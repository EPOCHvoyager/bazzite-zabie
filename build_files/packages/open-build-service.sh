#!/usr/bin/env bash
. "${LIB_DIR}/dnf.sh"

set ${CI:+-x} -euo pipefail

_get_obs_repo () {
    assert_single_argument "$@" || {
        printf '%s:%s: Single argument required for Open Build Service repository setup.\n' \
        "${BASH_SOURCE[0]##*/}" "${FUNCNAME[0]}" >&2
        return 1
    }

    local obs_project ;  obs_project="$1"  && readonly obs_project

    local release ;  release="$(rpm -E '%fedora')" || return \
    && readonly release

    local obs_repo ;  obs_repo="https://download.opensuse.org/repositories/${obs_project}/Fedora_${release}/${obs_project}.repo"  && readonly obs_repo

    dnf::add_repo "${obs_repo}" || return

    local obs_repo_id ;  obs_repo_id="${obs_project//[!0-9a-zA-Z.-]/_}"  && readonly obs_repo_id

    dnf::disable_repo "${obs_repo_id}" || return
}

_obs_install () {
    assert_multiple_arguments "$@" || {
        printf '%s:%s: Multiple arguments required for Open Build installation.\n' \
        "${BASH_SOURCE[0]##*/}" "${FUNCNAME[0]}" >&2
        return 1
    }

    local -a dnf_opts ; local opts_consumed
    dnf::parse_opts "dnf_opts" "opts_consumed" "$@" || return
    readonly dnf_opts opts_consumed
    shift "${opts_consumed}"

    local -a reconstructed_opts
    dnf::passthrough_opts "dnf_opts" "reconstructed_opts" || return
    readonly reconstructed_opts

    assert_multiple_arguments "$@" || {
        printf '%s:%s: Multiple arguments required for Open Build installation.\n' \
        "${BASH_SOURCE[0]##*/}" "${FUNCNAME[0]}" >&2
        return 1
    }

    local obs_project ;  obs_project="$1"   && readonly obs_project
    shift
    local -a packages ;  packages=( "$@" )  && readonly packages

    _get_obs_repo "${obs_project}" || return

    local obs_repo_id ;  obs_repo_id="${obs_project//[!0-9a-zA-Z.-]/_}"  && readonly obs_repo_id
    echo "Installing packages from Open Build Service project ${obs_project}…" && \

    dnf::external_install \
        "${reconstructed_opts[@]}" \
        "${obs_repo_id}" \
        "${packages[@]}" \
    && echo "Successfully installed packages from ${obs_project}." || return
}

main () {
    _obs_install \
        "home:luisbocanegra" \
        "plasma-panel-colorizer" "plasma-panel-spacer-extended" || return
}

main
