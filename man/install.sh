#!/bin/sh

manpath_file="${OUT}/.manpath"
if ! [ -e "${manpath_file}" ]; then
  printf 'MANDB_MAP %s/.nix-profile/share/man %s/man\n' "${OUT}" "${OUT}" >"${manpath_file}"
fi
