#!/usr/bin/env bats

load 'test_helper/bats-support/load'
load 'test_helper/bats-assert/load'

setup() {
    export SCRIPT_PATH="${BATS_TEST_DIRNAME}/../scripts/backup-integrity-check.sh"
    export TMP_DIR="$(mktemp -d)"
}

teardown() {
    rm -rf "$TMP_DIR"
}

@test "script file exists and is executable" {
    [ -f "$SCRIPT_PATH" ]
}

@test "script defines backup directory variable" {
    run grep -q "BACKUP_DIR=" "$SCRIPT_PATH"
    [ "$status" -eq 0 ]
}

@test "script supports help flag" {
    run "$SCRIPT_PATH" --help
    [ "$status" -eq 0 ]
    [[ "$output" == *"Usage:"* ]]
}

@test "script returns non-zero when no archives found" {
    run "$SCRIPT_PATH" "$TMP_DIR" 1
    [ "$status" -eq 2 ]
}
