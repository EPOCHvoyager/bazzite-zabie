#!/bin/bash

set ${CI:+-x} -euo pipefail

echo Installing packages from Fedora…

dnf5 -y install \
	--setopt=tsflags=noscripts \
	irqbalance
dnf5 -y install \
	realtime-setup
dnf5 -y install \
	--setopt=install_weak_deps=True \
	langpacks-pt_BR


rpm -V \
    realtime-setup \
    irqbalance \
    langpacks-pt_BR

echo Successfully installed.


echo Enabling service units…

systemctl enable irqbalance.service
systemctl enable realtime-setup.service
systemctl enable realtime-entsk.service


systemctl is-enabled irqbalance.service
systemctl is-enabled realtime-setup.service
systemctl is-enabled realtime-entsk.service

echo Successfully enabled.
