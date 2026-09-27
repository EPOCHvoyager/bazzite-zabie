#!/usr/bin/env bash
. "${LIB_DIR}/dnf.sh"
. "${LIB_DIR}/systemd.sh"

set ${CI:+-x} -euo pipefail

REPO_ID="terra"                     && readonly REPO_ID
PACKAGES=( "coolercontrol" )        && readonly PACKAGES
UNITS=( "coolercontrold.service" )  && readonly UNITS

main () {
    echo Installing packages from Terra…

    DNF_INSTALL_OPTS=( \
        "--setopt=tsflags=noscripts" \
        "--setopt=install_weak_deps=True" \
    ) || return
    dnf::external_install \
        "${REPO_ID}" \
        "${PACKAGES}" || return
    unset -v DNF_INSTALL_OPTS || return

    systemd::enable_units \
        "${UNITS[@]}" || return

    echo Successfully installed.
}

main
