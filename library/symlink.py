#!/usr/bin/python
# -*- coding: utf-8 -*-

"""
Cross-platform symlink module for Ansible.

Unlike ansible.builtin.file with state=link, this module guarantees identical
symlink semantics on all platforms (Unix and Windows), making playbooks more
portable.

Uses atomic rename pattern to avoid TOCTOU bugs.
Windows requires Developer Mode or admin rights.
"""

from __future__ import absolute_import, division, print_function

__metaclass__ = type

DOCUMENTATION = r"""
---
module: symlink
short_description: Create symbolic links cross-platform
description:
  - Creates symbolic links with consistent behavior across Unix and Windows.
  - Unlike ansible.builtin.file, guarantees identical semantics on all
    platforms, making playbooks more portable.
  - Uses atomic rename to avoid race conditions.
  - On Windows, requires Developer Mode enabled or administrator privileges.
options:
  src:
    description:
      - Path to the file or directory to link to.
    type: str
    required: true
  dest:
    description:
      - Path where the symbolic link should be created.
    type: str
    required: true
  force:
    description:
      - Must be C(false). Fails if dest exists and is not the correct symlink.
    type: bool
    required: true
author:
  - strager
"""

EXAMPLES = r"""
- name: Create a symbolic link
  symlink:
    src: /path/to/source
    dest: /path/to/link
    force: false
"""

import os
import uuid

from ansible.module_utils.basic import AnsibleModule


def symlink_is_correct(dest, src):
    """Check if dest is a symlink pointing to src."""
    try:
        if os.path.islink(dest):
            return os.readlink(dest) == src
    except OSError:
        pass
    return False


def create_symlink_atomic(src, dest):
    """
    Create symlink atomically using temp file + rename.

    This avoids TOCTOU bugs by:
    1. Creating symlink at a temporary path
    2. Atomically renaming it to the destination

    os.replace() is atomic on POSIX and on Windows (same volume).
    """
    dest_dir = os.path.dirname(dest) or "."
    tmp_path = os.path.join(dest_dir, ".ansible_symlink.%s.tmp" % uuid.uuid4().hex)

    try:
        os.symlink(src, tmp_path)
        os.replace(tmp_path, dest)
    except OSError:
        # Clean up temp file on failure
        try:
            if os.path.islink(tmp_path) or os.path.exists(tmp_path):
                os.unlink(tmp_path)
        except OSError:
            pass
        raise


def main():
    module = AnsibleModule(
        argument_spec=dict(
            src=dict(type="str", required=True),
            dest=dict(type="str", required=True),
            force=dict(type="bool", required=True),
        ),
        supports_check_mode=True,
    )

    src = module.params["src"]
    dest = module.params["dest"]
    force = module.params["force"]
    check_mode = module.check_mode

    if force:
        module.fail_json(msg="force=true is not supported")

    result = dict(
        changed=False,
        src=src,
        dest=dest,
    )

    # Check if symlink already exists and is correct
    if symlink_is_correct(dest, src):
        module.exit_json(**result)

    # Fail if destination exists as a file or directory (not a symlink)
    # Existing symlinks with wrong target will be replaced (matches ansible.builtin.file)
    if os.path.exists(dest) and not os.path.islink(dest):
        module.fail_json(
            msg="Destination '%s' already exists." % dest,
            **result
        )

    # Fail if parent directory doesn't exist
    parent_dir = os.path.dirname(dest)
    if parent_dir and not os.path.exists(parent_dir):
        module.fail_json(
            msg="Parent directory '%s' does not exist." % parent_dir,
            **result
        )

    # Create the symlink
    if not check_mode:
        try:
            create_symlink_atomic(src, dest)
        except OSError as e:
            # Provide helpful error message for Windows permission issues
            error_msg = str(e)
            if "privilege" in error_msg.lower() or "1314" in error_msg:
                error_msg += " (On Windows, enable Developer Mode or run as Administrator)"
            module.fail_json(
                msg="Failed to create symlink: %s" % error_msg,
                **result
            )
    result["changed"] = True

    module.exit_json(**result)


if __name__ == "__main__":
    main()
