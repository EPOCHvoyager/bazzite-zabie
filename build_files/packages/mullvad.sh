#!/bin/bash

echo Installing Mullvad VPN software…

dnf5 config-manager addrepo \
	--from-repofile=https://repository.mullvad.net/rpm/stable/mullvad.repo
dnf5 -y install \
	mullvad-vpn
dnf5 config-manager disable \
	mullvad-stable


rpm -V \
    mullvad-vpn

echo Successfully installed.


echo Enabling service units…

systemctl enable mullvad-daemon.service
systemctl enable mullvad-early-boot-blocking.service


systemctl is-enabled mullvad-daemon.service
systemctl is-enabled mullvad-early-boot-blocking.service

echo Successfully enabled.
