#!/usr/bin/env bash
. "${LIB_DIR}/dnf.sh"

set ${CI:+-x} -euo pipefail

_get_copr_repo () {
    assert_single_argument "$@" || { printf 'Single argument required for Copr repository file installation.\n' >&2 && return 1 ; }
    local copr ; copr="$1" ; readonly copr

    dnf5 -y copr enable \
        "${copr}" || return

    local copr_id ; copr_id="copr:copr.fedorainfracloud.org:${copr//[!0-9a-zA-Z.-]/:}" ; readonly copr_id
    dnf::disable_repo "${copr_id}" || return
}

_copr_install () {
    assert_multiple_arguments "$@" || { printf 'Multiple arguments required for Copr installation.\n' >&2 && return 1 ; }

    local -a dnf_opts ; local opts_consumed
    dnf::parse_opts "dnf_opts" "opts_consumed" "$@" || return
    readonly dnf_opts opts_consumed
    shift "${opts_consumed}"

    local -a reconstructed_opts
    dnf::passthrough_opts "dnf_opts" "reconstructed_opts" || return
    readonly reconstructed_opts

    assert_multiple_arguments "$@" || { printf 'Multiple arguments required for Copr installation.\n' >&2 && return 1 ; }

    local copr ; copr="$1" && readonly copr
    shift
    local -a packages ; packages=( "$@" ) && readonly packages

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
    # Use Piotr's Copr, as it is more actively maintained than the one pulled in the base image.
    _copr_install \
        -o "--allowerasing" \
        "sirlucjan/scx-scheds-cargo" \
        "scx-scheds-git" "scx-tools-git" || return

    # Disable default repos to bar dependency resolution from performing partial Plasma upgrades, in case upstream is behind Fedora.
    _copr_install \
        -o "--disablerepo=fedora,updates,updates-archive" \
        "infinality/kwin-effects-better-blur-dx" \
        "kwin-effects-better-blur-dx" || return
}

main
