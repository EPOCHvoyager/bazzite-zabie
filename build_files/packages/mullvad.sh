#!/usr/bin/env bash
. "${LIB_DIR}/dnf.sh"
. "${LIB_DIR}/systemd.sh"

set ${CI:+-x} -euo pipefail

REPO_URL="https://repository.mullvad.net/rpm/stable/mullvad.repo"           && readonly REPO_URL
PACKAGE="mullvad-vpn"                                                       && readonly PACKAGE
REPO_ID="mullvad-stable"                                                    && readonly REPO_ID
UNITS=( "mullvad-daemon.service" "mullvad-early-boot-blocking.service" )    && readonly UNITS
EXCLUDE_BIN="/usr/bin/mullvad-exclude"                                      && readonly EXCLUDE_BIN
TROUBLESHOOTING_BIN="/opt/Mullvad VPN/resources/mullvad-problem-report"     && readonly TROUBLESHOOTING_BIN
SYMLINK_LOCATION="/usr/bin/mullvad-problem-report"                          && readonly SYMLINK_LOCATION

_add_permissions () {
    assert_single_argument "$@" || {
        printf '%s:%s: Single argument required for adding permissions.\n' \
        "${BASH_SOURCE[0]##*/}" "${FUNCNAME[0]}" >&2
        return 1
    }

    local target ;  target="$1"  && readonly target

    echo "Adding permissions…" && \
    chmod u+s "${target}" || return


    [[ $( stat --format='%a' "${target}" ) = "4755" ]] \
    && echo "Successfully added." || return
}

_add_symlink () {
    assert_argument_count 2 "$@" || {
        printf '%s:%s: Two arguments required for symlink creation.\n' \
        "${BASH_SOURCE[0]##*/}" "${FUNCNAME[0]}" >&2
        return 1
    }

    local symlink_target    ;   symlink_target="$1"    && readonly symlink_target
    local symlink           ;   symlink="$2"           && readonly symlink

    ln -sf "${symlink_target}" \
    "${symlink}"
}

main () {
    dnf::add_repo \
        "${REPO_URL}" || return

    echo "Installing Mullvad VPN software…" && \
    dnf::external_install \
        -o "--setopt=tsflags=noscripts" \
        "${REPO_ID}" \
        "${PACKAGE}" \
    && echo "Mullvad VPN software successfully installed." || return

    systemd::enable_units \
        "${UNITS[@]}" || return

    # These are normally handled by install scriptlets.
    _add_permissions "${EXCLUDE_BIN}" || return
    _add_symlink "${TROUBLESHOOTING_BIN}" "${SYMLINK_LOCATION}" || return
}

main
