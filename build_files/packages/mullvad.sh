#!/bin/bash

set ${CI:+-x} -euo pipefail

echo Installing Mullvad VPN software…

dnf5 config-manager addrepo \
	--from-repofile=https://repository.mullvad.net/rpm/stable/mullvad.repo
dnf5 -y install \
	--setopt=tsflags=noscripts \
	mullvad-vpn
dnf5 config-manager disable \
	mullvad-stable


rpm -V \
    mullvad-vpn

echo Successfully installed.


echo Adding permissions…

# This is normally handled by an install scriptlet.
chmod u+s "/usr/bin/mullvad-exclude"


[[ $( stat --format='%a' /usr/bin/mullvad-exclude ) = "4755" ]]

echo Successfully added.


echo Enabling service units…

systemctl enable mullvad-daemon.service
systemctl enable mullvad-early-boot-blocking.service


systemctl is-enabled mullvad-daemon.service
systemctl is-enabled mullvad-early-boot-blocking.service

echo Successfully enabled.
