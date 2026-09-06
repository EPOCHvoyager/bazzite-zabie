#!/bin/bash

set ${CI:+-x} -euo pipefail

OPTS=( "--enable-repo=terra" \
"--setopt=tsflags=noscripts" \
"--setopt=install_weak_deps=True" )

PACKAGES=( "ananicy-cpp" )

UNITS=( "ananicy-cpp.service" )

_install() {
    echo Installing package from Terra…
    dnf5 -y install \
        "${OPTS[@]}" \
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

_install && \
_setup_units
