import io
import multiprocessing.dummy
import os
import pathlib
import pexpect
import re
import sys
import typing
import unittest


class SpawnZSHTestMixin:
    _spawned_zshs: typing.List[pexpect.spawn]

    def __init__(self, *args, **kwargs) -> None:
        self._spawned_zshs = []
        super().__init__(*args, **kwargs)

    def spawn_zsh(self, cwd: typing.Optional[pathlib.Path] = None) -> pexpect.spawn:
        log_file = io.BytesIO()
        zsh = spawn_zsh(cwd=cwd, log_file=log_file)
        self._spawned_zshs.append(zsh)

        def log_terminal_output_on_test_failure() -> None:
            if self.current_test_failed:
                output = log_file.getvalue()
                print(
                    f"zsh terminal output:\n{pretty_terminal_output(output)}",
                    file=sys.stderr,
                )

        self.addCleanup(lambda: log_terminal_output_on_test_failure())
        self.addCleanup(lambda: self._close_spawned_zshs())
        return zsh

    def _close_spawned_zshs(self) -> None:
        zshs_to_close = [zsh for zsh in self._spawned_zshs if not zsh.closed]
        if not zshs_to_close:
            return
        with multiprocessing.dummy.Pool() as pool:
            pool.map(lambda zsh: zsh.close(force=True), zshs_to_close)

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


def spawn_zsh(
    log_file: typing.BinaryIO, cwd: typing.Optional[pathlib.Path] = None
) -> pexpect.spawn:
    env = dict(os.environ)
    env["STRAGER_DISABLE_HISTFILE"] = "1"
    zsh = pexpect.spawn(
        zsh_executable(), args=["-i"], cwd=cwd, env=env, logfile=log_file, timeout=3
    )
    zsh.delaybeforesend = None
    zsh.logfile_send = None
    return zsh


def zsh_executable() -> pathlib.Path:
    return pathlib.Path("zsh")


def wait_for_zle_to_initialize(zsh: pexpect.spawn) -> None:
    clear_screen = b"\x1b[2J"
    zsh.sendcontrol("l")
    zsh.expect_exact(clear_screen)


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


def pretty_terminal_output(data: bytes) -> str:
    special_bytes: typing.Dict[byte, str] = {
        b"\n"[0]: '\\n"\nb"',
        b"\t"[0]: r"\t",
        b'"'[0]: r"\"",
        0x7F: r"\x7f",
    }

    out = io.StringIO()
    out.write('b"')
    for byte in data:
        escape_code = special_bytes.get(byte)
        if escape_code is None:
            if 0x20 <= byte < 0x80:
                out.write(chr(byte))
            else:
                out.write(f"\\x{byte:02x}")
        else:
            out.write(escape_code)
    out.write('"')
    result = out.getvalue()

    if data[-1:] == b"\n":
        result_to_strip = '\nb""'
        assert result.endswith(
            result_to_strip
        ), f"{result!r} should end with {result_to_strip!r}"
        result = result[: -len(result_to_strip)]
    return result


class PrettyTerminalOutputTestCase(unittest.TestCase):
    def test_empty(self) -> None:
        self.assertEqual(pretty_terminal_output(b""), 'b""')

    def test_single_quotes_are_verbatim(self) -> None:
        self.assertEqual(pretty_terminal_output(b"'"), '''b"'"''')

    def test_double_quotes_are_escaped(self) -> None:
        self.assertEqual(pretty_terminal_output(b'"'), r'b"\""')

    def test_most_printable_characters_are_verbatim(self) -> None:
        self.assertEqual(pretty_terminal_output(b"abcdefg"), 'b"abcdefg"')
        self.assertEqual(pretty_terminal_output(b"~!@#$%^&*()_+"), 'b"~!@#$%^&*()_+"')

    def test_spaces_are_verbatim(self) -> None:
        self.assertEqual(pretty_terminal_output(b" "), 'b" "')

    def test_tabs_are_code_escaped(self) -> None:
        self.assertEqual(pretty_terminal_output(b"\t"), r'b"\t"')

    def test_newlines_are_code_escaped_and_add_line_break(self) -> None:
        self.assertEqual(
            pretty_terminal_output(b"hello\nworld"), 'b"hello\\n"\nb"world"'
        )

    def test_trailing_newlines_do_not_add_line_break(self) -> None:
        self.assertEqual(pretty_terminal_output(b"\n"), r'b"\n"')
        self.assertEqual(pretty_terminal_output(b"hello\n"), r'b"hello\n"')
        self.assertEqual(
            pretty_terminal_output(b"hello\nworld\n"), 'b"hello\\n"\nb"world\\n"'
        )

    def test_most_control_codes_are_hex_escaped(self) -> None:
        self.assertEqual(pretty_terminal_output(b"\x00"), r'b"\x00"')
        self.assertEqual(pretty_terminal_output(b"\x01"), r'b"\x01"')
        self.assertEqual(pretty_terminal_output(b"\x02"), r'b"\x02"')
        self.assertEqual(pretty_terminal_output(b"\x0b"), r'b"\x0b"')
        self.assertEqual(pretty_terminal_output(b"\x10"), r'b"\x10"')
        self.assertEqual(pretty_terminal_output(b"\x1b"), r'b"\x1b"')
        self.assertEqual(pretty_terminal_output(b"\x1f"), r'b"\x1f"')
        self.assertEqual(pretty_terminal_output(b"\x7f"), r'b"\x7f"')

    def test_high_bit_bytes_are_hex_escaped(self) -> None:
        self.assertEqual(pretty_terminal_output(b"\x80"), r'b"\x80"')
        self.assertEqual(pretty_terminal_output(b"\x81"), r'b"\x81"')
        self.assertEqual(pretty_terminal_output(b"\x90"), r'b"\x90"')
        self.assertEqual(pretty_terminal_output(b"\x9c"), r'b"\x9c"')
        self.assertEqual(pretty_terminal_output(b"\xff"), r'b"\xff"')
