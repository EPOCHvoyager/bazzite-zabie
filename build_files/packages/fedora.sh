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
    DNF_INSTALL_OPTS=( \
        "--setopt=tsflags=noscripts" \
        "--setopt=install_weak_deps=True" \
    ) || return
    echo "Installing packages from Fedora…" && \
    dnf::install \
        "${PACKAGES[@]}" \
    && echo "Successfully installed packages from Fedora." || return
    unset -v DNF_INSTALL_OPTS || return

    systemd::enable_units \
        "${UNITS[@]}" || return
}

main
