#!/bin/bash

set ${CI:+-x} -euo pipefail

# Copy the contents of system_files/ of the git repo to /
cp -avf "/ctx/system_files"/. /


# Enable local service unit from system_files
echo Enabling pci-latency service…

systemctl enable pci-latency.service


systemctl is-enabled pci-latency.service

echo Successfully enabled.


# Run all package installation scripts
echo Installing packages…

PACKAGE_DIR="/ctx/packages"

for f in "${PACKAGE_DIR}"/*.sh; do
	sh -c "$f" || exit 1
done

echo Package installation done.


# Disable Krunner in favor of Vicinae
echo Disabling Krunner…

chmod -x /usr/bin/krunner


[[ $( stat --format='%a' /usr/bin/krunner ) = "644" ]]

echo Successfully disabled.
