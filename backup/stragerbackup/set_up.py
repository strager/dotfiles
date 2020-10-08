#!/usr/bin/env python

import contextlib
import datetime
import functools
import json
import logging
import os
import pathlib
import secrets
import shutil
import stragerbackup.archive
import stragerbackup.borg
import stragerbackup.site
import subprocess
import tempfile
import typing
import unittest


def main() -> None:
    logging.basicConfig(format="%(message)s", level=logging.INFO)
    site = stragerbackup.site.get_site_for_current_machine()
    set_up_backups(site=site)


def set_up_backups(site: stragerbackup.site.Site) -> None:
    site.backups_directory.mkdir(mode=0o700, parents=True, exist_ok=True)
    site.keys_directory.mkdir(mode=0o700, parents=True, exist_ok=True)

    process = stragerbackup.borg.run_borg_command(
        [
            "borg",
            "init",
            "--encryption",
            "keyfile-blake2",
            "--append-only",
            "--",
            str(site.repository),
        ],
        new_passphrase="",
    )
    process.check_returncode()

    archive_key_passphrase = generate_random_passphrase()
    stragerbackup.borg.copy_default_key(
        repository=site.repository, key_file=site.archive_key_file
    )
    stragerbackup.borg.change_borg_passphrase(
        repository=site.repository,
        key_file=site.archive_key_file,
        old_passphrase="",
        new_passphrase=archive_key_passphrase,
    )
    with open(site.archive_key_passphrase_file, "w") as f:
        site.archive_key_passphrase_file.chmod(0o400)
        f.write(archive_key_passphrase)

    with tempfile.NamedTemporaryFile() as temporary_file:
        temporary_key_file = pathlib.Path(temporary_file.name)
        stragerbackup.borg.copy_default_key(
            repository=site.repository, key_file=temporary_key_file
        )
        stragerbackup.borg.change_borg_passphrase_interactively(
            repository=site.repository,
            key_file=temporary_key_file,
        )
        stragerbackup.borg.copy_key_to_default(
            repository=site.repository, key_file=temporary_key_file
        )

    stragerbackup.borg.export_borg_key(
        repository=site.repository,
        output_file=site.exported_key_file,
    )
    stragerbackup.borg.export_borg_key(
        repository=site.repository,
        output_file=site.paper_key_file,
        mode="paper",
    )


def generate_random_passphrase() -> str:
    return secrets.token_hex(25)


class TestRandom(unittest.TestCase):
    def test_random_passphrases_are_long(self) -> None:
        for _ in range(100):
            passphrase = generate_random_passphrase()
            self.assertGreater(len(passphrase), 20)


class TestBackups(unittest.TestCase):
    def test_set_up_backups(self) -> None:
        logging.basicConfig(format="%(message)s", level=logging.INFO)

        with tempfile.TemporaryDirectory() as temporary_directory:
            temp_dir = pathlib.Path(temporary_directory)
            site = stragerbackup.site.Site(
                name="test-site",
                slow_backup_frequency=datetime.timedelta(days=7),
                backups_directory=temp_dir / "backups",
                keys_directory=temp_dir / "keys",
            )

            with environment_variables(BORG_BASE_DIR=str(temp_dir / "borg")):
                with environment_variables(BORG_NEW_PASSPHRASE="tacotruck"):
                    set_up_backups(site)

                auto_archives = stragerbackup.borg.get_borg_archives(
                    repository=site.repository,
                    key_file=site.archive_key_file,
                    key_passphrase_file=site.archive_key_passphrase_file,
                )
                self.assertEqual(auto_archives, [], "archive_key_file should be usable")

                list_command = stragerbackup.borg.run_borg_command(
                    command=["borg", "list", "--json", "--", str(site.repository)],
                    passphrase="tacotruck",
                    stdout=subprocess.PIPE,
                )
                list_command.check_returncode()
                manual_archives = stragerbackup.borg.parse_borg_list_output(
                    json.loads(list_command.stdout)
                )
                self.assertEqual(
                    manual_archives, [], "Typed passphrase should be usable"
                )

            with environment_variables(BORG_BASE_DIR=str(temp_dir / "borg-2")):
                self.assertTrue(site.paper_key_file.is_file())
                import_command = stragerbackup.borg.run_borg_command(
                    command=[
                        "borg",
                        "key",
                        "import",
                        "--",
                        str(site.repository),
                        str(site.exported_key_file),
                    ],
                )
                import_command.check_returncode()

                list_command = stragerbackup.borg.run_borg_command(
                    command=["borg", "list", "--json", "--", str(site.repository)],
                    passphrase="tacotruck",
                    stdout=subprocess.PIPE,
                )
                list_command.check_returncode()  # Should not fail.


@contextlib.contextmanager
def environment_variables(**env):
    old_values = {name: os.getenv(name) for name in env.keys()}

    def restore(name) -> None:
        old_value = old_values[name]
        if old_value is None:
            del os.environ[name]
        else:
            os.environ[name] = old_value

    with contextlib.ExitStack() as cleanups:
        for (name, new_value) in env.items():
            os.environ[name] = new_value
            cleanups.callback(functools.partial(restore, name))
        yield


if __name__ == "__main__":
    main()
