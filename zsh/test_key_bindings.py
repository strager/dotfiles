#!/usr/bin/env python3

import pathlib
import pexpect
import re
import sys
import tempfile
import tty
import typing
import unittest

from zsh import SpawnZSHTestMixin, wait_for_zle_to_initialize


class ZSHKeyBindingsTestCase(SpawnZSHTestMixin, unittest.TestCase):
    def test_alt_backspace_deletes_path_component_backward(self) -> None:
        test_cases = [
            (b"one two three", b"one two "),
            (b"one two ", b"one "),
            (b"one two >file", b"one two >"),
            (b"one two <file", b"one two <"),
            (b"one two |file", b"one two |"),
            (b"ls path/to/file", b"ls path/to/"),
            (b"ls path/to/dir/", b"ls path/to/"),
            (b"ls hello_world.txt", b"ls "),
        ]
        test_cases.extend(
            (b"one two file" + bytes([c, c, c]), b"one two ")
            for c in path_component_characters
        )
        for (input, expected) in test_cases:
            with self.subTest(expected=expected, input=input):
                self.assertEqual(
                    self.input_buffer_after_input(input + alt_backspace), expected
                )

    def test_alt_backspace_deletes_backward_to_symbol(self) -> None:
        test_cases = [
            (b"one two >three", b"one two >"),
            (b"one & two", b"one & "),
            (b"a ${var}", b"a ${var"),
            (b"a ${var", b"a ${"),
        ]
        for (input, expected) in test_cases:
            with self.subTest(expected=expected, input=input):
                self.assertEqual(
                    self.input_buffer_after_input(input + alt_backspace), expected
                )

    def test_alt_backspace_deletes_symbols_backward(self) -> None:
        test_cases = [
            (b"one two @|$", b"one two "),
            (b"one two @ | $", b"one two @ | "),
            (b"one two! @", b"one two! "),
        ]

        path_component_symbols = bytes(
            set(common_symbols) & set(path_component_characters)
        )
        test_cases.append((b"one two " + path_component_symbols, b"one two "))
        test_cases.extend(
            (b"one two " + bytes([symbol]), b"one two ")
            for symbol in path_component_symbols
        )

        not_symbols = b"/"
        symbol_like_symbols = bytes(
            set(common_symbols) - set(path_component_symbols) - set(not_symbols)
        )
        test_cases.append((b"one two " + symbol_like_symbols, b"one two "))
        test_cases.extend(
            (b"one two " + bytes([symbol]), b"one two ")
            for symbol in symbol_like_symbols
        )

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

    def test_ctrl_w_deletes_symbols_as_letters(self) -> None:
        test_cases = [
            (b"one two @|+", b"one two "),
            (b"one two a@b|c+d", b"one two "),
            (b"one two @ | +", b"one two @ | "),
            (b"one two! @", b"one two! "),
        ]
        test_cases.append((b"one two " + common_symbols, b"one two "))
        test_cases.extend(
            (b"one two " + bytes([symbol]), b"one two ") for symbol in common_symbols
        )
        for (input, expected) in test_cases:
            with self.subTest(expected=expected, input=input):
                self.assertEqual(
                    self.input_buffer_after_input(input + ctrl_w), expected
                )

    def input_buffer_after_input(self, input: bytes) -> bytes:
        zsh = self.spawn_zsh()
        dump_input_buffer_on_ctrl_g(zsh)

        wait_for_zle_to_initialize(zsh)
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

common_symbols = b"~!@#$%^&*()_+~-={}|[]\\:\";'<>?,./"
path_component_characters = (
    b"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-+._"
)
