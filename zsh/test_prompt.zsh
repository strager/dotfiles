#!/usr/bin/env zsh

setopt err_exit
setopt pipe_fail
setopt unset

here="$(cd "$(dirname "${0}")" && pwd)"
. "${here}/testlib.zsh"

# TODO(strager): Move into ~/.zshenv.
fpath=("${here}/strager" "${fpath[@]}")
autoload -Uk strager_prompt_cwd

test_cwd_of_root_is_slash() {
    cd /
    assert [ "$(strager_prompt_cwd)" = / ]
}

test_cwd_of_home_is_tilde() {
    cd "${HOME}"
    assert [ "$(strager_prompt_cwd)" = '~' ]
}

test_cwd_of_rooted_directory_has_truncated_leading_components() {
    local temp_dir="$(make_temporary_directory_in_root)"
    mkdir -p "${temp_dir}/component/another_component/dir"
    cd "${temp_dir}/component/another_component/dir"

    assert leading_components_are_truncated "$(strager_prompt_cwd)"
    assert [ "$(strager_prompt_cwd)" '=~' '/c/a/d' ]
}

test_cwd_of_rooted_directory_has_full_final_component() {
    local temp_dir="$(make_temporary_directory_in_root)"
    mkdir -p "${temp_dir}/leading_component/final_component"
    cd "${temp_dir}/leading_component/final_component"

    assert [ "$(strager_prompt_cwd)" '=~' '/final_component$' ]
}

test_cwd_of_directory_in_home_has_truncated_leading_components() {
    local temp_dir="$(make_temporary_directory_in_home)"
    mkdir -p "${temp_dir}/component/another_component/dir"
    cd "${temp_dir}/component/another_component/dir"

    assert leading_components_are_truncated "$(strager_prompt_cwd)"
    assert [ "$(strager_prompt_cwd)" '=~' '/c/a/d' ]
}

test_cwd_of_directory_in_home_starts_with_tilde() {
    local temp_dir="$(make_temporary_directory_in_home)"
    mkdir -p "${temp_dir}/component/another_component/dir"
    cd "${temp_dir}/component/another_component/dir"

    assert [ "$(strager_prompt_cwd)" '=~' '^~/' ]
}

make_temporary_directory_in_root() {
    TMPDIR=/tmp mktemp -d -t strager_test_prompt.zsh.XXXXXX
}

make_temporary_directory_in_home() {
    local cache_home="${XDG_CACHE_HOME-${HOME}/.cache}"
    mkdir -p "${cache_home}"
    mktemp -d "${cache_home}/strager_test_prompt.zsh.XXXXXX"
}

leading_components_are_truncated() {
    local path="${1}"
    [ "${path}" '=~' '^/?([^/]/)*[^/]+/?$' ]
}

run_all_tests
