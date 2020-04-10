#!/usr/bin/env zsh

setopt err_exit
setopt pipe_fail
setopt unset

here="$(cd "$(dirname "${0}")" && pwd)"
. "${here}/testlib.zsh"

# TODO(strager): Move into ~/.zshenv.
fpath=("${here}/strager" "${fpath[@]}")
autoload -Uk sexercism

test_successful_download_changes_cwd() {
    exercism() {
        mkdir -p "${exercism_root}/cpp/hello_world"
        printf '\nDownloaded to\n' >&2
        printf '%s/cpp/hello_world\n' "${exercism_root}"
    }

    cd /
    local exercism_root="$(make_temporary_directory)"

    sexercism download --wat
    assert [ "$(pwd)" = "${exercism_root}/cpp/hello_world" ]
}

test_successful_submission_does_not_change_cwd() {
    exercism() {
        printf '\n\n' >&2
        printf '    Your solution has been submitted successfully.\n' >&2
        printf '    You can complete the exercise and unlock the next core exercise at:\n\n' >&2
        printf '    https://exercism.io/my/solutions/a9067845bda743e8bb98db8ac1f84fa2\n\n'
    }

    cd /
    local exercism_root="$(make_temporary_directory)"

    sexercism submit hello_world.c hello_world.h
    assert [ "$(pwd)" = / ]
}

test_failed_download_does_not_change_cwd() {
    exercism() {
        mkdir -p "${exercism_root}/cpp/hello_world"
        printf '\nDownloaded to\n' >&2
        printf '%s/cpp/hello_world\n' "${exercism_root}"
        return 1
    }

    cd /
    local exercism_root="$(make_temporary_directory)"

    sexercism download --wat || :
    assert [ "$(pwd)" = / ]
}

test_help_does_not_change_cwd() {
    exercism() {
        command exercism --help
    }

    cd /
    local exercism_root="$(make_temporary_directory)"

    sexercism --help
    assert [ "$(pwd)" = / ]
}

make_temporary_directory() {
    mktemp -d -t strager_test_sexercism.zsh.XXXXXX
}

run_all_tests
