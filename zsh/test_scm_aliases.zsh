#!/usr/bin/env zsh

setopt err_exit
setopt pipe_fail
setopt unset

# HACK(strager): Work around the following message from Travis CI:
# /nix/store/cinw572b38aln37glr0zb8lxwrgaffl4-bash-4.4-p23/bin/bash: warning: setlocale: LC_ALL: cannot change locale (en_US.UTF-8)
export LC_ALL=C

here="$(cd "$(dirname "${0}")" && pwd)"
. "${here}/testlib.zsh"

test_scm_aliases_fail_if_not_in_checkout() {
    set_up
    local exit_code=0
    gs >test_stdout 2>test_stderr || exit_code="${?}"
    assert [ "${exit_code}" -ne 0 ]
    assert [ "$(cat test_stdout)" = '' ]
    assert [ "$(cat test_stderr)" = 'gs: fatal: could not determine SCM' ]
}

test_scm_status_returns_status_in_bzr_checkout() {
    set_up
    bzr init
    touch somefile
    local exit_code=0
    gs >.bzr/test_output 2>&1 || exit_code="${?}"
    cat .bzr/test_output
    assert [ "${exit_code}" -eq 0 ]
    assert [ "$(cat .bzr/test_output)" = $'unknown:\n  somefile' ]
}

test_scm_status_returns_status_in_git_checkout() {
    set_up
    git init
    touch somefile
    local exit_code=0
    gs >.git/test_output 2>&1 || exit_code="${?}"
    cat .git/test_output
    assert [ "${exit_code}" -eq 0 ]
    assert [ "$(cat .git/test_output)" = $'## No commits yet on master\n?? somefile' ]
}

test_scm_status_returns_status_in_hg_checkout() {
    set_up
    hg init
    touch somefile
    local exit_code=0
    gs >.hg/test_output 2>&1 || exit_code="${?}"
    cat .hg/test_output
    assert [ "${exit_code}" -eq 0 ]
    assert [ "$(cat .hg/test_output)" = $'? somefile' ]
}

set_up() {
    if ! [[ -o interactive ]]; then
        assert false 'This test must be run in zsh interactive mode'
    fi

    local temp_dir="$(make_temporary_directory)"
    cd "${temp_dir}"

    export HGPLAIN=1
}

make_temporary_directory() {
    mktemp -d -t strager_test_scm_aliases.zsh.XXXXXX
}

force_zsh_interactive
run_all_tests
