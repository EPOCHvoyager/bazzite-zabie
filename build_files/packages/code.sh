#!/usr/bin/env bash
. "${LIB_DIR}/dnf.sh"

set ${CI:+-x} -euo pipefail

echo Installing Visual Studio Code…

# Based on Microsoft's official instructions. See — https://code.visualstudio.com/docs/setup/linux
REPO_KEY="https://packages.microsoft.com/keys/microsoft.asc"
REPO_BASE_URL="https://packages.microsoft.com/yumrepos/vscode"
REPO_PATH="/etc/yum.repos.d"
REPO_FILE="vscode.repo"
PACKAGE="code"
REPO_ID="${PACKAGE}"

rpm --import "${REPO_KEY}"
cat << EOF > "${REPO_PATH}"/"${REPO_FILE}"
[${REPO_ID}]
name=Visual Studio Code
baseurl=${REPO_BASE_URL}
enabled=0
autorefresh=1
type=rpm-md
gpgcheck=1
gpgkey=${REPO_KEY}
EOF

dnf::external_install \
    "${REPO_ID}" \
    "${PACKAGE}"

echo Successfully installed.
