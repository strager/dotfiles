#!/usr/bin/env bash
set -e
set -u

# Assumption: When invoking 'man -k', ${HOME}/bin is in
# ${PATH}. If ${HOME}/bin/../man exists, this causes 'man
# -k' to add ${HOME}/bin/../man (aka ${HOME}/man) to its
# MANPATH.
whatis_path="${HOME}/man/whatis"
whatis_system_path="${HOME}/man/whatis.system"

force_generate_all=false

while [ "${#}" -ne 0 ]; do
    case "${1}" in
        --all)
            force_generate_all=true
            shift
            ;;
        *)
            printf 'error: unrecognized option: %s\n' "${1}" >&2
            exit 1
            ;;
    esac
done

old_IFS="${IFS}"
IFS=:
all_man_directories=($(man -w))
IFS="${old_IFS}"

extra_man_directories=()
for profile_dir in ${NIX_PROFILES}; do
    extra_man_directories=("${profile_dir}/share/man" "${extra_man_directories[@]:+"${extra_man_directories[@]}"}")
done

is_extra_man_directory() {
    local directory="${1}"
    for extra_man_directory in "${extra_man_directories[@]:+"${extra_man_directories[@]}"}"; do
        if [ "${extra_man_directory}" = "${directory}" ]; then
            return 0
        fi
    done
    return 1
}

system_man_directories=()
for man_directory in "${all_man_directories[@]}"; do
    if ! is_extra_man_directory "${man_directory}"; then
        system_man_directories+=("${man_directory}")
    fi
done

generate_system_whatis() {
    mkdir -p -- "$(dirname "${whatis_system_path}")"
    /usr/libexec/makewhatis -o "${whatis_system_path}" -- "${system_man_directories[@]}"
}

generate_final_whatis() {
    mkdir -p -- "$(dirname "${whatis_path}")"
    cp -- "${whatis_system_path}" "${whatis_path}"
    /usr/libexec/makewhatis -a -o "${whatis_path}" -- "${extra_man_directories[@]}"
}

if "${force_generate_all}" || ! [ -f "${whatis_system_path}" ]; then
    generate_system_whatis
fi
generate_final_whatis
