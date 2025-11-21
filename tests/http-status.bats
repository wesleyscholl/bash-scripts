#!/usr/bin/env bats

# Tests for http-status.sh

load 'test_helper/bats-support/load'
load 'test_helper/bats-assert/load'

setup() {
    export SCRIPT_PATH="${BATS_TEST_DIRNAME}/../scripts/http-status.sh"
}

@test "script file exists and is executable" {
    [ -f "$SCRIPT_PATH" ]
    [ -x "$SCRIPT_PATH" ]
}

@test "curl command available" {
    command -v curl
}

@test "script defines URL variable" {
    run grep -q "URL=" "$SCRIPT_PATH"
    [ "$status" -eq 0 ]
}

@test "script defines expected code variable" {
    run grep -q "EXPECTED_CODE=" "$SCRIPT_PATH"
    [ "$status" -eq 0 ]
}

@test "script fetches HTTP status code" {
    run grep -q "STATUS_CODE=.*curl.*http_code" "$SCRIPT_PATH"
    [ "$status" -eq 0 ]
}

@test "script uses silent flag" {
    run grep -q "curl.*-s" "$SCRIPT_PATH"
    [ "$status" -eq 0 ]
}

@test "script uses output to null" {
    run grep -q "curl.*-o /dev/null" "$SCRIPT_PATH"
    [ "$status" -eq 0 ]
}

@test "script compares status code" {
    run grep -q "if \[.*STATUS_CODE.*EXPECTED_CODE" "$SCRIPT_PATH"
    [ "$status" -eq 0 ]
}

@test "script reports website up status" {
    run grep -q "Website is up" "$SCRIPT_PATH"
    [ "$status" -eq 0 ]
}

@test "script reports website down status" {
    run grep -q "Website is down" "$SCRIPT_PATH"
    [ "$status" -eq 0 ]
}

@test "curl can fetch HTTP status code" {
    run curl -o /dev/null -s -w "%{http_code}\n" https://google.com
    [ "$status" -eq 0 ]
    [[ "$output" =~ ^[0-9]{3}$ ]]
}
