#!/usr/bin/env bats

load 'test_helper/bats-support/load'
load 'test_helper/bats-assert/load'

setup() {
    export SCRIPT_PATH="${BATS_TEST_DIRNAME}/../scripts/backup-size-trend.sh"
    export TMP_DIR="$(mktemp -d)"
    echo "data" > "$TMP_DIR/a.txt"
}

teardown() {
    rm -rf "$TMP_DIR"
}

@test "script exists" {
    [ -f "$SCRIPT_PATH" ]
}

@test "script defines backup dir variable" {
    run grep -q "BACKUP_DIR=" "$SCRIPT_PATH"
    [ "$status" -eq 0 ]
}

@test "script supports help" {
    run "$SCRIPT_PATH" --help
    [ "$status" -eq 0 ]
}

@test "script runs against temp directory" {
    run "$SCRIPT_PATH" "$TMP_DIR" 5
    [ "$status" -eq 0 ]
}
