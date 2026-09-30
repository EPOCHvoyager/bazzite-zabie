#!/usr/bin/env bash
. "${LIB_DIR}/dnf.sh"

set ${CI:+-x} -euo pipefail

_retrieve_api_json () {
    assert_single_argument "$@" || { printf "Repository required for retrieving a JSON from the GitHub API.\n" >&2 && return 1 ; }
    local repo ; repo="$1" && readonly repo

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

_get_rpm_url () {
    assert_argument_count 2 "$@" || { printf 'Two arguments required for obtaining download URL from release.\n' >&2 && return 1 ; }

    local repo    ;  repo="$1"     && readonly repo
    local pattern ;  pattern="$2"  && readonly pattern

    _retrieve_api_json "${repo}" | \
    jq -er --arg pattern "${pattern}" '
        [ .assets[] | select( .name | test($pattern) ) ] |
        if length == 1 then
            .[0].browser_download_url
        else
            error("Single asset required")
        end
    ' || return
}

_download_rpm () {
    assert_argument_count 3 "$@" || { printf 'Three arguments required downloading GitHub release RPM.\n' >&2 && return 1 ; }

    local repo        ;  repo="$1"         && readonly repo
    local pattern     ;  pattern="$2"      && readonly pattern
    local destination ;  destination="$3"  && readonly destination

    local download_url ; download_url="$( _get_rpm_url "${repo}" "${pattern}" )" || return
    readonly download_url

    wget \
        --no-verbose \
        --tries=3 \
        --waitretry=2 \
        --timeout=10 \
        --output-document="${destination}" \
        "${download_url}" || return
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

    local repo    ;  repo="$1"     && readonly repo
    local pattern ;  pattern="$2"  && readonly pattern

    local tmp_dir ; tmp_dir="$( mktemp -d )" || return \
    && readonly tmp_dir

    trap 'rm -rf -- "$tmp_dir"' RETURN

    local rpm_file ; rpm_file="$( mktemp "${tmp_dir}/rpm-XXXXXX" )" || return \
    && readonly rpm_file

    echo "Downloading RPM with pattern ${pattern} from the latest GitHub release at ${repo}…" && \
    _download_rpm "${repo}" "${pattern}" "${rpm_file}" || return \
    && echo "Downloaded successfully."

    echo "Installing RPM…" && \
    dnf::rpm_install "${reconstructed_opts[@]}" "${rpm_file}" || return \
    && echo "Successfully installed."
}

main () {
    _install_lastest_release \
    "Heroic-Games-Launcher/HeroicGamesLauncher" \
    "^Heroic-.*-x86_64\.rpm$"
}

main
