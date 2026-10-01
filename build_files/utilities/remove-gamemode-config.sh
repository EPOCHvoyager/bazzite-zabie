#!/usr/bin/env bash
. "${LIB_DIR}/parse.sh"

set ${CI:+-x} -euo pipefail

CONFIG_PATH="/usr/share/gamemode/gamemode.ini"

_remove_default_ini () {
    assert_single_argument "$@" || {
        printf '%s:%s: Single argument required to remove default gamemode configuration.\n' \
        "${BASH_SOURCE[0]##*/}" "${FUNCNAME[0]}" >&2
        return 1
    }

    local ini_path ;  ini_path="$1"  && readonly ini_path

    if [[ ! -f "${ini_path}" ]] ; then
        return
    else
        rm "${ini_path}" || return
        [[ ! -f "${ini_path}" ]]
    fi
}

main () {
    echo "Removing Feral gamemode stock configuration…" && \
    _remove_default_ini "${CONFIG_PATH}" || return \
    && echo "Successfully removed."
}

main
