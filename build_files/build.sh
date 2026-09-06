#!/bin/bash

set ${CI:+-x} -euo pipefail

UTILITY_DIR="/ctx/utilities"
UTILITY_SCRIPTS=( \
"copy-files.sh" \
"enable-pci-latency.sh" \
"install-packages.sh" \
"remove-gamemode-config.sh" )

for s in "${UTILITY_DIR}"/"${UTILITY_SCRIPTS[@]}"; do
	sh -c "$s" || exit 1
done
