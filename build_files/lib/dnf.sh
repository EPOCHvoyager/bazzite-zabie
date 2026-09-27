#!/usr/bin/env bash
. "${LIB_DIR}/parse.sh"

dnf::add_repo () {
    assert_single_argument "$@" || { printf 'Single argument required for adding repository through dnf.\n' >&2 && return 1 ; }
    local repo_file ; repo_file="$1" && readonly repo_file

    dnf5 config-manager addrepo \
        --from-repofile="${repo_file}" || return
}

dnf::disable_repo () {
    assert_single_argument "$@" || { printf 'Single argument required for disabling repository through dnf.\n' >&2 && return 1 ; }
    local repo_id ; repo_id="$1" && readonly repo_id

    dnf5 config-manager disable \
        "${repo_id}" || return
    dnf::assert_repo_disabled "${repo_id}"
}

dnf::get_repo_json () {
    assert_single_argument "$@" || { printf 'Single argument required to query repository data from dnf.\n' >&2 && return 1 ; }
    local query_repo ; query_repo="$1" && readonly query_repo

    dnf5 repo info --all --json "${query_repo}" || return
}

dnf::assert_repo_disabled () {
    assert_single_argument "$@" || { printf 'Single argument required for repository disablement assertion.\n' >&2 && return 1 ; }
    local repo_id ; repo_id="$1" && readonly repo_id

    local repo_json ; repo_json="$(dnf::get_repo_json "${repo_id}")" && readonly repo_json

    jq -e --arg id "$repo_id" \
        'length == 1 and .[0].id == $id and .[0].is_enabled == false' <<< "${repo_json}" || return
}

dnf::install () {
    assert_arguments_passed "$@" || { printf 'No arguments provided for dnf package installation.\n' >&2 && return 1 ; }
    local packages ; packages=( "$@" ) && readonly packages
    if [[ -z "${repo_enable+x}" ]]; then
            :
        else
            local enable_repo ; enable_repo="${repo_enable}" && readonly enable_repo
    fi

    dnf5 -y install \
        ${DNF_INSTALL_OPTS:+"${DNF_INSTALL_OPTS[@]}"} \
        ${enable_repo:+"${enable_repo}"} \
        "${packages[@]}" || return
    rpm -V \
        "${packages[@]}" || return
}

dnf::external_install() {
    assert_multiple_arguments "$@" || { printf 'Multiple arguments required for external repository installation.\n' >&2 && return 1 ; }
    local repository ; repository="$1" && readonly repository
    shift
    local -a packages ; packages=( "$@" ) && readonly packages
    local repo_enable ; repo_enable="--enable-repo=${repository}" && readonly repo_enable

    dnf::install "${packages[@]}" || return
}
