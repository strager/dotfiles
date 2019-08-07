#!/bin/sh

dconf=/usr/bin/dconf
if ! [ -e "${dconf}" ]; then
    echo "dconf not installed; ignoring" >&2
    return
fi

dconf_dir=/org/gnome/terminal/

backup_path=$(mktemp /tmp/gnome-terminal_config_backup.XXXXXXXX)
"${dconf}" dump "${dconf_dir}" >"${backup_path}"
echo "note: restore old settings with:"
echo "      ${dconf} load ${dconf_dir} <${backup_path}"

"${dconf}" load "${dconf_dir}" <"${HEREP}/gnome-terminal.ini"
echo "note: gnome-terminal config is not automatically updated"
