#!/usr/bin/env bash
. "${LIB_DIR}/parse.sh"

set ${CI:+-x} -euo pipefail

error () {
    assert_single_argument "$@" || {
        printf '%s:%s: Error message required.\n' \
        "${BASH_SOURCE[1]##*/}" "${FUNCNAME[1]}" >&2
        return 1
    }

    local error_msg ;  error_msg="$1"  ; readonly error_msg

    printf '%s:%s: %s.\n' \
    "${BASH_SOURCE[1]##*/}" \
    "${FUNCNAME[1]}" \
    "${error_msg}" \
    >&2
}
