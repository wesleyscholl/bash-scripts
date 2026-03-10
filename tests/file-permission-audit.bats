#!/usr/bin/env bats

load 'test_helper/bats-support/load'
load 'test_helper/bats-assert/load'

setup() {
    export SCRIPT_PATH="${BATS_TEST_DIRNAME}/../scripts/file-permission-audit.sh"
    export TMP_DIR="$(mktemp -d)"
    touch "$TMP_DIR/safe.txt"
    chmod 644 "$TMP_DIR/safe.txt"
}

teardown() {
    rm -rf "$TMP_DIR"
}

@test "script exists" {
    [ -f "$SCRIPT_PATH" ]
}

@test "script supports help" {
    run "$SCRIPT_PATH" --help
    [ "$status" -eq 0 ]
}

@test "script passes directory with safe permissions" {
    run "$SCRIPT_PATH" "$TMP_DIR"
    [ "$status" -eq 0 ]
}

@test "script checks find usage" {
    run grep -q "find .* -perm -0002" "$SCRIPT_PATH"
    [ "$status" -eq 0 ]
}
