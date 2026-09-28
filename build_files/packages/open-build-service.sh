#!/usr/bin/env bash
. "${LIB_DIR}/dnf.sh"

set ${CI:+-x} -euo pipefail

_get_obs_repo () {
    assert_single_argument "$@" || { printf 'Single argument required for Open Build Service repository file installation.\n' >&2 && return 1 ; }
    local obs_project ; obs_project="$1" && readonly obs_project

    local release  ; release="$(rpm -E '%fedora')" && readonly release
    local obs_repo ; obs_repo="https://download.opensuse.org/repositories/${obs_project}/Fedora_${release}/${obs_project}.repo" && readonly obs_repo
    dnf::add_repo "${obs_repo}" || return

    local obs_repo_id ; obs_repo_id="${obs_project//[!0-9a-zA-Z.-]/_}" && readonly obs_repo_id
    dnf::disable_repo "${obs_repo_id}" || return
}

_obs_install () {
    assert_multiple_arguments "$@" || { printf 'Multiple arguments required for Open Build installation.\n' >&2 && return 1 ; }
    local obs_project ; obs_project="$1"  && readonly obs_project
    shift
    local -a packages ; packages=( "$@" ) && readonly packages

    _get_obs_repo "${obs_project}" || return

    local obs_repo_id ; obs_repo_id="${obs_project//[!0-9a-zA-Z.-]/_}" && readonly obs_repo_id
    echo "Installing packages from Open Build Service project ${obs_project}…" && \
    dnf::external_install \
        "${obs_repo_id}" \
        "${packages[@]}" \
    && echo "Successfully installed packages from ${obs_project}." || return
}

main () {
    _obs_install \
        "home:luisbocanegra" \
        "plasma-panel-colorizer" "plasma-panel-spacer-extended" || return

    _obs_install \
        "home:paulmcauley" \
        "klassy" || return
}

main
