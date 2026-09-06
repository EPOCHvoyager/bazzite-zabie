#!/bin/bash

set ${CI:+-x} -euo pipefail

OPTS=( "--setopt=tsflags=noscripts" "--setopt=install_weak_deps=True" )

PACKAGES=( \
"realtime-setup" \
"irqbalance" \
"gamemode" \
"langpacks-pt_BR" )

UNITS=( \
"irqbalance.service" \
"realtime-setup.service" \
"realtime-entsk.service" )

_install() {
	echo Installing packages from Fedora…
	dnf5 -y install \
		"${OPTS[@]}" \
		"${PACKAGES[@]}"


	rpm -V \
		"${PACKAGES[@]}"
	echo Successfully installed.
}


_setup_units() {
    echo Enabling service units…
    for u in "${UNITS[@]}"; do
        systemctl enable "$u" && \


        systemctl is-enabled "$u" || exit 1
    done
    echo Successfully enabled.
}

_install && \
_setup_units
