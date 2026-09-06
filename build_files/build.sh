#!/bin/bash

set ${CI:+-x} -euo pipefail

UTILITY_DIR="/ctx/utilities"
UTILITY_SCRIPTS=( \
"${UTILITY_DIR}/copy-files.sh" \
"${UTILITY_DIR}/enable-pci-latency.sh" \
"${UTILITY_DIR}/install-packages.sh" \
"${UTILITY_DIR}/remove-gamemode-config.sh" )

for s in "${UTILITY_SCRIPTS[@]}"; do
	sh -c "$s" || exit 1
done
