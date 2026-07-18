#!/bin/bash

set ${CI:+-x} -euo pipefail

_rpm_from_release() {
	local api_url ; api_url="https://api.github.com/repos/${REPO}/releases/latest"

	curl -s "$api_url" \
	| jq -r '.assets[] | select(.name | contains ("x86_64.rpm")) | .browser_download_url' \
	| head -n 1 \
	| xargs -I {} wget {} -P /tmp
}

_install_and_clean() {
	local temp_dir ; temp_dir="/tmp"
	local rpm_file ; rpm_file=$( find "${tmp_dir}" -iname "${RPM}" )

	dnf5 -y install \
		"${rpm_file}"
	rm "${rpm_file}"
}


echo Installing Heroic from latest GitHub release…

REPO="Heroic-Games-Launcher/HeroicGamesLauncher"
_rpm_from_release

RPM="Heroic-*-x86_64.rpm"
_install_and_clean


rpm -V \
	heroic

echo Successfully installed.
