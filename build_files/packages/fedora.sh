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

echo Installing packages from Fedora…

DNF_INSTALL_OPTS=( \
    "--setopt=tsflags=noscripts" \
    "--setopt=install_weak_deps=True" \
)
dnf::install \
    "${PACKAGES[@]}"
unset -v DNF_INSTALL_OPTS

systemd::enable_units \
    "${UNITS[@]}"

echo Successfully installed.
