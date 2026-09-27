#!/usr/bin/env bash

set ${CI:+-x} -euo pipefail

CONFIG_PATH="/usr/share/gamemode/gamemode.ini"

main () {
    echo Removing Feral gamemode stock configuration…
    rm "${CONFIG_PATH}"


    [[ ! -f "${CONFIG_PATH}" ]]
    echo Successfully removed
}

main
