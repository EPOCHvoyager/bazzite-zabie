#!/bin/bash

set ${CI:+-x} -euo pipefail

echo Installing packages from Copr…

dnf5 -y install \
	--setopt=tsflags=noscripts \
	https://download.copr.fedorainfracloud.org/results/bieszczaders/kernel-cachyos-addons/fedora-43-x86_64/10428026-ananicy-cpp/ananicy-cpp-1.2.0-1.fc43.x86_64.rpm
# TODO: Remove once there's a new successfull build on Copr
dnf5 -y install \
	--enable-repo="copr:copr.fedorainfracloud.org:bieszczaders:kernel-cachyos-addons" \
	cachyos-ananicy-rules
	#ananicy-cpp

# This package needs to be rebuilt for specific versions of Plasma.
dnf5 -y copr enable \
	infinality/kwin-effects-better-blur-dx
dnf5 -y install \
	kwin-effects-better-blur-dx
dnf5 -y copr disable \
	infinality/kwin-effects-better-blur-dx

# Pull from the official Copr, as Terra is often out of date
dnf5 -y copr enable \
	codifryed/CoolerControl
dnf5 -y install \
	coolercontrol \
	coolercontrold
dnf5 -y copr disable \
	codifryed/CoolerControl

# Drop-in replacement for Krunner
dnf5 -y copr enable \
	scujas/plasma-applet-appgrid
dnf5 -y install \
	plasma-applet-appgrid
dnf5 -y copr disable \
	scujas/plasma-applet-appgrid


rpm -V \
    ananicy-cpp \
    cachyos-ananicy-rules \
    kwin-effects-better-blur-dx \
    coolercontrol \
    coolercontrold \
    plasma-applet-appgrid

echo Successfully installed.


echo Enabling service units…

systemctl enable ananicy-cpp.service
systemctl enable coolercontrold.service


systemctl is-enabled ananicy-cpp.service
systemctl is-enabled coolercontrold.service

echo Successfully enabled.
