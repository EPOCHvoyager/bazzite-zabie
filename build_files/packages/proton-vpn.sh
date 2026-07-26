#!/bin/bash

set ${CI:+-x} -euo pipefail

echo Installing Proton VPN software…

_install_repo() {
cat > /etc/yum.repos.d/protonvpn-stable.repo << EOF
#
# ProtonVPN stable release
#
[protonvpn-fedora-stable]
name = ProtonVPN Fedora Stable repository
baseurl = https://repo.protonvpn.com/fedora-$releasever-stable
enabled = 1
gpgcheck = 1
repo_gpgcheck=0
skip_if_unavailable=true
gpgkey = https://repo.protonvpn.com/fedora-$releasever-stable/public_key.asc
EOF
}

_install_repo

dnf5 -y install \
    --setopt=tsflags=noscripts \
    proton-vpn-gnome-desktop


rpm -V \
    proton-vpn-gnome-desktop

echo Successfully installed.


echo Enabling service units…

systemctl enable me.proton.vpn.split_tunneling.service


systemctl is-enabled me.proton.vpn.split_tunneling.service

echo Successfully enabled.
