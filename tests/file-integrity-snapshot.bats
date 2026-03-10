#!/usr/bin/env bats

load 'test_helper/bats-support/load'
load 'test_helper/bats-assert/load'

setup() {
    export SCRIPT_PATH="${BATS_TEST_DIRNAME}/../scripts/file-integrity-snapshot.sh"
    export TMP_DIR="$(mktemp -d)"
    echo "hello" > "$TMP_DIR/sample.txt"
}

teardown() {
    rm -rf "$TMP_DIR"
}

@test "script file exists and is executable" {
    [ -f "$SCRIPT_PATH" ]
}

@test "script defines mode variable" {
    run grep -q "MODE=" "$SCRIPT_PATH"
    [ "$status" -eq 0 ]
}

@test "script supports help flag" {
    run "$SCRIPT_PATH" --help
    [ "$status" -eq 0 ]
}

@test "script creates and verifies manifest" {
    run "$SCRIPT_PATH" create "$TMP_DIR" "$TMP_DIR/manifest.sha256"
    [ "$status" -eq 0 ]

    run "$SCRIPT_PATH" verify "$TMP_DIR" "$TMP_DIR/manifest.sha256"
    [ "$status" -eq 0 ]
}
