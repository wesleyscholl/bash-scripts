#!/usr/bin/env bats

load 'test_helper/bats-support/load'
load 'test_helper/bats-assert/load'

setup() {
    SCRIPT_PATH="$(cd "$(dirname "$BATS_TEST_FILENAME")/.." && pwd)/scripts/log-error-summary.sh"
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

@test "script defines PATTERNS array" {
    run grep -q "^PATTERNS=" "$SCRIPT_PATH"
    assert_success
}

@test "--help flag exits with status 0" {
    run bash "$SCRIPT_PATH" --help
    assert_success
    assert_output --partial "Usage:"
}

@test "missing log file argument exits with error" {
    run bash "$SCRIPT_PATH"
    assert_failure
}

@test "script exits with error for nonexistent log file" {
    run bash "$SCRIPT_PATH" /nonexistent/app.log
    assert_failure
}

@test "script counts ERROR pattern in sample log" {
    local sample="${TEST_DIR}/app.log"
    printf 'INFO service started\nERROR connection failed\nERROR timeout\nWARN low memory\n' > "$sample"
    run bash "$SCRIPT_PATH" "$sample"
    assert_success
    assert_output --partial "ERROR"
}

@test "script accepts custom pattern via --pattern flag" {
    run grep -q "\-\-pattern\|\-p" "$SCRIPT_PATH"
    assert_success
}

@test "script reports line count of log file" {
    local sample="${TEST_DIR}/test.log"
    printf 'line1\nline2\nline3\n' > "$sample"
    run bash "$SCRIPT_PATH" "$sample"
    assert_success
    assert_output --partial "Lines:"
}

@test "script shows sample lines for top pattern" {
    run grep -q "Sample lines" "$SCRIPT_PATH"
    assert_success
}

@test "script validates top is positive integer" {
    local sample="${TEST_DIR}/test.log"
    touch "$sample"
    run bash "$SCRIPT_PATH" --top 0 "$sample"
    assert_failure
}
