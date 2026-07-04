#!/bin/bash

echo Installing package from Terra…

dnf5 -y install \
	--enable-repo="terra" \
	bpftune


rpm -V \
	bpftune

echo Successfully installed.


echo Enabling service unit…

systemctl enable bpftune


systemctl is-enabled bpftune

echo Successfully enabled.
