#!/bin/bash

set ${CI:+-x} -euo pipefail

# Copy the contents of system_files/ of the git repo to /
cp -avf "/ctx/system_files"/. /

# Enable local service unit from system_files.
echo Enabling pci-latency service…

systemctl enable pci-latency.service


systemctl is-enabled pci-latency.service

echo Successfully enabled.

# Create plugdev with the correct GID. TODO: Investigate upstream
groupadd plugdev -g 46


[[ "$(getent group 46)" =~ "plugdev" ]]

# Run all package installation scripts in set directory.
echo Installing packages…

PACKAGE_DIR="/ctx/packages"
shopt -s nullglob ; scripts=("${PACKAGE_DIR}"/*.sh) ; SCRIPT_COUNT="${#scripts[@]}" ; shopt -u nullglob
SCRIPTS_RAN=0

for f in "${PACKAGE_DIR}"/*.sh; do
	sh -c "$f" && (( ++SCRIPTS_RAN )) || exit 1
done


[[ "${SCRIPTS_RAN}" == "${SCRIPT_COUNT}" ]]

echo Package installation done.

# Remove stock settings for user scripting-only use.
echo Removing Feral gamemode stock configuration…

rm /usr/share/gamemode/gamemode.ini


[[ ! -f "/usr/share/gamemode/gamemode.ini" ]]

echo Successfully removed.
