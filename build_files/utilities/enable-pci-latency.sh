#!/bin/bash

set ${CI:+-x} -euo pipefail

UNIT="pci-latency.service"

# Enable local service unit from system_files.
echo Enabling pci-latency service…
systemctl enable "${UNIT}"


systemctl is-enabled "${UNIT}"
echo Successfully enabled.
