#!/bin/bash

set ${CI:+-x} -euo pipefail

# Copy the contents of system_files/ of the git repo to /
cp -avf "/ctx/system_files"/. /

# Enable local service unit from system_files
systemctl enable pci-latency.service


PACKAGE_DIR="/ctx/packages"

for f in "${PACKAGE_DIR}"/*.sh; do
	./"$f" || break
done
