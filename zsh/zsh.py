import io
import pathlib
import pexpect
import re
import sys
import typing


class SpawnZSHTestMixin:
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


def spawn_zsh(
    log_file: typing.BinaryIO, cwd: typing.Optional[pathlib.Path] = None
) -> pexpect.spawn:
    zsh = pexpect.spawn(
        zsh_executable(), args=["-i"], cwd=cwd, logfile=log_file, timeout=3
    )
    zsh.logfile_send = None
    return zsh


def zsh_executable() -> pathlib.Path:
    return pathlib.Path("zsh")


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
