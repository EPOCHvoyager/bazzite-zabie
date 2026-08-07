#!/bin/bash

set ${CI:+-x} -euo pipefail

_get_from_copr () {
	dnf5 -y copr enable \
		"${COPR}"
	dnf5 -y install \
		"${PACKAGES[@]}"
	dnf5 -y copr disable \
		"${COPR}"


	rpm -V \
		"${PACKAGES[@]}"
	dnf5 repolist --disabled | grep -q "${COPR//[!0-9a-zA-Z.-]/:}"
}


echo Installing packages from Copr…

# This package needs to be rebuilt for specific versions of Plasma.
COPR="infinality/kwin-effects-better-blur-dx"
PACKAGES=( "kwin-effects-better-blur-dx" )
_get_from_copr

# A Spotlight-like application launcher for Plasma.
COPR="scujas/plasma-applet-appgrid"
PACKAGES=( "plasma-applet-appgrid" )
_get_from_copr

# Pull from the official Copr, as Terra is often out of date.
COPR="codifryed/CoolerControl"
PACKAGES=( "coolercontrol" "coolercontrold" )
_get_from_copr

echo Successfully installed.


echo Enabling service units…

systemctl enable coolercontrold.service


systemctl is-enabled coolercontrold.service

echo Successfully enabled.
