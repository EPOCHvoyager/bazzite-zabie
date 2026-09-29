#!/usr/bin/env bash
. "${LIB_DIR}/dnf.sh"
. "${LIB_DIR}/systemd.sh"

set ${CI:+-x} -euo pipefail

REPO_ID="terra"                     && readonly REPO_ID
PACKAGES=( "coolercontrol" )        && readonly PACKAGES
UNITS=( "coolercontrold.service" )  && readonly UNITS

main () {
    echo "Installing packages from Terra…" && \
    dnf::external_install \
        -o "--setopt=tsflags=noscripts" \
        -o "--setopt=install_weak_deps=True" \
        "${REPO_ID}" \
        "${PACKAGES[@]}" \
    && echo "Successfully installed packages from Terra." || return

    systemd::enable_units \
        "${UNITS[@]}" || return
}

main
