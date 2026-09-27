#!/usr/bin/env bash
. "${LIB_DIR}/dnf.sh"
. "${LIB_DIR}/systemd.sh"

set ${CI:+-x} -euo pipefail

REPO_ID="terra" && readonly REPO_ID
PACKAGES=( "coolercontrol" ) && readonly PACKAGES
UNITS=( "coolercontrold.service" ) && readonly UNITS

echo Installing packages from Terra…

DNF_INSTALL_OPTS=( \
    "--setopt=tsflags=noscripts" \
    "--setopt=install_weak_deps=True" \
)
dnf::external_install \
    "${REPO_ID}" \
    "${PACKAGES}"
unset -v DNF_INSTALL_OPTS

systemd::enable_units \
    "${UNITS[@]}"

echo Successfully installed.
