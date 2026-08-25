#!/bin/bash

set ${CI:+-x} -euo pipefail

_get_from_copr () {
	dnf5 -y copr enable \
		"${COPR}"
	if [[ -z "${REPLACE}" ]]; then
		dnf5 -y install \
			"${PACKAGES[@]}"
	else
		dnf5 -y install \
			--allowerasing \
			"${PACKAGES[@]}"
		env -u REPLACE
	fi
	dnf5 -y copr disable \
		"${COPR}"


	rpm -V \
		"${PACKAGES[@]}"
	dnf5 repolist --disabled | grep -q "${COPR//[!0-9a-zA-Z.-]/:}"
}

echo Installing packages from Copr…

# This Copr repository is included in the base image. Thus, enable it ephemerally with --enable-repo, passing the repo ID.
COPR="copr:copr.fedorainfracloud.org:bieszczaders:kernel-cachyos-addons"
dnf5 -y install \
	--enable-repo="${COPR}" \
	scx-manager


rpm -V \
	scx-manager
dnf5 repolist --disabled | grep -q "${COPR}"

# Use Piotr's Copr, as it is more actively maintained than the one pulled in the base image.
COPR="sirlucjan/scx-scheds-cargo"
PACKAGES=( "scx-scheds-git" "scx-tools-git" )
REPLACE=1
_get_from_copr

# This package needs to be rebuilt for specific versions of Plasma.
COPR="infinality/kwin-effects-better-blur-dx"
PACKAGES=( "kwin-effects-better-blur-dx-2.5.1-1.20260808_061638gite8475d0.fc44" )
_get_from_copr

# Pull from the official Copr, as Terra is often out of date.
COPR="codifryed/CoolerControl"
PACKAGES=( "coolercontrol" "coolercontrold" )
_get_from_copr

# Chromium-based web browser.
COPR="imput/helium"
PACKAGES=( "helium-bin" )
_get_from_copr

echo Successfully installed.

echo Enabling service units…

systemctl enable coolercontrold.service


systemctl is-enabled coolercontrold.service

echo Successfully enabled.
