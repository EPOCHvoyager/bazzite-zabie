#!/bin/bash

set ${CI:+-x} -euo pipefail

REPO_PATH="/ctx/system_files"

# Copy the contents of system_files/ of the git repo to /
cp -avf "${REPO_PATH}"/. /
