#!/usr/bin/env bash
. "${LIB_DIR}/parse.sh"

dnf::add_repo () {
    assert_single_argument "$@" || {
        printf '%s:%s: Single argument required for adding repository through dnf.\n' \
        "${BASH_SOURCE[0]##*/}" "${FUNCNAME[0]}" >&2
        return 1
    }

    local repo_file ;  repo_file="$1"  && readonly repo_file

    dnf5 config-manager addrepo \
        --from-repofile="${repo_file}" || return
}

dnf::get_repo_json () {
    assert_single_argument "$@" || {
        printf '%s:%s: Single argument required to query repository data from dnf.\n' \
        "${BASH_SOURCE[0]##*/}" "${FUNCNAME[0]}" >&2
        return 1
    }

    local query_repo ;  query_repo="$1"  && readonly query_repo

    dnf5 repo info --all --json "${query_repo}" || return
}

dnf::assert_repo_disabled () {
    assert_single_argument "$@" || {
        printf '%s:%s: Single argument required for repository disablement assertion.\n' \
        "${BASH_SOURCE[0]##*/}" "${FUNCNAME[0]}" >&2
        return 1
    }

    local repo_id ;  repo_id="$1"  && readonly repo_id

    local repo_json ;  repo_json="$( dnf::get_repo_json "${repo_id}" )" || return \
    && readonly repo_json

    jq -e --arg id "$repo_id" \
        'length == 1 and .[0].id == $id and .[0].is_enabled == false' <<< "${repo_json}" || return
}

dnf::disable_repo () {
    assert_single_argument "$@" || {
        printf '%s:%s: Single argument required for disabling repository through dnf.\n' \
        "${BASH_SOURCE[0]##*/}" "${FUNCNAME[0]}" >&2
        return 1
    }

    local repo_id ;  repo_id="$1"  && readonly repo_id

    dnf5 config-manager disable \
        "${repo_id}" || return
    dnf::assert_repo_disabled "${repo_id}"
}

dnf::parse_opts () {
    assert_multiple_arguments "$@" || {
        printf '%s:%s: Destination variables required for parsing dnf installation options.\n' \
        "${BASH_SOURCE[0]##*/}" "${FUNCNAME[0]}" >&2
        return 1
    }

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
                printf '%s:%s: Argument required for option -%s.\n' \
                "${BASH_SOURCE[0]##*/}" "${FUNCNAME[0]}" "$OPTARG" >&2
                return 2
                ;;
            \?)
                printf '%s:%s: Unrecognized option: -%s\n' \
                "${BASH_SOURCE[0]##*/}" "${FUNCNAME[0]}" "$OPTARG" >&2
                return 2
                ;;
        esac
    done
    consumed="$((OPTIND - 1))"
}

dnf::passthrough_opts () {
     assert_multiple_arguments "$@" || {
        printf '%s:%s: Destination variables required for dnf installation opt passthrough.\n' \
        "${BASH_SOURCE[0]##*/}" "${FUNCNAME[0]}" >&2
        return 1
    }

    local -n opts="$1"
    local -n passthrough_opts="$2"

    passthrough_opts=()
    local opt
    for opt in "${opts[@]}"; do
        passthrough_opts+=( -o "$opt" )
    done
}

_verify_rpm_installed () {
     assert_single_argument "$@" || {
        printf '%s:%s: Exactly one argument required for verifying installation.\n' \
        "${BASH_SOURCE[0]##*/}" "${FUNCNAME[0]}" >&2
        return 1
    }

     local rpm_file ;  rpm_file="$1"  && readonly rpm_file

     local package_name ;  package_name="$( rpm -qp --qf '%{NAME}\n' "${rpm_file}" )" || return \
     && readonly package_name

     rpm -V \
        "${package_name}" || return
}

dnf::rpm_install () {
    assert_arguments_passed "$@" || {
        printf '%s:%s: No arguments provided for RPM installation.\n' \
        "${BASH_SOURCE[0]##*/}" "${FUNCNAME[0]}" >&2
        return 1
    }

    local -a dnf_opts ; local opts_consumed
    dnf::parse_opts "dnf_opts" "opts_consumed" "$@" || return
    readonly dnf_opts opts_consumed
    shift "${opts_consumed}"

    assert_single_argument "$@" || {
        printf '%s:%s: Exactly one argument required for dnf RPM installation.\n' \
        "${BASH_SOURCE[0]##*/}" "${FUNCNAME[0]}" >&2
        return 1
    }

    local rpm_file ;  rpm_file="$1"  && readonly rpm_file

    dnf5 -y install \
        "${dnf_opts[@]}" \
        "${rpm_file}" || return

    _verify_rpm_installed "${rpm_file}" || return
}

dnf::install () {
    assert_arguments_passed "$@" || {
        printf '%s:%s: No arguments provided for dnf package installation.\n' \
        "${BASH_SOURCE[0]##*/}" "${FUNCNAME[0]}" >&2
        return 1
    }

    local -a dnf_opts ; local opts_consumed
    dnf::parse_opts "dnf_opts" "opts_consumed" "$@" || return
    readonly dnf_opts opts_consumed
    shift "${opts_consumed}"

    assert_arguments_passed "$@" || {
        printf '%s:%s: No packages provided for dnf installation.\n' \
        "${BASH_SOURCE[0]##*/}" "${FUNCNAME[0]}" >&2
        return 1
    }

    local packages ;  packages=( "$@" )  && readonly packages

    dnf5 -y install \
        "${dnf_opts[@]}" \
        "${packages[@]}" || return
    rpm -V \
        "${packages[@]}" || return
}

dnf::external_install () {
    assert_multiple_arguments "$@" || {
        printf '%s:%s: Multiple arguments required for external repository installation.\n' \
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
        printf '%s:%s: Multiple arguments required for external repository installation.\n' \
        "${BASH_SOURCE[0]##*/}" "${FUNCNAME[0]}" >&2
        return 1
    }

    local repository ;  repository="$1"  && readonly repository
    shift

    assert_arguments_passed "$@" || {
        printf '%s:%s: No packages provided for external repository installation.\n' \
        "${BASH_SOURCE[0]##*/}" "${FUNCNAME[0]}" >&2
        return 1
    }

    local -a packages ;  packages=( "$@" )  && readonly packages

    dnf::install -o "--enable-repo=${repository}" "${reconstructed_opts[@]}" "${packages[@]}" || return
}
