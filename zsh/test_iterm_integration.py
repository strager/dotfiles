#!/usr/bin/env python3

import pathlib
import pexpect
import re
import sys
import tempfile
import typing
import unittest
from zsh import (
    SpawnZSHTestMixin,
    string_ignoring_escape_sequences_re,
    wait_for_zle_to_initialize,
)


class ZSHITermPromptTestCase(unittest.TestCase, SpawnZSHTestMixin):
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
        wait_for_zle_to_initialize(zsh)
        send_and_expect_byte_by_byte(zsh, b"echo hello")
        zsh.sendintr()
        exit_status = expect_ftcs_command_finished(zsh)
        self.assertEqual(exit_status, 130)
        self.assertNotRegex(
            zsh.before,
            ftcs_command_executed_re,
            "FTCS_COMMAND_EXECUTED should not preceed FTCS_COMMAND_FINISHED.",
        )


def send_and_expect_byte_by_byte(zsh: pexpect.spawn, input: bytes) -> bytes:
    for byte in input:
        current_input = bytes([byte])
        zsh.send(current_input)
        zsh.expect(string_ignoring_escape_sequences_re(current_input))


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


"""A regular expression matching components inside a FinalTerm escape sequence.
"""
ftcs_extra_arguments_re = b"(?:;[^\x07]*)*"

"""A regular expression pattern matching a FinalTerm FTCS_COMMAND_EXECUTED
escape sequence.
"""
ftcs_command_executed_re = b"\x1b]133;C" + ftcs_extra_arguments_re + b"\x07"


if __name__ == "__main__":
    unittest.main()
