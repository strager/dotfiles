import pathlib
import platform
import sys
import typing


class Site(typing.NamedTuple):
    name: str
    backed_up_directory: str
    local_directory: str
    nas_sftp_directory: str
    ssh_key_file: str
    ssh_known_hosts_file: str

    @property
    def source_ignore_file(self) -> pathlib.Path:
        return pathlib.Path(__file__).parent / ".." / f"kopiaignore-{self.name}"


sites = [
    Site(
        name="strapurp",
        backed_up_directory="/home/strager",
        local_directory="/home/strager/backups/strapurp/",
        nas_sftp_directory="homes/strager/backups/strapurp/",
        ssh_key_file="/home/strager/.ssh/id_rsa",
        ssh_known_hosts_file="/home/strager/.ssh/known_hosts",
    ),
]


def get_site_for_current_machine() -> Site:
    return get_site_for_hostname(platform.node())


def get_site_for_hostname(hostname: str) -> Site:
    for site in sites:
        if site.name == hostname:
            return site
    sys.stderr.write(f"error: unrecognized host: {hostname}\n")
    exit(1)
