#!/usr/bin/env python3

import pathlib
import pexpect
import re
import sys
import tempfile
import tty
import typing
import unittest
import zsh


class ZSHKeyBindingsTestCase(unittest.TestCase, zsh.SpawnZSHTestMixin):
    def test_alt_backspace_deletes_entire_word_backward(self) -> None:
        test_cases = [
            (b"one two three", b"one two "),
            (b"one two ", b"one "),
            (b"one two >three", b"one two "),
            (b"ls path/to/file", b"ls "),
            (b"ls path/to/dir/", b"ls "),
        ]
        for (input, expected) in test_cases:
            with self.subTest(expected=expected, input=input):
                self.assertEqual(
                    self.input_buffer_after_input(input + alt_backspace), expected
                )

    def test_alt_backspace_deletes_symbols_backword_then_word_backward(self) -> None:
        test_cases = [
            (b"one two @|+", b"one "),
            (b"one two @ | +", b"one "),
            (b"one two! @", b"one "),
        ]
        for (input, expected) in test_cases:
            with self.subTest(expected=expected, input=input):
                self.assertEqual(
                    self.input_buffer_after_input(input + alt_backspace), expected
                )

    def test_ctrl_w_deletes_entire_word_backward(self) -> None:
        test_cases = [
            (b"one two three", b"one two "),
            (b"one two ", b"one "),
            (b"one two >three", b"one two "),
            (b"ls path/to/file", b"ls "),
            (b"ls path/to/dir/", b"ls "),
        ]
        for (input, expected) in test_cases:
            with self.subTest(expected=expected, input=input):
                self.assertEqual(
                    self.input_buffer_after_input(input + ctrl_w), expected
                )

    def test_ctrl_w_deletes_symbols_backword_then_word_backward(self) -> None:
        test_cases = [
            (b"one two @|+", b"one "),
            (b"one two @ | +", b"one "),
            (b"one two! @", b"one "),
        ]
        for (input, expected) in test_cases:
            with self.subTest(expected=expected, input=input):
                self.assertEqual(
                    self.input_buffer_after_input(input + ctrl_w), expected
                )

    def input_buffer_after_input(self, input: bytes) -> bytes:
        zsh = self.spawn_zsh()
        dump_input_buffer_on_ctrl_g(zsh)

        # HACK(strager): Wait for zle to initialize.
        zsh.sendcontrol("l")
        zsh.expect_exact(clear_screen)

        zsh.send(input)
        zsh.sendcontrol("g")
        return get_dumped_input_buffer(zsh)


def dump_input_buffer_on_ctrl_g(zsh: pexpect.spawn) -> None:
    zsh.send(
        b"""strager_echo_buffer() { printf '[%s[%s]%s]\\n' '[' "${BUFFER}" ']' }\n"""
    )
    zsh.send(b"zle -N strager_echo_buffer\n")
    zsh.send(b"bindkey '^g' strager_echo_buffer\n")


def get_dumped_input_buffer(zsh: pexpect.spawn) -> None:
    zsh.expect(b"\[\[\[(?P<input_buffer>.*)\]\]\]")
    return zsh.match.group("input_buffer")


alt_backspace = b"\x1b\x7f"
ctrl_w = b"\x17"

clear_screen = b"\x1b[2J"
