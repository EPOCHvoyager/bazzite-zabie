#!/bin/bash

set ${CI:+-x} -euo pipefail

_get_from_obs () {
	local release ; release="$(rpm -E '%fedora')"
	local repo_file ; repo_file="https://download.opensuse.org/repositories/${REPO}/Fedora_${release}/${REPO}.repo"

	dnf5 config-manager addrepo \
		--from-repofile="${repo_file}"
	dnf5 -y install \
		"${PACKAGES}"
	dnf5 config-manager disable \
		"${REPO//[!0-9a-zA-Z.-]/_}"
}


echo Installing packages from Open Build Service…

REPO="home:luisbocanegra"
PACKAGES="plasma-panel-colorizer plasma-panel-spacer-extended kde-material-you-colors"
_get_from_obs

REPO="home:paulmcauley"
PACKAGES="klassy"
_get_from_obs


rpm -V \
	plasma-panel-colorizer \
	plasma-panel-spacer-extended \
	kde-material-you-colors \
	klassy

echo Successfully installed.
