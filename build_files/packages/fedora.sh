#!/usr/bin/env bash
. "${LIB_DIR}/dnf.sh"
. "${LIB_DIR}/systemd.sh"

set ${CI:+-x} -euo pipefail

PACKAGES=( \
    "realtime-setup" \
    "irqbalance" \
    "pipewire-module-filter-chain-lv2" \
    "gamemode" \
    "langpacks-pt_BR" \
) && readonly PACKAGES

UNITS=( \
    "irqbalance.service" \
    "realtime-setup.service" \
    "realtime-entsk.service" \
) && readonly UNITS

main () {
    echo "Installing packages from Fedora…" && \
    dnf::install \
        -o "--setopt=tsflags=noscripts" \
        -o "--setopt=install_weak_deps=True" \
        "${PACKAGES[@]}" \
    && echo "Successfully installed packages from Fedora." || return

    systemd::enable_units \
        "${UNITS[@]}" || return
}

main
