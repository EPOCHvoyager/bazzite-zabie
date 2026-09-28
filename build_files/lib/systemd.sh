#!/usr/bin/env bash
. "${LIB_DIR}/parse.sh"

systemd::enable_units () {
    assert_arguments_passed "$@" || { printf 'No arguments provided for service unit enabling.\n' >&2 && return 1 ; }
    local units ; units=( "$@" ) && readonly units

    for u in "${units[@]}"; do
        echo "Enabling unit ${u}…" && \
        systemctl enable "$u" || return
        systemctl is-enabled "$u" \
        && echo "Successfully enabled." || return
    done
}
