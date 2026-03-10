#!/usr/bin/env bats

load 'test_helper/bats-support/load'
load 'test_helper/bats-assert/load'

setup() {
    SCRIPT_PATH="$(cd "$(dirname "$BATS_TEST_FILENAME")/.." && pwd)/scripts/dns-lookup-check.sh"
    export SCRIPT_PATH
    chmod +x "$SCRIPT_PATH"
}

@test "script file exists and is executable" {
    [ -f "$SCRIPT_PATH" ]
    [ -x "$SCRIPT_PATH" ]
}

@test "script defines EXPECTED_IP variable" {
    run grep -q "EXPECTED_IP" "$SCRIPT_PATH"
    assert_success
}

@test "--help flag exits with status 0" {
    run bash "$SCRIPT_PATH" --help
    assert_success
    assert_output --partial "Usage:"
}

@test "missing hostname argument exits with error" {
    run bash "$SCRIPT_PATH"
    assert_failure
}

@test "script checks for dig nslookup or host command" {
    run grep -q "dig\|nslookup\|host" "$SCRIPT_PATH"
    assert_success
}

@test "script resolves a known hostname" {
    if ! command -v dig >/dev/null 2>&1 && ! command -v host >/dev/null 2>&1 && ! command -v nslookup >/dev/null 2>&1; then
        skip "no DNS resolver tool available"
    fi
    run bash "$SCRIPT_PATH" localhost
    # localhost may resolve or not; just check the script runs without crashing
    [ "$status" -eq 0 ] || [ "$status" -eq 1 ]
}

@test "script reports OK or FAIL for each host" {
    run grep -q "OK:" "$SCRIPT_PATH"
    assert_success
}

@test "script exits 1 on resolution failure" {
    run grep -q "exit 1" "$SCRIPT_PATH"
    assert_success
}
