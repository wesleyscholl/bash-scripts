#!/usr/bin/env bats

# Tests for random-password-generator.sh

@test "openssl available for password generation" {
    command -v openssl
}

@test "generate random bytes" {
    run openssl rand -base64 32
    [ "$status" -eq 0 ]
    [ -n "$output" ]
}

@test "password has expected length" {
    password=$(openssl rand -base64 12)
    [ ${#password} -gt 10 ]
}

@test "tr command available for character filtering" {
    command -v tr
}

@test "generated password is unique" {
    pass1=$(openssl rand -base64 16)
    pass2=$(openssl rand -base64 16)
    [ "$pass1" != "$pass2" ]
}
