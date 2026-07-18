#!/bin/bash

set ${CI:+-x} -euo pipefail

_get_rpm_from_release() {

	local api_url ; api_url="https://api.github.com/repos/${REPO}/releases/latest"

	curl -s "$api_url" \
	| jq -r '.assets[] | select(.name | contains ("x86_64.rpm")) | .browser_download_url' \
	| head -n 1 \
	| xargs -I {} wget {} -P /tmp
}

echo Installing Heroic from latest GitHub release…

REPO="Heroic-Games-Launcher/HeroicGamesLauncher"
_get_rpm_from_release

RPM="Heroic-*-x86_64.rpm"
dnf5 -y install \
	/tmp/"${RPM}"
rm /tmp/"${RPM}"


rpm -V \
	heroic

echo Successfully installed.


echo Installing Latte Dock NG from latest GitHub release…

REPO="ruizhi-lab/latte-dock-ng"
_get_rpm_from_release

RPM="latte-dock-ng-*.x86_64.rpm"
dnf5 -y install \
	/tmp/"${RPM}"
rm /tmp/"${RPM}"


rpm -V \
	latte-dock-ng

echo Successfully installed.
