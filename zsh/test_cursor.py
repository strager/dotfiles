#!/usr/bin/env python3

import pathlib
import pexpect
import re
import sys
import tempfile
import typing
import unittest
from zsh import (
    ITermCursorShape,
    SpawnZSHTestMixin,
    string_ignoring_escape_sequences_re,
    wait_for_zle_to_initialize,
)
from test_iterm_integration import expect_ftcs_command_start


class ZSHCursorTestCase(SpawnZSHTestMixin, unittest.TestCase):
    def test_cursor_is_vertical_bar_at_prompt_by_default(self) -> None:
        zsh = self.spawn_zsh()
        expect_ftcs_command_start(zsh)
        self.assertEqual(zsh.current_iterm_cursor_shape, ITermCursorShape.VERTICAL_BAR)

    def test_cursor_is_block_during_command_execution(self) -> None:
        zsh = self.spawn_zsh()
        zsh.send(b"printf '%s is running:' command ; cat\n")
        zsh.expect_exact(b"command is running:")
        self.assertEqual(zsh.current_iterm_cursor_shape, ITermCursorShape.BLOCK)

    def test_cursor_is_vertical_bar_in_vi_insert_mode(self) -> None:
        zsh = self.spawn_zsh()
        zsh.send(b"bindkey -v\n")
        zsh.send(b"abcdefg")
        wait_for_zle_to_initialize(zsh)
        self.assertEqual(zsh.current_iterm_cursor_shape, ITermCursorShape.VERTICAL_BAR)

    def test_cursor_is_vertical_bar_in_vi_command_mode(self) -> None:
        zsh = self.spawn_zsh()
        wait_for_zle_to_initialize(zsh)
        zsh.sendcontrol("x")
        zsh.sendcontrol("v")

        zsh.send(b"ga")
        zsh.expect_exact(b"column 0")

        self.assertEqual(zsh.current_iterm_cursor_shape, ITermCursorShape.BLOCK)

    def test_cursor_is_vertical_bar_in_vi_insert_mode_coming_from_command_mode(
        self
    ) -> None:
        zsh = self.spawn_zsh()
        wait_for_zle_to_initialize(zsh)
        zsh.sendcontrol("x")
        zsh.sendcontrol("v")

        # Switch to insert mode.
        zsh.send(b"a")
        # HACK(strager): Wait for cursor to change, avoiding syntax highlighter
        # quirks.
        zsh.send(b"#MY COMMAND")
        zsh.expect_exact(b"MY COMMAN")

        self.assertEqual(zsh.current_iterm_cursor_shape, ITermCursorShape.VERTICAL_BAR)


if __name__ == "__main__":
    unittest.main()
