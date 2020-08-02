import datetime
import pathlib
import platform
import sys
import typing


class Site(typing.NamedTuple):
    name: str
    slow_backup_frequency: datetime.timedelta
    backups_directory: pathlib.Path
    keys_directory: pathlib.Path

    @property
    def repository(self) -> pathlib.Path:
        return self.backups_directory / self.name

    @property
    def archive_key_file(self) -> pathlib.Path:
        return self.keys_directory / f"{self.name}-archive.borgkey"

    @property
    def archive_key_passphrase_file(self) -> pathlib.Path:
        return self.keys_directory / f"{self.name}-archive.borgkey.passphrase"

    @property
    def exported_key_file(self) -> pathlib.Path:
        return self.repository / "exported-borg-key"

    @property
    def paper_key_file(self) -> pathlib.Path:
        return self.repository / "borg-key.txt"

    @property
    def patterns_file(self) -> pathlib.Path:
        return pathlib.Path(__file__).parent / ".." / f"{self.name}.lst"


straddler_site = Site(
    name="straddler",
    slow_backup_frequency=datetime.timedelta(days=7),
    backups_directory=pathlib.PosixPath("/Users/strager/borg-backups"),
    keys_directory=pathlib.PosixPath("/Users/strager/borg-keys"),
)

sites = {
    "straglum": Site(
        name="straglum",
        slow_backup_frequency=datetime.timedelta(days=7),
        backups_directory=pathlib.PosixPath("/home/strager/borg-backups"),
        keys_directory=pathlib.PosixPath("/home/strager/borg-keys"),
    ),
    "straddler.lan": straddler_site,
    "straddler.local": straddler_site,
    "staler": Site(
        name="staler",
        slow_backup_frequency=datetime.timedelta(days=28),
        backups_directory=pathlib.PosixPath(
            "/cygdrive/c/Users/strager/Documents/borg-backups"
        ),
        keys_directory=pathlib.PosixPath(
            "/cygdrive/c/Users/strager/Documents/borg-keys"
        ),
    ),
}


def get_site_for_current_machine() -> Site:
    return get_site_for_hostname(platform.node())


def get_site_for_hostname(hostname: str) -> Site:
    site = sites.get(hostname)
    if site is None:
        sys.stderr.write(f"error: unrecognized host: {hostname}\n")
        exit(1)
    return site
