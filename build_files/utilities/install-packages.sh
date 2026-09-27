#!/usr/bin/env bash
. "${LIB_DIR}"/parse.sh

set ${CI:+-x} -euo pipefail

PACKAGE_DIR="/ctx/packages" && readonly PACKAGE_DIR

shopt -s nullglob ; SCRIPTS=( "${PACKAGE_DIR}"/*.sh ) && readonly SCRIPTS ; shopt -u nullglob

_run_package_scripts () {
    assert_arguments_passed "$@" || { printf 'No scripts provided for package installation.\n' >&2 && return 1 ; }
    local -a scripts ; scripts=( "$@" ) && readonly scripts

    local scripts_ran ; scripts_ran=0

    echo Installing packages…

    for script in "${scripts[@]}"; do
        "$script" && (( ++scripts_ran )) || return
    done
    readonly scripts_ran
    _assert_all_scripts_ran "${scripts_ran}"

    echo Package installation done.
}

_assert_all_scripts_ran () {
    assert_single_argument "$@" || { printf 'Single argument required to assert execution of all package scripts.\n' >&2 && return 1 ; }
    local scripts_ran ; scripts_ran=$1 && readonly scripts_ran

    local script_count ; script_count=${#SCRIPTS[@]} && readonly script_count

    (( ${scripts_ran} == ${script_count} )) || return
}

_run_package_scripts "${SCRIPTS[@]}"
