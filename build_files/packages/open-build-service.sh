#!/usr/bin/env bash
. "${LIB_DIR}/dnf.sh"

set ${CI:+-x} -euo pipefail

_get_repo_url () {
    assert_argument_count 2 "$@" || { error 'Input and output variables required to obtain Open Build Service repository URL.' ; return 1 ; }

    local -n obs_project_ref="$1"
    local -n obs_repo_url_ref="$2"

    local release ;  release="$(rpm -E '%fedora')" || return \
    && readonly release

    obs_repo_url_ref="https://download.opensuse.org/repositories/${obs_project_ref}/Fedora_${release}/${obs_project_ref}.repo"
}

_convert_obs_id () {
    assert_argument_count 2 "$@" || { error 'Input and output variables required to convert Open Build Service repository ID.' ; return 1 ; }

    local -n obs_project_ref="$1"
    local -n obs_repo_id_ref="$2"

    obs_repo_id_ref="${obs_project_ref//[!0-9a-zA-Z.-]/_}"
}

_get_obs_repo () {
    assert_single_argument "$@" || { error 'Single argument required for Open Build Service repository setup.' ; return 1 ; }

    local obs_project ;  obs_project="$1"  && readonly obs_project

    local obs_repo_url ;  _get_repo_url "obs_project" "obs_repo_url" || return
    readonly obs_repo_url

    dnf::add_repo "${obs_repo_url}" || return

    local obs_repo_id ;  _convert_obs_id "obs_project" "obs_repo_id" || return
    readonly obs_repo_id

    dnf::disable_repo "${obs_repo_id}" || return
}

_obs_install () {
    assert_multiple_arguments "$@" || { error 'Multiple arguments required for Open Build Service installation.' ; return 1 ; }

    local -a dnf_opts ; local opts_consumed
    dnf::parse_opts "dnf_opts" "opts_consumed" "$@" || return
    readonly dnf_opts opts_consumed
    shift "${opts_consumed}"

    local -a reconstructed_opts
    dnf::passthrough_opts "dnf_opts" "reconstructed_opts" || return
    readonly reconstructed_opts

    assert_multiple_arguments "$@" || { error 'Project and package(s) required for Open Build Service installation.' ; return 1 ; }

    local obs_project ;  obs_project="$1"   && readonly obs_project
    shift
    local -a packages ;  packages=( "$@" )  && readonly packages

    _get_obs_repo "${obs_project}" || return

    local obs_repo_id ;  _convert_obs_id "obs_project" "obs_repo_id" || return
    readonly obs_repo_id

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
