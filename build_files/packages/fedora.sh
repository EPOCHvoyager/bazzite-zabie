#!/usr/bin/env bash
. "${LIB_DIR}/dnf.sh"
. "${LIB_DIR}/systemd.sh"

set ${CI:+-x} -euo pipefail

PACKAGES=( \
    "realtime-setup" \
    "irqbalance" \
    "gamemode" \
    "langpacks-pt_BR" \
) && readonly PACKAGES

UNITS=( \
    "irqbalance.service" \
    "realtime-setup.service" \
    "realtime-entsk.service" \
) && readonly UNITS

main () {
    echo Installing packages from Fedora…

    DNF_INSTALL_OPTS=( \
        "--setopt=tsflags=noscripts" \
        "--setopt=install_weak_deps=True" \
    ) || return
    dnf::install \
        "${PACKAGES[@]}" || return
    unset -v DNF_INSTALL_OPTS || return

    systemd::enable_units \
        "${UNITS[@]}" || return

    echo Successfully installed.
}

main
