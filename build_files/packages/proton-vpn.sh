#!/bin/bash

set ${CI:+-x} -euo pipefail

echo Installing Proton VPN software…

TMP_DIR="/tmp"
RELEASE="$(rpm -E '%fedora')"

_install_repo() {
    local repo_rpm ; repo_rpm="protonvpn-stable-release-1.0.4-1.noarch.rpm"
    local repo_rpm_url ; repo_rpm_url="https://repo.protonvpn.com/fedora-${RELEASE}-stable/protonvpn-stable-release/${repo_rpm}"

    wget "${repo_rpm_url}" -P "${TMP_DIR}"

    dnf5 -y install \
        "${TMP_DIR}/${repo_rpm}"


    rpm -V \
        "$( rpm -qp --qf '%{NAME}\n' "${TMP_DIR}/${repo_rpm}" )"

    rm "${TMP_DIR}"/*.rpm
}

_install_repo

dnf5 check-update --refresh

dnf5 -y install \
    proton-vpn-gnome-desktop


rpm -V \
    proton-vpn-gnome-desktop

echo Successfully installed.
