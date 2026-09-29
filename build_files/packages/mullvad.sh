#!/usr/bin/env bash
. "${LIB_DIR}/dnf.sh"
. "${LIB_DIR}/systemd.sh"

set ${CI:+-x} -euo pipefail

REPO_URL="https://repository.mullvad.net/rpm/stable/mullvad.repo"           && readonly REPO_URL
PACKAGE="mullvad-vpn"                                                       && readonly PACKAGE
REPO_ID="mullvad-stable"                                                    && readonly REPO_ID
UNITS=( "mullvad-daemon.service" "mullvad-early-boot-blocking.service" )    && readonly UNITS
EXCLUDE_BIN="/usr/bin/mullvad-exclude"                                      && readonly EXCLUDE_BIN

_add_permissions () {
    echo "Adding permissions…" && \
    chmod u+s "${EXCLUDE_BIN}" || return


    [[ $( stat --format='%a' "${EXCLUDE_BIN}" ) = "4755" ]] \
    && echo "Successfully added." || return
}

main () {
    dnf::add_repo \
        "${REPO_URL}" || return

    echo "Installing Mullvad VPN software…" && \
    dnf::external_install \
        "${REPO_ID}" \
        "${PACKAGE}" \
        -o "--setopt=tsflags=noscripts" \
    && echo "Mullvad VPN software successfully installed." || return

    systemd::enable_units \
        "${UNITS[@]}" || return

    _add_permissions || return
}

main
