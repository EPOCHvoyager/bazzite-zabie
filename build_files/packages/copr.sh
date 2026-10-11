#!/usr/bin/env bash
. "${LIB_DIR}/dnf.sh"

set ${CI:+-x} -euo pipefail

_get_copr_repo () {
    assert_single_argument "$@" || error 'Single argument required for Copr repository setup.'

    local copr ;  copr="$1"  ; readonly copr

    dnf5 -y copr enable \
        "${copr}" || return

    local copr_id ; copr_id="copr:copr.fedorainfracloud.org:${copr//[!0-9a-zA-Z.-]/:}" ; readonly copr_id
    dnf::disable_repo "${copr_id}" || return
}

_copr_install () {
    assert_multiple_arguments "$@" || error 'Multiple arguments required for Copr installation.'

    local -a dnf_opts ; local opts_consumed
    dnf::parse_opts "dnf_opts" "opts_consumed" "$@" || return
    readonly dnf_opts opts_consumed
    shift "${opts_consumed}"

    local -a reconstructed_opts
    dnf::passthrough_opts "dnf_opts" "reconstructed_opts" || return
    readonly reconstructed_opts

    assert_multiple_arguments "$@" || error 'Copr repository and package(s) required for installation.'

    local copr ;  copr="$1"  && readonly copr
    shift
    local -a packages ;  packages=( "$@" )  && readonly packages

    _get_copr_repo "${copr}" || return

    local copr_id ; copr_id="copr:copr.fedorainfracloud.org:${copr//[!0-9a-zA-Z.-]/:}" && readonly copr_id
    echo "Installing packages from Copr ${copr}…" && \
    dnf::external_install \
        "${reconstructed_opts[@]}" \
        "${copr_id}" \
        "${packages[@]}" \
    && echo "Successfully installed packages from ${copr}." || return
}

main () {
    # Disable default repos to prevent dependency resolution from performing partial Plasma upgrades (for example, if the base image is behind Fedora).
    _copr_install \
        -o "--disablerepo=fedora,updates,updates-archive" \
        "infinality/kwin-effects-better-blur-dx" \
        "kwin-effects-better-blur-dx" || return
}

main
