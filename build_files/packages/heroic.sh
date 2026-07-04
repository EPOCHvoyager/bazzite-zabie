#!/bin/bash

set ${CI:+-x} -euo pipefail

URL="https://api.github.com/repos/Heroic-Games-Launcher/HeroicGamesLauncher/releases/latest"

echo Installing Heroic from latest GitHub release…

curl -s $URL \
| jq -r '.assets[] | select(.name | contains ("x86_64.rpm")) | .browser_download_url' \
| head -n 1 \
| xargs -I {} wget {} -P /tmp

dnf5 -y install \
	/tmp/Heroic-*-x86_64.rpm
rm /tmp/Heroic-*-x86_64.rpm


rpm -V \
    heroic

echo Successfully installed.
