#!/bin/bash

set ${CI:+-x} -euo pipefail

PACKAGES=( "system76-scheduler" )
UNITS=( "com.system76.Scheduler.service" )

_install() {
    echo Installing package from Terra…
    dnf5 -y install \
        --enable-repo="terra" \
        "${PACKAGES[@]}"


    rpm -V \
        "${PACKAGES[@]}"
    echo Successfully installed.
}

_setup_units() {
    echo Enabling service unit…
    for u in "${UNITS[@]}"; do
        systemctl enable "$u" && \


        systemctl is-enabled "$u" || exit 1
    done
    echo Successfully enabled.
}

_install

_setup_units
