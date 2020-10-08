import contextlib
import datetime
import json
import logging
import os
import pathlib
import pipes
import stragerbackup.util
import subprocess
import tempfile
import typing

logger = logging.getLogger(__name__)


def run_borg_command(
    command: typing.Sequence[str],
    key_file: typing.Optional[pathlib.Path] = None,
    keys_dir: typing.Optional[pathlib.Path] = None,
    passphrase: typing.Optional[str] = None,
    passphrase_file: typing.Optional[pathlib.Path] = None,
    new_passphrase: typing.Optional[str] = None,
    **subprocess_run_kwargs,
) -> subprocess.CompletedProcess:
    with contextlib.ExitStack() as cleanups:
        extra_env = {}
        pass_fds = []

        if key_file is not None:
            extra_env["BORG_KEY_FILE"] = str(key_file)
        if keys_dir is not None:
            extra_env["BORG_KEYS_DIR"] = str(keys_dir)

        assert (
            passphrase is None or passphrase_file is None
        ), "passphrase and passphrase_file are mututally exclusive"
        if passphrase is not None:
            # TODO(strager): Always give passphrases using files.
            extra_env["BORG_PASSPHRASE"] = passphrase
        if passphrase_file is not None:
            passphrase_fd = os.open(passphrase_file, os.O_RDONLY)
            cleanups.callback(lambda: os.close(passphrase_fd))
            extra_env["BORG_PASSPHRASE_FD"] = str(passphrase_fd)
            pass_fds.append(passphrase_fd)

        if new_passphrase is not None:
            # TODO(strager): Always give passphrases using files. Unfortunately,
            # Borg does not have a way to give a file or fd or command for the
            # new passphrase.
            extra_env["BORG_NEW_PASSPHRASE"] = new_passphrase

        logger.info(
            f"$ {stragerbackup.util.command_string(command=command, extra_env=extra_env)}"
        )

        return subprocess.run(
            command,
            env=dict(os.environ, **extra_env),
            pass_fds=pass_fds,
            **subprocess_run_kwargs,
        )


def change_borg_passphrase(
    repository: pathlib.Path,
    key_file: pathlib.Path,
    old_passphrase: str,
    new_passphrase: str,
) -> None:
    passphrase_command = run_borg_command(
        ["borg", "key", "change-passphrase", "--", str(repository)],
        key_file=key_file,
        passphrase=old_passphrase,
        new_passphrase=new_passphrase,
    )
    passphrase_command.check_returncode()


def change_borg_passphrase_interactively(
    repository: pathlib.Path,
    key_file: pathlib.Path,
) -> None:
    passphrase_command = run_borg_command(
        ["borg", "key", "change-passphrase", "--", str(repository)],
        key_file=key_file,
    )
    passphrase_command.check_returncode()


def copy_key_to_default(repository: pathlib.Path, key_file: pathlib.Path) -> None:
    with tempfile.NamedTemporaryFile() as temporary_file:
        exported_key_file = pathlib.Path(temporary_file.name)
        export_borg_key(
            repository=repository, output_file=exported_key_file, key_file=key_file
        )
        import_borg_key(
            repository=repository,
            input_file=exported_key_file,
        )


def copy_default_key(repository: pathlib.Path, key_file: pathlib.Path) -> None:
    with tempfile.NamedTemporaryFile() as temporary_file:
        exported_key_file = pathlib.Path(temporary_file.name)
        export_borg_key(repository=repository, output_file=exported_key_file)
        import_borg_key(
            repository=repository, input_file=exported_key_file, key_file=key_file
        )


def export_borg_key(
    repository: pathlib.Path,
    output_file: pathlib.Path,
    key_file: typing.Optional[pathlib.Path] = None,
    mode: str = "key",
) -> None:
    mode_options = {
        "key": [],
        "paper": ["--paper"],
    }[mode]
    export_command = run_borg_command(
        ["borg", "key", "export"]
        + mode_options
        + ["--", str(repository), str(output_file)],
        key_file=key_file,
    )
    export_command.check_returncode()


def import_borg_key(
    repository: pathlib.Path,
    input_file: pathlib.Path,
    key_file: typing.Optional[pathlib.Path] = None,
) -> None:
    if key_file is None:
        import_command = run_borg_command(
            ["borg", "key", "import", "--", str(repository), str(input_file)],
        )
        import_command.check_returncode()
    else:
        # TODO(strager): If the file named by $BORG_KEY_FILE does not exist, 'borg
        # key import' fails. Switch to using $BORG_KEY_FILE when this bug is fixed.
        # https://github.com/borgbackup/borg/pull/5201
        with tempfile.TemporaryDirectory() as temporary_directory:
            keys_dir = pathlib.Path(temporary_directory)
            import_command = run_borg_command(
                ["borg", "key", "import", "--", str(repository), str(input_file)],
                keys_dir=str(keys_dir),
            )
            import_command.check_returncode()
            imported_files = list(keys_dir.iterdir())
            if len(imported_files) != 1:
                raise Exception(
                    f"Expected 'borg key import' to create exactly one file, but it created {len(imported_files)}: {', '.join(imported_files)}"
                )
            imported_files[0].rename(key_file)


def get_borg_archives(
    repository: pathlib.Path,
    key_file: pathlib.Path,
    key_passphrase_file: pathlib.Path,
) -> typing.List["BorgArchive"]:
    process = run_borg_command(
        command=[
            "borg",
            "list",
            "--json",
            "--sort-by",
            "timestamp",
            "--",
            str(repository),
        ],
        key_file=key_file,
        passphrase_file=key_passphrase_file,
        stdout=subprocess.PIPE,
    )
    process.check_returncode()
    return parse_borg_list_output(json.loads(process.stdout))


class BorgArchive:
    def __init__(self, borg_list_archive: typing.Dict) -> None:
        self._data = borg_list_archive

    @property
    def name(self) -> str:
        return self._data["name"]

    @property
    def time(self) -> datetime.datetime:
        return datetime.datetime.strptime(
            self._data["time"], "%Y-%m-%dT%H:%M:%S.000000"
        )


def parse_borg_list_output(borg_list_output: typing.Dict) -> typing.List[BorgArchive]:
    return [BorgArchive(archive) for archive in borg_list_output["archives"]]
