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

_dnf::parse_opts () {
    assert_multiple_arguments "$@" || { printf 'Destination variables required for parsing dnf installation options.\n' >&2 && return 1 ; }

    local -n opts="$1"
    local -n consumed="$2"
    shift 2

    opts=()
    local opt
    local OPTARG

    local OPTIND ; OPTIND=1
    while getopts ":o:" opt; do
        case "$opt" in
            o)
                opts+=( "$OPTARG" )
                ;;
            :)
                printf 'Argument required for option -%s.\n' "$OPTARG" >&2
                return 2
                ;;
            \?)
                printf 'Unrecognized option: -%s\n' "$OPTARG" >&2
                return 2
                ;;
        esac
    done
    consumed="$((OPTIND - 1))"
}

dnf::install () {
    assert_arguments_passed "$@" || { printf 'No arguments provided for dnf package installation.\n' >&2 && return 1 ; }

    local -a dnf_opts ; local opts_consumed
    _dnf::parse_opts "dnf_opts" "opts_consumed" "$@" || return
    readonly dnf_opts opts_consumed
    shift "${opts_consumed}"

    assert_arguments_passed "$@" || { printf 'No packages provided for dnf installation.\n' >&2 && return 1 ; }

    local packages ; packages=( "$@" ) && readonly packages

    dnf5 -y install \
        "${dnf_opts[@]}" \
        "${packages[@]}" || return
    rpm -V \
        "${packages[@]}" || return
}

dnf::external_install () {
    assert_multiple_arguments "$@" || { printf 'Multiple arguments required for external repository installation.\n' >&2 && return 1 ; }

    local -a dnf_opts ; local opts_consumed
    _dnf::parse_opts "dnf_opts" "opts_consumed" "$@" || return
    readonly dnf_opts opts_consumed
    shift "${opts_consumed}"

    assert_multiple_arguments "$@" || { printf 'Multiple arguments required for external repository installation.\n' >&2 && return 1 ; }
    local repository ; repository="$1" && readonly repository
    shift

    assert_arguments_passed "$@" || { printf 'No packages provided for external repository installation.\n' >&2 && return 1 ; }
    local -a packages ; packages=( "$@" ) && readonly packages

    local -a raw_opts
    for opt in "${dnf_opts[@]}"; do
        raw_opts+=( -o "$opt" )
    done
    readonly raw_opts

    dnf::install -o "--enable-repo=${repository}" "${raw_opts[@]}" "${packages[@]}" || return
}
