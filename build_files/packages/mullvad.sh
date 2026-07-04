#!/bin/bash

set ${CI:+-x} -euo pipefail

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
