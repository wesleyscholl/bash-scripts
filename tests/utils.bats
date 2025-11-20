#!/usr/bin/env bats

# Common utility tests

@test "bash version 4.0 or higher" {
    [[ "${BASH_VERSION%%.*}" -ge 4 ]]
}

@test "grep available" {
    command -v grep
}

@test "awk available" {
    command -v awk
}

@test "sed available" {
    command -v sed
}

@test "curl or wget available" {
    command -v curl || command -v wget
}

@test "date command works" {
    run date
    [ "$status" -eq 0 ]
}

@test "hostname command works" {
    run hostname
    [ "$status" -eq 0 ]
}

@test "whoami command works" {
    run whoami
    [ "$status" -eq 0 ]
}

@test "environment variables set" {
    [ -n "$HOME" ]
    [ -n "$PATH" ]
}

@test "tmp directory writable" {
    [ -w "/tmp" ]
}
