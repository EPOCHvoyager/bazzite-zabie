#!/usr/bin/env bash
. "${LIB_DIR}/parse.sh"

systemd::enable_units () {
    assert_arguments_passed "$@" || {
        printf '%s:%s: No arguments provided for enabling service units.\n' \
        "${BASH_SOURCE[0]##*/}" "${FUNCNAME[0]}" >&2
        return 1
    }

    local units ;  units=( "$@" )  && readonly units
    local unit

    for unit in "${units[@]}"; do
        echo "Enabling unit ${unit}…" && \
        systemctl enable "$unit" || return
        systemctl is-enabled "$unit" \
        && echo "Successfully enabled." || return
    done
}
