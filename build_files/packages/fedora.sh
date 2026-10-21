#!/usr/bin/env bash
. "${LIB_DIR}/dnf.sh"
. "${LIB_DIR}/systemd.sh"

set ${CI:+-x} -euo pipefail

PACKAGES=( \
    "realtime-setup" \
    "irqbalance" \
    "gamemode" \
    "langpacks-pt_BR" \
)  && readonly PACKAGES

FONT_PACKAGES=( \
    "atkinson-hyperlegible-next-fonts" \
    "ibm-plex-sans-fonts" \
    "ibm-plex-mono-fonts" \
    "adobe-source-sans-pro-fonts" \
)  && readonly FONT_PACKAGES

UNITS=( \
    "irqbalance.service" \
    "realtime-setup.service" \
    "realtime-entsk.service" \
)  && readonly UNITS

main () {
    echo "Installing fonts from Fedora…" && \
    dnf::install \
        "${FONT_PACKAGES[@]}" \
    && echo "Successfully installed fonts from Fedora." || return

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
