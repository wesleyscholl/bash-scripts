#!/usr/bin/env bats

load 'test_helper/bats-support/load'
load 'test_helper/bats-assert/load'

setup() {
    export SCRIPT_PATH="${BATS_TEST_DIRNAME}/../scripts/git-commit-signoff-check.sh"
}

@test "script exists" {
    [ -f "$SCRIPT_PATH" ]
}

@test "script defines commits variable" {
    run grep -q "COMMITS=" "$SCRIPT_PATH"
    [ "$status" -eq 0 ]
}

@test "script supports help" {
    run "$SCRIPT_PATH" --help
    [ "$status" -eq 0 ]
}

@test "script rejects invalid commit count" {
    run "$SCRIPT_PATH" abc
    [ "$status" -eq 1 ]
}
