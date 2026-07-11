#!/bin/bash

set ${CI:+-x} -euo pipefail

RELEASE="$(rpm -E '%fedora')"

echo Installing packages from Open Build Service…

dnf5 config-manager addrepo \
	--from-repofile=https://download.opensuse.org/repositories/home:luisbocanegra/Fedora_"${RELEASE}"/home:luisbocanegra.repo
dnf5 -y install \
	plasma-panel-colorizer \
	plasma-panel-spacer-extended \
	kde-material-you-colors
dnf5 config-manager disable \
	home_luisbocanegra

dnf5 config-manager addrepo \
	--from-repofile=https://download.opensuse.org/repositories/home:paulmcauley/Fedora_"${RELEASE}"/home:paulmcauley.repo
dnf5 -y install \
	klassy
dnf5 config-manager disable \
	home_paulmcauley


rpm -V \
	plasma-panel-colorizer \
	plasma-panel-spacer-extended \
	klassy

echo Successfully installed.
