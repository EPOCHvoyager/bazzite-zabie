#!/bin/bash

set ${CI:+-x} -euo pipefail

echo Installing packages from Terra…

dnf5 -y install \
	--enable-repo="terra" \
	bpftune \
	plasma6-applet-appgrid


rpm -V \
	bpftune \
	plasma6-applet-appgrid

echo Successfully installed.


echo Enabling service unit…

systemctl enable bpftune


systemctl is-enabled bpftune

echo Successfully enabled.
