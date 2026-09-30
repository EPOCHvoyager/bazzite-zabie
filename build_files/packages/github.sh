#!/usr/bin/env bash
. "${LIB_DIR}/dnf.sh"

set ${CI:+-x} -euo pipefail

_retrieve_api_json () {
    assert_single_argument "$@" || { printf "Repository required for retrieving a JSON from the GitHub API.\n" >&2 && return 1 ; }
    local repo ;  repo="$1"  && readonly repo

    local api_url ; api_url="https://api.github.com/repos/${repo}/releases/latest" && readonly api_url

    curl \
    --compressed \
    --fail-with-body \
    --silent \
    --show-error \
    --location \
    --retry 3 \
    --retry-connrefused \
    --connect-timeout 10 \
    --max-time 60 \
    --header 'Accept: application/vnd.github+json' \
    --header 'X-GitHub-Api-Version: 2026-03-10' \
    "${api_url}" || return
}

_get_asset_data () {
    assert_argument_count 2 "$@" || { printf 'Two arguments necessary to obtain GitHub asset data.\n' >&2 && return 1 ; }

    local json    ;  json="$1"     && readonly json
    local pattern ;  pattern="$2"  && readonly pattern

    jq -er --arg pattern "${pattern}" '
        [ .assets[] | select( .name | test($pattern) ) ] |
        if length == 1 then
            .[0]
        else
            error("Single asset required")
        end
    ' <<< "${json}" || return
}

_get_download_data () {
    assert_argument_count 4 "$@" || { printf 'Two arguments and two destination variables required for obtaining download data.\n' >&2 && return 1 ; }

    local repo              ;   repo="$1"           && readonly repo
    local pattern           ;   pattern="$2"        && readonly pattern
    local -n download_url   ;   download_url="$3"
    local -n asset_digest   ;   asset_digest="$4"

    local api_json ; api_json="$( _retrieve_api_json "${repo}" )" || return \
    && readonly api_json

    local asset_data ; asset_data="$( _get_asset_data "${api_json}" "${pattern}" )" || return \
    && readonly asset_data

    download_url="$( jq -er '.browser_download_url' <<< "${asset_data}" )"  || return
    asset_digest="$( jq -er '.digest' <<< "${asset_data}" )"                || return
}

_verify_download () {
    assert_argument_count 2 "$@" || { printf '.\n' >&2 && return 1 ; }

    local file    ;   file="$1"     && readonly file
    local digest  ;   digest="$2"   && readonly digest

    [[ "${digest}" =~ ^sha256:[0-9a-fA-F]{64}$ ]] || { printf 'Unsupported or invalid checksum: %s\n' "${digest}" >&2 && return 1 ; }

    local expected_sha256 ; expected_sha256="${digest#sha256:}" && readonly expected_sha256

    printf '%s  %s\n' "${expected_sha256}" "${file}" | \
    sha256sum -c || return
}

_download_rpm () {
    assert_argument_count 3 "$@" || { printf 'Three arguments required downloading GitHub release RPM.\n' >&2 && return 1 ; }

    local repo          ;   repo="$1"           && readonly repo
    local pattern       ;   pattern="$2"        && readonly pattern
    local destination   ;   destination="$3"    && readonly destination

    local download_url digest
    _get_download_data "${repo}" "${pattern}" "download_url" "digest" || return
    readonly download_url digest

    wget \
        --no-verbose \
        --tries=3 \
        --waitretry=2 \
        --timeout=10 \
        --output-document="${destination}" \
        "${download_url}" || return

    _verify_download "${destination}" "${digest}"
}

_install_latest_release () {
    assert_multiple_arguments "$@" || { printf 'Multiple arguments required for installing RPM from latest GitHub release.\n' >&2 && return 1 ; }

    local -a dnf_opts ; local opts_consumed
    dnf::parse_opts "dnf_opts" "opts_consumed" "$@" || return
    readonly dnf_opts opts_consumed
    shift "${opts_consumed}"

    local -a reconstructed_opts
    dnf::passthrough_opts "dnf_opts" "reconstructed_opts" || return
    readonly reconstructed_opts

    assert_multiple_arguments "$@" || { printf 'Multiple arguments required for installing RPM from latest GitHub release.\n' >&2 && return 1 ; }

    local repo    ;   repo="$1"      && readonly repo
    local pattern ;   pattern="$2"   && readonly pattern

    local tmp_dir ;  tmp_dir="$( mktemp -d )"  || return \
    && readonly tmp_dir

    trap "rm -rf -- '${tmp_dir}'" RETURN

    local rpm_file ;  rpm_file="$( mktemp "${tmp_dir}/XXXXXX.rpm" )"  || return \
    && readonly rpm_file

    echo "Downloading RPM with pattern ${pattern} from the latest GitHub release at ${repo}…" && \
    _download_rpm "${repo}" "${pattern}" "${rpm_file}" || return \
    && echo "Downloaded successfully."

    echo "Installing RPM…" && \
    dnf::rpm_install "${reconstructed_opts[@]}" "${rpm_file}" || return \
    && echo "Successfully installed."
}

main () {
    :
}

main
