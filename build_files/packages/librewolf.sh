#!/bin/bash

set ${CI:+-x} -euo pipefail

echo Installing LibreWolf…

PACKAGE="librewolf"
REPO_ID="${PACKAGE}"

dnf5 -y config-manager \
    addrepo --from-repofile=https://repo.librewolf.net/librewolf.repo
dnf5 -y install \
    "${PACKAGE}"
dnf5 config-manager disable \
    "${REPO_ID}"


rpm -V \
    "${PACKAGE}"
dnf5 repolist --disabled | grep -q "${REPO_ID}"

echo Successfully installed.


echo Applying fix for Plasma Integration…

# See — https://www.librewolf.net/docs/faq/#how-do-i-get-native-messaging-to-work.
# The Fedora plasma-browser-integration package puts this in /lib64, LibreWolf looks for it in /lib.
mkdir /usr/lib/librewolf
ln -s /usr/lib64/librewolf/native-messaging-hosts /usr/lib/librewolf/native-messaging-hosts


[[ -f /usr/lib/librewolf/native-messaging-hosts/org.kde.plasma.browser_integration.json ]]

echo Successfully applied.
