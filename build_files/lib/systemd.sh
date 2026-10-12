#!/usr/bin/env bash
. "${LIB_DIR}/error.sh"

systemd::enable_units () {
    assert_arguments_passed "$@" || error 'No arguments provided for enabling service units.'

    local units ;  units=( "$@" )  && readonly units
    local unit

    for unit in "${units[@]}"; do
        echo "Enabling unit ${unit}…" && \
        systemctl enable "$unit" || return
        systemctl is-enabled "$unit" \
        && echo "Successfully enabled." || return
    done
}
