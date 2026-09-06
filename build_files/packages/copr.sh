#!/bin/bash

set ${CI:+-x} -euo pipefail

_get_from_copr () {
	dnf5 -y copr enable \
		"${COPR}"
	dnf5 -y install \
		${OPTS:+"${OPTS[@]}"} \
		"${PACKAGES[@]}"
	dnf5 -y copr disable \
		"${COPR}"


	rpm -V \
		"${PACKAGES[@]}"
	dnf5 repolist --disabled | grep -q "${COPR//[!0-9a-zA-Z.-]/:}"
	unset OPTS ; unset COPR ; unset PACKAGES
}

_setup_units() {
	echo Enabling service unit…
    for u in "${UNITS[@]}"; do
        systemctl enable "$u" && \


        systemctl is-enabled "$u" || exit 1
    done
    unset UNITS
    echo Successfully enabled.
}

echo Installing packages from Copr…

COPR="bieszczaders/kernel-cachyos-addons"
PACKAGES=( "scx-manager" )
_get_from_copr

# Use Piotr's Copr, as it is more actively maintained than the one pulled in the base image.
COPR="sirlucjan/scx-scheds-cargo"
PACKAGES=( "scx-scheds-git" "scx-tools-git" )
OPTS=( "--allowerasing" )
_get_from_copr

# This package needs to be rebuilt for specific versions of Plasma.
COPR="infinality/kwin-effects-better-blur-dx"
PACKAGES=( "kwin-effects-better-blur-dx-2.5.1-1.20260808_061638gite8475d0.fc44" )
_get_from_copr

# Pull from the official Copr, as Terra is often out of date.
COPR="codifryed/CoolerControl"
PACKAGES=( "coolercontrol" )
UNITS=( "coolercontrold.service" )
OPTS=( "--setopt=install_weak_deps=True" )
_get_from_copr && \
_setup_units

echo Successfully installed.
