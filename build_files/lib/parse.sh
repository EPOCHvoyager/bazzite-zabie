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

