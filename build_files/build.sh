#!/usr/bin/env bash

set ${CI:+-x} -euo pipefail

LIB_DIR="/ctx/lib" && readonly LIB_DIR ; export LIB_DIR
. "${LIB_DIR}/parse.sh"

UTILITY_DIR="/ctx/utilities" && readonly UTILITY_DIR
UTILITY_SCRIPTS=( \
    "${UTILITY_DIR}/copy-files.sh" \
    "${UTILITY_DIR}/install-packages.sh" \
    "${UTILITY_DIR}/remove-gamemode-config.sh" \
) && readonly UTILITY_SCRIPTS

_run_utility_scripts () {
    assert_arguments_passed "$@" || { printf 'No utility scripts provided.\n' >&2 && return 1 ; }
    local -a scripts ; scripts=( "$@" ) && readonly scripts

    for script in "${scripts[@]}"; do
        echo "Running utility script ${script##*/}…" && "$script" || return
    done \
    && echo "Finished running utility scripts."
}

main () {
    _run_utility_scripts "${UTILITY_SCRIPTS[@]}" || return
}

main
