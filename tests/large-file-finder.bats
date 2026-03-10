#!/usr/bin/env bats

load 'test_helper/bats-support/load'
load 'test_helper/bats-assert/load'

setup() {
    SCRIPT_PATH="$(cd "$(dirname "$BATS_TEST_FILENAME")/.." && pwd)/scripts/large-file-finder.sh"
    export SCRIPT_PATH
    chmod +x "$SCRIPT_PATH"
    TEST_DIR=$(mktemp -d)
    export TEST_DIR
}

teardown() {
    rm -rf "$TEST_DIR"
}

@test "script file exists and is executable" {
    [ -f "$SCRIPT_PATH" ]
    [ -x "$SCRIPT_PATH" ]
}

@test "script defines TOP_N variable" {
    run grep -q "^TOP_N=" "$SCRIPT_PATH"
    assert_success
}

@test "--help flag exits with status 0" {
    run bash "$SCRIPT_PATH" --help
    assert_success
    assert_output --partial "Usage:"
}

@test "script rejects non-numeric top" {
    run bash "$SCRIPT_PATH" --top abc
    assert_failure
}

@test "script rejects non-numeric min-size" {
    run bash "$SCRIPT_PATH" --min-size abc
    assert_failure
}

@test "script exits with error for nonexistent directory" {
    run bash "$SCRIPT_PATH" /nonexistent/dir
    assert_failure
}

@test "script finds no files when all are under min-size" {
    touch "${TEST_DIR}/tiny.txt"
    run bash "$SCRIPT_PATH" --min-size 100 "$TEST_DIR"
    assert_success
}

@test "script uses find command" {
    run grep -q "find " "$SCRIPT_PATH"
    assert_success
}

@test "script outputs human-readable sizes" {
    run grep -qE "MB|GB|KB" "$SCRIPT_PATH"
    assert_success
}
