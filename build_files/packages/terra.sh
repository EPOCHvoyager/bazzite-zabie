#!/bin/bash

set ${CI:+-x} -euo pipefail

echo Installing packages from Terra…

dnf5 -y install \
	--enable-repo="terra" \
	bpftune \
	vicinae


rpm -V \
	bpftune \
	vicinae

echo Successfully installed.


echo Enabling service unit…

systemctl enable bpftune


systemctl is-enabled bpftune

echo Successfully enabled.
