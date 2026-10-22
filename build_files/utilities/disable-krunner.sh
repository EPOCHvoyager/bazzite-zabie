#!/usr/bin/env bash
. "${LIB_DIR}/error.sh"

set ${CI:+-x} -euo pipefail

KRUNNER_BIN_PATH="/usr/bin/krunner"  && readonly KRUNNER_BIN_PATH

_disable_execution () {
    assert_single_argument "$@" || { error 'Single argument required to remove execution permissions.' ; return 1 ; }

    local bin_path ;  bin_path="$1"  && readonly bin_path

    if [[ $( stat --format='%a' "${bin_path}" ) == "644" ]] ; then
        return
    else
        chmod -x -- "${bin_path}" || return
        [[ $( stat --format='%a' "${bin_path}" ) == "644" ]]
    fi
}

main () {
    _disable_execution "${KRUNNER_BIN_PATH}" || return
}

main
