#!/usr/bin/env bash

assert_arguments_passed () {
    (( $# > 0 ))
}

assert_single_argument () {
    (( $# == 1 ))
}

assert_multiple_arguments () {
    (( $# >= 2 ))
}

assert_argument_count () {
    assert_arguments_passed "$@" || return
    local wanted_args ;  wanted_args="$1"  && readonly wanted_args
    shift
    (( $# == wanted_args ))
}
