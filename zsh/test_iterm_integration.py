#!/usr/bin/env python3

import io
import pathlib
import pexpect
import re
import sys
import tempfile
import typing
import unittest


class ZSHITermPromptTestCase(unittest.TestCase):
    def test_prompt_is_delimited(self) -> None:
        zsh = self.spawn_zsh()
        expect_ftcs_prompt(zsh)
        expect_ftcs_command_start(zsh)
        prompt = zsh.before
        self.assertRegex(
            prompt, b"^.+ $", "Prompt escape sequences should wrap the non-empty prompt"
        )

    def test_typed_command_is_delimited(self) -> None:
        zsh = self.spawn_zsh()
        expect_ftcs_command_start(zsh)
        typed_command = b""
        zsh.send(b"echo hello world")
        zsh.expect(string_ignoring_escape_sequences_re(b"echo hello world"))
        typed_command += zsh.before
        typed_command += zsh.match.group(0)
        zsh.send(b"\n")
        expect_ftcs_command_executed(zsh)
        typed_command += zsh.before
        self.assertRegex(
            typed_command,
            b"^"
            + string_ignoring_escape_sequences_re(b"echo hello world")
            + b"[\r\n]*$",
            "Command escape sequences should wrap the typed command",
        )

    def test_command_output_is_delimited(self) -> None:
        zsh = self.spawn_zsh()
        expect_ftcs_command_start(zsh)
        zsh.send(b"printf '%s world\\n' hello\n")
        expect_ftcs_command_executed(zsh)
        expect_ftcs_command_finished(zsh)
        command_output = zsh.before
        self.assertRegex(
            command_output,
            b"^hello world\r\n",
            "Command escape sequences should wrap the command's output",
        )

    def test_exit_code_sequence_follows_command_output(self) -> None:
        zsh = self.spawn_zsh()
        zsh.send(b"(echo hello; exit 42)\n")
        zsh.expect(b"hello\r\n")
        exit_status = expect_ftcs_command_finished(zsh)
        self.assertEqual(exit_status, 42)

    def test_prompt_includes_current_working_directory_sequence(self) -> None:
        with tempfile.TemporaryDirectory() as temp_dir:
            directory = pathlib.Path(temp_dir).resolve()

            zsh = self.spawn_zsh(cwd=directory)
            iterm_dir = expect_iterm_current_dir(zsh)
            self.assertEqual(iterm_dir, bytes(directory))

            # HACK(strager): Skip duplicate sequences.
            expect_ftcs_command_start(zsh)

            subdirectory = directory / "subdirectory"
            subdirectory.mkdir()
            zsh.send(b"cd subdirectory\n")
            iterm_dir = expect_iterm_current_dir(zsh)
            self.assertEqual(iterm_dir, bytes(subdirectory))

    def test_ctrl_c_reports_command_finished_sequence(self) -> None:
        zsh = self.spawn_zsh()
        send_and_expect_byte_by_byte(zsh, b"echo hello")
        zsh.sendintr()
        exit_status = expect_ftcs_command_finished(zsh)
        self.assertEqual(exit_status, 130)
        # TODO(strager): Ensure FTCS_COMMAND_EXECUTED does not preceed
        # FTCS_COMMAND_FINISHED.
        if False:
            self.assertNotRegex(
                zsh.before,
                ftcs_command_executed_re,
                "FTCS_COMMAND_EXECUTED should not preceed FTCS_COMMAND_FINISHED.",
            )

    def spawn_zsh(self, cwd: typing.Optional[pathlib.Path] = None) -> pexpect.spawn:
        log_file = io.BytesIO()
        zsh = spawn_zsh(cwd=cwd, log_file=log_file)

        def log_terminal_output_on_test_failure() -> None:
            if self.current_test_failed:
                print(f"zsh terminal output: {log_file.getvalue()!r}", file=sys.stderr)

        self.addCleanup(lambda: log_terminal_output_on_test_failure())
        self.addCleanup(lambda: zsh.close(force=True))
        return zsh

    @property
    def current_test_failed(self) -> bool:
        # HACK(strager): Use private APIs of unittest to determine if the test
        # failed.
        if self._outcome is None:
            return False
        if not self._outcome.success:
            return True
        for (test, exc_info) in self._outcome.errors:
            if exc_info is not None:
                return True
        return False


def send_and_expect_byte_by_byte(zsh: pexpect.spawn, input: bytes) -> bytes:
    for byte in input:
        current_input = bytes([byte])
        zsh.send(current_input)
        zsh.expect(string_ignoring_escape_sequences_re(current_input))


def string_ignoring_escape_sequences_re(string: bytes) -> bytes:
    """Return a regular expression pattern which matches the given string with
    optionally interleaved terminal escape sequences.

    Use this function to ignore color escape sequences used for syntax
    highlighting, for example.
    """
    escape_sequence_re = b"(?:\x1b.+)?"
    return (
        escape_sequence_re
        + escape_sequence_re.join(re.escape(bytes([b])) for b in string)
        + escape_sequence_re
    )


def expect_ftcs_prompt(zsh: pexpect.spawn) -> None:
    """Match a FinalTerm FTCS_PROMPT escape sequence.
    """
    zsh.expect(b"\x1b]133;A" + ftcs_extra_arguments_re + b"\x07")


def expect_ftcs_command_start(zsh: pexpect.spawn) -> None:
    """Match a FinalTerm FTCS_COMMAND_START escape sequence.
    """
    zsh.expect(b"\x1b]133;B" + ftcs_extra_arguments_re + b"\x07")


def expect_ftcs_command_executed(zsh: pexpect.spawn) -> None:
    """Match a FinalTerm FTCS_COMMAND_EXECUTED escape sequence.
    """
    zsh.expect(b"\x1b]133;C" + ftcs_extra_arguments_re + b"\x07")


def expect_ftcs_command_finished(zsh: pexpect.spawn) -> typing.Optional[int]:
    """Match a FinalTerm FTCS_COMMAND_FINISHED escape sequence.
    """
    zsh.expect(
        b"\x1b]133;D(?:;(?P<exit_status>[0-9]+))?" + ftcs_extra_arguments_re + b"\x07"
    )
    exit_status = zsh.match.group("exit_status")
    if not exit_status:
        return None
    return int(exit_status)


def expect_iterm_current_dir(zsh: pexpect.spawn) -> bytes:
    """Match a iTerm CurrentDir escape sequence.
    """
    zsh.expect(b"\x1b](?:1337|50);CurrentDir=(?P<iterm_current_dir_path>.*?)\x07")
    return zsh.match.group("iterm_current_dir_path")


def spawn_zsh(
    log_file: typing.BinaryIO, cwd: typing.Optional[pathlib.Path] = None
) -> pexpect.spawn:
    zsh = pexpect.spawn(
        zsh_executable(), args=["-i"], cwd=cwd, logfile=log_file, timeout=3
    )
    zsh.logfile_send = None
    return zsh


"""A regular expression matching components inside a FinalTerm escape sequence.
"""
ftcs_extra_arguments_re = b"(?:;[^\x07]*)*"

"""A regular expression pattern matching a FinalTerm FTCS_COMMAND_EXECUTED
escape sequence.
"""
ftcs_command_executed_re = b"\x1b]133;C" + ftcs_extra_arguments_re + b"\x07"


def zsh_executable() -> pathlib.Path:
    return pathlib.Path("zsh")


if __name__ == "__main__":
    unittest.main()
