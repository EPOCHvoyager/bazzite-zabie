#!/usr/bin/env bash

set ${CI:+-x} -euo pipefail

export LIB_DIR="/ctx/lib"

UTILITY_DIR="/ctx/utilities"
UTILITY_SCRIPTS=( \
    "${UTILITY_DIR}/copy-files.sh" \
    "${UTILITY_DIR}/install-packages.sh" \
    "${UTILITY_DIR}/remove-gamemode-config.sh" \
)

for script in "${UTILITY_SCRIPTS[@]}"; do
    "$script" || exit 1
done
