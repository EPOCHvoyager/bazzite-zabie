#!/bin/bash

set ${CI:+-x} -euo pipefail

echo Installing Mullvad VPN software…

REPO_URL="https://repository.mullvad.net/rpm/stable/mullvad.repo"
PACKAGE="mullvad-vpn"
REPO_ID="mullvad-stable"

dnf5 config-manager addrepo \
	--from-repofile="${REPO}"
dnf5 -y install \
	--setopt=tsflags=noscripts \
	"${PACKAGE}"
dnf5 config-manager disable \
	"${REPO_ID}"


rpm -V \
    "${REPO_ID}"

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
