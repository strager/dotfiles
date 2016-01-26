#!/bin/sh

defaults=/usr/bin/defaults
if ! [ -e "${defaults}" ]; then
    echo "defaults not installed; ignoring" >&2
    exit 0
fi

domain=com.googlecode.iterm2

backup_path=$(mktemp /tmp/iterm_config_backup.XXXXXXXX)
"${defaults}" export "${domain}" "${backup_path}"
echo "note: restore old settings with:"
echo "      ${defaults} import ${domain} ${backup_path}"

"${defaults}" import "${domain}" \
    "${HEREP}/com.googlecode.iterm2.plist"
echo "note: iterm config is not automatically updated"
