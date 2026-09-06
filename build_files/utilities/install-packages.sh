#!/bin/bash

set ${CI:+-x} -euo pipefail

echo Installing packages…
PACKAGE_DIR="/ctx/packages"
shopt -s nullglob ; scripts=("${PACKAGE_DIR}"/*.sh) ; SCRIPT_COUNT="${#scripts[@]}" ; shopt -u nullglob
SCRIPTS_RAN=0

for f in "${PACKAGE_DIR}"/*.sh; do
	sh -c "$f" && (( ++SCRIPTS_RAN )) || exit 1
done


[[ "${SCRIPTS_RAN}" == "${SCRIPT_COUNT}" ]]
echo Package installation done.
