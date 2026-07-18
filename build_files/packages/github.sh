#!/bin/bash

set ${CI:+-x} -euo pipefail

_get_rpm_from_release() {
	local api_url ; api_url="https://api.github.com/repos/${REPO}/releases/latest"

	curl -s "$api_url" \
	| jq -r '.assets[] | select(.name | contains ("x86_64.rpm")) | .browser_download_url' \
	| head -n 1 \
	| xargs -I {} wget {} -P /tmp
}

_install_and_clean() {
	local temp_dir ; temp_dir="/tmp"

	dnf5 -y install \
		"${temp_dir}"/${RPM}
	rm "${temp_dir}"/${RPM}
}


echo Installing Heroic from latest GitHub release…

REPO="Heroic-Games-Launcher/HeroicGamesLauncher"
_get_rpm_from_release

RPM="Heroic-*-x86_64.rpm"
_install_and_clean


rpm -V \
	heroic

echo Successfully installed.
