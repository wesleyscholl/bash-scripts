#!/usr/bin/env bats

load 'test_helper/bats-support/load'
load 'test_helper/bats-assert/load'

setup() {
    SCRIPT_PATH="$(cd "$(dirname "$BATS_TEST_FILENAME")/.." && pwd)/scripts/certificate-renewal-check.sh"
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

@test "script defines WARN_DAYS variable" {
    run grep -q "^WARN_DAYS=" "$SCRIPT_PATH"
    assert_success
}

@test "--help flag exits with status 0" {
    run bash "$SCRIPT_PATH" --help
    assert_success
    assert_output --partial "Usage:"
}

@test "missing argument exits with error" {
    run bash "$SCRIPT_PATH"
    assert_failure
}

@test "script requires openssl" {
    run grep -q "openssl" "$SCRIPT_PATH"
    assert_success
}

@test "script validates warn-days is an integer" {
    run bash "$SCRIPT_PATH" --warn-days abc example.com
    assert_failure
}

@test "script validates crit-days is an integer" {
    run bash "$SCRIPT_PATH" --crit-days abc example.com
    assert_failure
}

@test "script detects EXPIRED in output text" {
    run grep -q "EXPIRED" "$SCRIPT_PATH"
    assert_success
}

@test "script detects CRITICAL in output text" {
    run grep -q "CRITICAL" "$SCRIPT_PATH"
    assert_success
}

@test "script reports error for nonexistent cert file" {
    run bash "$SCRIPT_PATH" /nonexistent/cert.pem
    assert_failure
}

@test "script checks a live certificate" {
    if ! command -v openssl >/dev/null 2>&1; then skip "openssl not available"; fi
    run bash "$SCRIPT_PATH" github.com:443
    [ "$status" -eq 0 ] || [ "$status" -eq 1 ]
    assert_output --partial "day(s)"
}
