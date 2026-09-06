#!/bin/bash

set ${CI:+-x} -euo pipefail

PACKAGES=( "system76-scheduler" )
UNITS=( "com.system76.Scheduler.service" )

_install() {
    dnf5 -y install \
        --enable-repo="terra" \
        "${PACKAGES[@]}"


    rpm -V \
        "${PACKAGES[@]}"
}

_setup_units() {
    for u in "${UNITS[@]}"; do
        systemctl enable "$u" && \


        systemctl is-enabled "$u" || exit 1
    done
}

echo Installing package from Terra…

_install

echo Successfully installed.

echo Enabling service unit…

_setup_units

echo Successfully enabled.
