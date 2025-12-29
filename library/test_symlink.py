#!/usr/bin/env python
# -*- coding: utf-8 -*-

import os
import sys
import tempfile
import unittest
from unittest.mock import MagicMock, patch

# Mock ansible before importing symlink
sys.modules['ansible'] = MagicMock()
sys.modules['ansible.module_utils'] = MagicMock()
sys.modules['ansible.module_utils.basic'] = MagicMock()

from symlink import symlink_is_correct, create_symlink_atomic, main


class ExitJson(Exception):
    """Raised by FakeAnsibleModule.exit_json to halt execution."""
    def __init__(self, kwargs):
        self.kwargs = kwargs


class FailJson(Exception):
    """Raised by FakeAnsibleModule.fail_json to halt execution."""
    def __init__(self, kwargs):
        self.kwargs = kwargs


class FakeAnsibleModule:
    """Test double for AnsibleModule that captures exit/fail calls."""

    def __init__(self, argument_spec, supports_check_mode):
        self.argument_spec = argument_spec
        self.params = {}
        self.check_mode = False

    def exit_json(self, **kwargs):
        raise ExitJson(kwargs)

    def fail_json(self, **kwargs):
        raise FailJson(kwargs)


class TestSymlinkIsCorrect(unittest.TestCase):
    def setUp(self):
        self.tmpdir = tempfile.TemporaryDirectory()

    def tearDown(self):
        self.tmpdir.cleanup()

    def test_missing_returns_false(self):
        dest = os.path.join(self.tmpdir.name, "missing")
        self.assertFalse(symlink_is_correct(dest, "/some/src"))

    def test_file_returns_false(self):
        dest = os.path.join(self.tmpdir.name, "file")
        with open(dest, "w") as f:
            f.write("content")
        self.assertFalse(symlink_is_correct(dest, "/some/src"))

    def test_directory_returns_false(self):
        dest = os.path.join(self.tmpdir.name, "dir")
        os.mkdir(dest)
        self.assertFalse(symlink_is_correct(dest, "/some/src"))

    def test_correct_symlink_returns_true(self):
        src = "/some/src"
        dest = os.path.join(self.tmpdir.name, "link")
        os.symlink(src, dest)
        self.assertTrue(symlink_is_correct(dest, src))

    def test_wrong_symlink_returns_false(self):
        dest = os.path.join(self.tmpdir.name, "link")
        os.symlink("/wrong/target", dest)
        self.assertFalse(symlink_is_correct(dest, "/some/src"))


class TestCreateSymlinkAtomic(unittest.TestCase):
    def setUp(self):
        self.tmpdir = tempfile.TemporaryDirectory()

    def tearDown(self):
        self.tmpdir.cleanup()

    def test_creates_symlink_when_dest_missing(self):
        src = "/some/src"
        dest = os.path.join(self.tmpdir.name, "link")
        create_symlink_atomic(src, dest)
        self.assertTrue(os.path.islink(dest))
        self.assertEqual(os.readlink(dest), src)

    def test_replaces_file_with_symlink(self):
        src = "/some/src"
        dest = os.path.join(self.tmpdir.name, "file")
        with open(dest, "w") as f:
            f.write("content")
        create_symlink_atomic(src, dest)
        self.assertTrue(os.path.islink(dest))
        self.assertEqual(os.readlink(dest), src)

    def test_replaces_correct_symlink(self):
        src = "/some/src"
        dest = os.path.join(self.tmpdir.name, "link")
        os.symlink(src, dest)
        create_symlink_atomic(src, dest)
        self.assertTrue(os.path.islink(dest))
        self.assertEqual(os.readlink(dest), src)

    def test_replaces_wrong_symlink(self):
        src = "/some/src"
        dest = os.path.join(self.tmpdir.name, "link")
        os.symlink("/wrong/target", dest)
        create_symlink_atomic(src, dest)
        self.assertTrue(os.path.islink(dest))
        self.assertEqual(os.readlink(dest), src)


