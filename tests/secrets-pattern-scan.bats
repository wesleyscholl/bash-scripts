#!/usr/bin/env bats

load 'test_helper/bats-support/load'
load 'test_helper/bats-assert/load'

setup() {
    export SCRIPT_PATH="${BATS_TEST_DIRNAME}/../scripts/secrets-pattern-scan.sh"
    export TMP_DIR="$(mktemp -d)"
}

teardown() {
    rm -rf "$TMP_DIR"
}

@test "script file exists and is executable" {
    [ -f "$SCRIPT_PATH" ]
}

@test "script defines secret patterns array" {
    run grep -q "patterns=(" "$SCRIPT_PATH"
    [ "$status" -eq 0 ]
}

@test "script supports help flag" {
    run "$SCRIPT_PATH" --help
    [ "$status" -eq 0 ]
}

@test "script returns zero with no findings" {
    echo "safe-content" > "$TMP_DIR/safe.txt"
    run "$SCRIPT_PATH" "$TMP_DIR"
    [ "$status" -eq 0 ]
}
