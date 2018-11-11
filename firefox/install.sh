#!/bin/sh

find_firefox_profile() {
    all_profiles_path="$OUT/Library/Application Support/Firefox/Profiles"
    profile_path=
    old_IFS="${IFS}"
    IFS=
    for cur_profile_path in ${all_profiles_path}/*; do
        if ! [ -d "${cur_profile_path}" ]; then
            continue
        fi
        if [ -n "${profile_path}" ]; then
            printf 'warning: too many Firefox profiles; ignoring Firefox\n' >&2
            IFS="${old_IFS}"
            return
        fi
        profile_path="${cur_profile_path}"
    done
    IFS="${old_IFS}"
    if [ -z "${profile_path}" ]; then
        printf 'warning: could not find any Firefox profiles; ignoring Firefox\n' >&2
        return
    fi
    printf '%s' "${profile_path}"
    return
}

profile_path="$(find_firefox_profile)"
if [ -n "${profile_path}" ]; then
    mkdir -p "${profile_path}/chrome"
    "$S" "$HEREP/userChrome.css" "${profile_path}/chrome/userChrome.css"
fi
