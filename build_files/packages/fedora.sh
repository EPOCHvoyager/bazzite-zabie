#!/bin/bash

echo Installing packages from Fedora…

dnf5 -y install \
	realtime-setup \
	irqbalance
dnf5 -y install \
	--setopt=install_weak_deps=True \
	langpacks-pt_BR


rpm -V \
    realtime-setup \
    irqbalance \
    langpacks-pt_BR

echo Successfully installed.


echo Enabling service units…

systemctl enable realtime-setup.service
systemctl enable realtime-entsk.service
systemctl enable irqbalance.service


systemctl is-enabled realtime-setup.service
systemctl is-enabled realtime-entsk.service
systemctl is-enabled irqbalance.service

echo Successfully enabled.
