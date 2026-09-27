#!/usr/bin/env bash
. "${LIB_DIR}/dnf.sh"

set ${CI:+-x} -euo pipefail

# Based on Microsoft's official instructions. See — https://code.visualstudio.com/docs/setup/linux
REPO_KEY="https://packages.microsoft.com/keys/microsoft.asc"    && readonly REPO_KEY
REPO_BASE_URL="https://packages.microsoft.com/yumrepos/vscode"  && readonly REPO_BASE_URL
REPO_PATH="/etc/yum.repos.d"                                    && readonly REPO_PATH
REPO_FILE="vscode.repo"                                         && readonly REPO_FILE
PACKAGE="code"                                                  && readonly PACKAGE
REPO_ID="${PACKAGE}"                                            && readonly REPO_ID
REPO_NAME="Visual Studio Code"                                  && readonly REPO_NAME

_import_key () {
    assert_single_argument "$@" || { printf 'Single argument required for importing repository key.\n' >&2 && return 1 ; }
    local repo_key ; repo_key="$@" && readonly repo_key

    rpm --import "${repo_key}" || return
}

_install_repo () {
    assert_multiple_arguments "$@" || { printf 'Multiple arguments required for installing Visual Studio Code repository.\n' >&2 && return 1 ; }
    local install_path  ;   install_path="$1"     && readonly install_path
    local repo_id       ;   repo_id="$2"          && readonly repo_id
    local repo_name     ;   repo_name="$3"        && readonly repo_name
    local repo_base_url ;   repo_base_url="$4"    && readonly repo_base_url
    local repo_key      ;   repo_key="$5"         && readonly repo_key

    cat <<- EOF > "${install_path}" || return
	[${repo_id}]
	name=${repo_name}
	baseurl=${repo_base_url}
	enabled=0
	autorefresh=1
	type=rpm-md
	gpgcheck=1
	gpgkey=${repo_key}
	EOF
}

main () {
    _import_key "${REPO_KEY}" || return
    _install_repo \
        "${REPO_PATH}/${REPO_FILE}" \
        "${REPO_ID}" \
        "${REPO_NAME}" \
        "${REPO_BASE_URL}" \
        "${REPO_KEY}" || return

    echo Installing Visual Studio Code…

    dnf::external_install \
        "${REPO_ID}" \
        "${PACKAGE}" || return

    echo Successfully installed.
}

main
