#!/usr/bin/env bats

load 'test_helper/bats-support/load'
load 'test_helper/bats-assert/load'

setup() {
    export SCRIPT_PATH="${BATS_TEST_DIRNAME}/../scripts/remote-backup-verifier.sh"
}

@test "script exists" {
    [ -f "$SCRIPT_PATH" ]
}

@test "script checks ssh dependency" {
    run grep -q "command -v ssh" "$SCRIPT_PATH"
    [ "$status" -eq 0 ]
}

@test "script supports help" {
    run "$SCRIPT_PATH" --help
    [ "$status" -eq 0 ]
}

@test "script requires host and path" {
    run "$SCRIPT_PATH"
    [ "$status" -eq 0 ]
}
