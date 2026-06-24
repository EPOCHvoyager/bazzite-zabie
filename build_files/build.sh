#!/bin/bash

set -ouex pipefail

# Copy the contents of system_files/ of the git repo to /
cp -avf "/ctx/system_files"/. /

### Install packages

RELEASE="$(rpm -E '%fedora')"

## Packages from the Fedora repos

dnf5 -y install \
	irqbalance \
	realtime-setup
dnf5 -y install \
	--setopt=install_weak_deps=True \
	langpacks-pt_BR


## Package from Terra

dnf5 -y install \
	--enable-repo="terra" \
	bpftune


## Packages from Copr

dnf5 -y install \
	https://download.copr.fedorainfracloud.org/results/bieszczaders/kernel-cachyos-addons/fedora-43-x86_64/10428026-ananicy-cpp/ananicy-cpp-1.2.0-1.fc43.x86_64.rpm
# TODO: Remove once there's a new successfull build on Copr
dnf5 -y install \
	--enable-repo="copr:copr.fedorainfracloud.org:bieszczaders:kernel-cachyos-addons" \
	cachyos-ananicy-rules
	#ananicy-cpp

# Pull from Piotr's Copr instead of addons, as it's more actively maintained
dnf5 -y copr enable \
	sirlucjan/scx-scheds-cargo
dnf5 -y install \
	--allowerasing \
	scx-scheds-dev-git \
	scx-tools-dev-git
dnf5 -y copr disable \
	sirlucjan/scx-scheds-cargo

# This package needs to be rebuilt for specific versions of Plasma.
dnf5 -y copr enable \
	infinality/kwin-effects-better-blur-dx
dnf5 -y install \
	kwin-effects-better-blur-dx
dnf5 -y copr disable \
	infinality/kwin-effects-better-blur-dx

# Pull from the official Copr, as Terra is often out of date
dnf5 -y copr enable \
	codifryed/CoolerControl
dnf5 -y install \
	coolercontrol \
	coolercontrold
dnf5 -y copr disable \
	codifryed/CoolerControl


## Plasma customizations pulled from Open Build Service.

dnf5 config-manager addrepo \
	--from-repofile=https://download.opensuse.org/repositories/home:luisbocanegra/Fedora_"${RELEASE}"/home:luisbocanegra.repo
dnf5 -y install \
	plasma-panel-colorizer \
	plasma-panel-spacer-extended
dnf5 config-manager disable \
	home_luisbocanegra

dnf5 config-manager addrepo \
	--from-repofile=https://download.opensuse.org/repositories/home:paulmcauley/Fedora_"${RELEASE}"/home:paulmcauley.repo
dnf5 -y install \
	klassy
dnf5 config-manager disable \
	home_paulmcauley


## Mullvad's VPN software

dnf5 config-manager addrepo \
	--from-repofile=https://repository.mullvad.net/rpm/stable/mullvad.repo
dnf5 -y install \
	mullvad-vpn
dnf5 config-manager disable \
	mullvad-stable


### Enable service units

systemctl enable pci-latency.service

systemctl enable realtime-setup.service
systemctl enable realtime-entsk.service
systemctl enable irqbalance.service

systemctl enable bpftune.service
systemctl enable coolercontrold.service

systemctl enable ananicy-cpp.service

systemctl enable mullvad-daemon.service
systemctl enable mullvad-early-boot-blocking.service
