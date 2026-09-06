#!/bin/bash

set ${CI:+-x} -euo pipefail

REPO_URL="https://repository.mullvad.net/rpm/stable/mullvad.repo"
PACKAGE="mullvad-vpn"
REPO_ID="mullvad-stable"
UNITS=( "mullvad-daemon.service" "mullvad-early-boot-blocking.service" )
EXCLUDE_BIN="/usr/bin/mullvad-exclude"

_install() {
	echo Installing Mullvad VPN software…
	dnf5 config-manager addrepo \
		--from-repofile="${REPO_URL}"
	dnf5 -y install \
		--setopt=tsflags=noscripts \
		"${PACKAGE}"
	dnf5 config-manager disable \
		"${REPO_ID}"


	rpm -V \
		"${PACKAGE}"
	dnf5 repolist --disabled | grep -q "${REPO_ID}"
	echo Successfully installed.
}

_add_permission() {
	echo Adding permissions…
	# This is normally handled by an install scriptlet.
	chmod u+s "${EXCLUDE_BIN}"


	[[ $( stat --format='%a' "${EXCLUDE_BIN}" ) = "4755" ]]
	echo Successfully added.
}

_unit_setup() {
	echo Enabling service units…
    for u in "${UNITS[@]}"; do
        systemctl enable "$u" && \


        systemctl is-enabled "$u" || exit 1
    done
	echo Successfully enabled.
}

_install

_add_permission

_unit_setup

