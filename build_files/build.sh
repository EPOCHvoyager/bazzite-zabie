#!/bin/bash

set ${CI:+-x} -euo pipefail

# Copy the contents of system_files/ of the git repo to /
cp -avf "/ctx/system_files"/. /

# Enable local service unit from system_files.
echo Enabling pci-latency service…

systemctl enable pci-latency.service


systemctl is-enabled pci-latency.service

echo Successfully enabled.

# Run all package installation scripts in set directory.
echo Installing packages…

PACKAGE_DIR="/ctx/packages"
SCRIPTS_RAN=0 ; echo "${SCRIPTS_RAN}" > /tmp/scripts_ran

for f in "${PACKAGE_DIR}"/*.sh; do
	sh -c "$f" || exit 1
done


shopt -s nullglob ; scripts=("${PACKAGE_DIR}"/*.sh) ; SCRIPT_COUNT="${#scripts[@]}"
read SCRIPTS_RAN < /tmp/scripts_ran

[[ "${SCRIPTS_RAN}" == "${SCRIPT_COUNT}" ]]

rm /tmp/scripts_ran

echo Package installation done.

# Remove stock settings for user scripting-only use.
echo Removing Feral gamemode stock configuration…

rm /usr/share/gamemode/gamemode.ini


[[ ! -f "/usr/share/gamemode/gamemode.ini" ]]

echo Successfully removed.

# Disable Krunner in favor of AppGrid.
echo Disabling Krunner…

chmod -x /usr/bin/krunner


[[ $( stat --format='%a' /usr/bin/krunner ) = "644" ]]

echo Successfully disabled.
