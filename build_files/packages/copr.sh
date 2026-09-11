#!/bin/bash

set ${CI:+-x} -euo pipefail

_get_from_copr () {
	dnf5 -y copr enable \
		"${COPR}"
	dnf5 -y install \
		${OPTS:+"${OPTS[@]}"} \
		"${PACKAGES[@]}"
	dnf5 -y copr disable \
		"${COPR}"


	rpm -V \
		"${PACKAGES[@]}"
	dnf5 repolist --disabled | grep -q "${COPR//[!0-9a-zA-Z.-]/:}"
	unset -v OPTS COPR PACKAGES
}

echo Installing packages from Copr…

COPR="bieszczaders/kernel-cachyos-addons"
PACKAGES=( "scx-manager" )
_get_from_copr

# Use Piotr's Copr, as it is more actively maintained than the one pulled in the base image.
COPR="sirlucjan/scx-scheds-cargo"
PACKAGES=( "scx-scheds-git" "scx-tools-git" )
OPTS=( "--allowerasing" )
_get_from_copr

# This package needs to be rebuilt for specific versions of Plasma.
COPR="infinality/kwin-effects-better-blur-dx"
PACKAGES=( "kwin-effects-better-blur-dx" )
_get_from_copr

echo Successfully installed.
