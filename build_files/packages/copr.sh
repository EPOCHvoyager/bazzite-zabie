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
	dnf5 repolist --disabled | grep -q "${REPO}"
}


echo Installing packages from Copr…

dnf5 -y install \
	--setopt=tsflags=noscripts \
	https://download.copr.fedorainfracloud.org/results/bieszczaders/kernel-cachyos-addons/fedora-43-x86_64/10428026-ananicy-cpp/ananicy-cpp-1.2.0-1.fc43.x86_64.rpm
# TODO: Remove once there's a new successful build on Copr
dnf5 -y install \
	--enable-repo="copr:copr.fedorainfracloud.org:bieszczaders:kernel-cachyos-addons" \
	cachyos-ananicy-rules
	#ananicy-cpp


rpm -V \
    ananicy-cpp \
    cachyos-ananicy-rules
dnf5 repolist --disabled | grep -q "copr:copr.fedorainfracloud.org:bieszczaders:kernel-cachyos-addons"

# This package needs to be rebuilt for specific versions of Plasma.
COPR="infinality/kwin-effects-better-blur-dx"
PACKAGES=( "kwin-effects-better-blur-dx-2.5.1-1.20260708_061726gite8475d0.fc44" )
_get_from_copr

# A Spotlight-like application launcher for Plasma
COPR="scujas/plasma-applet-appgrid"
PACKAGES=( "plasma-applet-appgrid" )
_get_from_copr

# Pull from the official Copr, as Terra is often out of date
COPR="codifryed/CoolerControl"
PACKAGES=( "coolercontrol" "coolercontrold" )
_get_from_copr

echo Successfully installed.


echo Enabling service units…

systemctl enable ananicy-cpp.service
systemctl enable coolercontrold.service


systemctl is-enabled ananicy-cpp.service
systemctl is-enabled coolercontrold.service

echo Successfully enabled.
