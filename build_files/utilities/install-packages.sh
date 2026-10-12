#!/usr/bin/env bash
. "${LIB_DIR}/error.sh"

set ${CI:+-x} -euo pipefail

PACKAGE_DIR="/ctx/packages"  && readonly PACKAGE_DIR

shopt -s nullglob ;  SCRIPTS=( "${PACKAGE_DIR}"/*.sh )  && readonly SCRIPTS ; shopt -u nullglob

_run_package_scripts () {
    assert_arguments_passed "$@" || { error 'No scripts provided for package script execution.' ; return 1 ; }

    local -a scripts ;  scripts=( "$@" )  && readonly scripts

    local scripts_ran ;  scripts_ran=0

    for script in "${scripts[@]}"; do
        echo "Running package installation script ${script##*/}…" && \
        "$script" && (( ++scripts_ran )) || return
    done
    readonly scripts_ran

    _assert_all_scripts_ran "${scripts_ran}" || return
}

_assert_all_scripts_ran () {
    assert_single_argument "$@" || { error 'Single argument required to assert execution of all package scripts.' ; return 1 ; }
    local scripts_ran ;  scripts_ran=$1  && readonly scripts_ran

    local script_count ;  script_count=${#SCRIPTS[@]}  && readonly script_count

    (( ${scripts_ran} == ${script_count} )) && echo "Package installation done." || return
}

main () {
    _run_package_scripts "${SCRIPTS[@]}" || return
}

main
