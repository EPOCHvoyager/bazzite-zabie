#!/usr/bin/env bash
. "${LIB_DIR}/parse.sh"

set ${CI:+-x} -euo pipefail

SYSTEM_FILES_PATH="/ctx/system_files"

_copy_to_root () {
    assert_single_argument "$@" || {
        printf '%s:%s: Single argument required for root file copy.\n' \
        "${BASH_SOURCE[0]##*/}" "${FUNCNAME[0]}" >&2
        return 1
    }

    local source_path ;  source_path="$1"  && readonly source_path
    cp -avf "${source_path}"/. / || return
}

main () {
    _copy_to_root "${SYSTEM_FILES_PATH}" || return
}

main
