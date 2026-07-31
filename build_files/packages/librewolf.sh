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