class TestMain(unittest.TestCase):
    def setUp(self):
        self.tmpdir = tempfile.TemporaryDirectory()
        self.fake_module = FakeAnsibleModule({}, True)
        self.module_patcher = patch('symlink.AnsibleModule', return_value=self.fake_module)
        self.module_patcher.start()

    def tearDown(self):
        self.module_patcher.stop()
        self.tmpdir.cleanup()

    def test_creates_symlink_with_absolute_src(self):
        src = "/absolute/path/to/src"
        dest = os.path.join(self.tmpdir.name, "link")
        self.fake_module.params = {"src": src, "dest": dest, "force": False}

        with self.assertRaises(ExitJson) as ctx:
            main()

        self.assertTrue(ctx.exception.kwargs["changed"])
        self.assertTrue(os.path.islink(dest))
        self.assertEqual(os.readlink(dest), src)

    def test_creates_symlink_with_relative_src(self):
        src = "../relative/path"
        dest = os.path.join(self.tmpdir.name, "link")
        self.fake_module.params = {"src": src, "dest": dest, "force": False}

        with self.assertRaises(ExitJson) as ctx:
            main()

        self.assertTrue(ctx.exception.kwargs["changed"])
        self.assertTrue(os.path.islink(dest))
        self.assertEqual(os.readlink(dest), src)

    def test_creates_dangling_symlink(self):
        src = os.path.join(self.tmpdir.name, "nonexistent")
        dest = os.path.join(self.tmpdir.name, "link")
        self.fake_module.params = {"src": src, "dest": dest, "force": False}

        with self.assertRaises(ExitJson) as ctx:
            main()

        self.assertTrue(ctx.exception.kwargs["changed"])
        self.assertTrue(os.path.islink(dest))

    def test_idempotent_when_symlink_correct(self):
        src = "/some/src"
        dest = os.path.join(self.tmpdir.name, "link")
        os.symlink(src, dest)
        self.fake_module.params = {"src": src, "dest": dest, "force": False}

        with self.assertRaises(ExitJson) as ctx:
            main()

        self.assertFalse(ctx.exception.kwargs["changed"])

    def test_updates_wrong_symlink(self):
        src = "/correct/src"
        dest = os.path.join(self.tmpdir.name, "link")
        os.symlink("/wrong/target", dest)
        self.fake_module.params = {"src": src, "dest": dest, "force": False}

        with self.assertRaises(ExitJson) as ctx:
            main()

        self.assertTrue(ctx.exception.kwargs["changed"])
        self.assertEqual(os.readlink(dest), src)

    def test_fails_when_dest_is_file(self):
        src = "/some/src"
        dest = os.path.join(self.tmpdir.name, "file")
        with open(dest, "w") as f:
            f.write("content")
        self.fake_module.params = {"src": src, "dest": dest, "force": False}

        with self.assertRaises(FailJson) as ctx:
            main()

        self.assertIn("already exists", ctx.exception.kwargs["msg"])

    def test_fails_when_dest_is_directory(self):
        src = "/some/src"
        dest = os.path.join(self.tmpdir.name, "dir")
        os.mkdir(dest)
        self.fake_module.params = {"src": src, "dest": dest, "force": False}

        with self.assertRaises(FailJson) as ctx:
            main()

        self.assertIn("already exists", ctx.exception.kwargs["msg"])

    def test_fails_when_parent_missing(self):
        src = "/some/src"
        dest = os.path.join(self.tmpdir.name, "parent", "child", "link")
        self.fake_module.params = {"src": src, "dest": dest, "force": False}

        with self.assertRaises(FailJson) as ctx:
            main()

        self.assertIn("does not exist", ctx.exception.kwargs["msg"])

    def test_check_mode_does_not_create_symlink(self):
        src = "/some/src"
        dest = os.path.join(self.tmpdir.name, "link")
        self.fake_module.params = {"src": src, "dest": dest, "force": False}
        self.fake_module.check_mode = True

        with self.assertRaises(ExitJson) as ctx:
            main()

        self.assertTrue(ctx.exception.kwargs["changed"])
        self.assertFalse(os.path.exists(dest))

    def test_check_mode_fails_when_parent_missing(self):
        src = "/some/src"
        dest = os.path.join(self.tmpdir.name, "parent", "link")
        self.fake_module.params = {"src": src, "dest": dest, "force": False}
        self.fake_module.check_mode = True

        with self.assertRaises(FailJson) as ctx:
            main()

        self.assertIn("does not exist", ctx.exception.kwargs["msg"])

    def test_check_mode_idempotent_when_symlink_correct(self):
        src = "/some/src"
        dest = os.path.join(self.tmpdir.name, "link")
        os.symlink(src, dest)
        self.fake_module.params = {"src": src, "dest": dest, "force": False}
        self.fake_module.check_mode = True

        with self.assertRaises(ExitJson) as ctx:
            main()

        self.assertFalse(ctx.exception.kwargs["changed"])

    def test_check_mode_reports_changed_for_wrong_symlink(self):
        src = "/correct/src"
        dest = os.path.join(self.tmpdir.name, "link")
        os.symlink("/wrong/target", dest)
        self.fake_module.params = {"src": src, "dest": dest, "force": False}
        self.fake_module.check_mode = True

        with self.assertRaises(ExitJson) as ctx:
            main()

        self.assertTrue(ctx.exception.kwargs["changed"])
        # Symlink should NOT be updated in check_mode
        self.assertEqual(os.readlink(dest), "/wrong/target")

    def test_check_mode_fails_when_dest_is_file(self):
        src = "/some/src"
        dest = os.path.join(self.tmpdir.name, "file")
        with open(dest, "w") as f:
            f.write("content")
        self.fake_module.params = {"src": src, "dest": dest, "force": False}
        self.fake_module.check_mode = True

        with self.assertRaises(FailJson) as ctx:
            main()

        self.assertIn("already exists", ctx.exception.kwargs["msg"])

    def test_check_mode_fails_when_dest_is_directory(self):
        src = "/some/src"
        dest = os.path.join(self.tmpdir.name, "dir")
        os.mkdir(dest)
        self.fake_module.params = {"src": src, "dest": dest, "force": False}
        self.fake_module.check_mode = True

        with self.assertRaises(FailJson) as ctx:
            main()

        self.assertIn("already exists", ctx.exception.kwargs["msg"])

    def test_fails_when_force_is_true(self):
        src = "/some/src"
        dest = os.path.join(self.tmpdir.name, "link")
        self.fake_module.params = {"src": src, "dest": dest, "force": True}

        with self.assertRaises(FailJson) as ctx:
            main()

        self.assertIn("not supported", ctx.exception.kwargs["msg"])


if __name__ == "__main__":
    unittest.main()
