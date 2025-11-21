#!/usr/bin/env bats

# Tests for account-expiry-notify.sh

load 'test_helper/bats-support/load'
load 'test_helper/bats-assert/load'

setup() {
    export SCRIPT_PATH="${BATS_TEST_DIRNAME}/../scripts/account-expiry-notify.sh"
}

@test "script file exists and is executable" {
    [ -f "$SCRIPT_PATH" ]
    [ -x "$SCRIPT_PATH" ]
}

@test "date command available" {
    command -v date
}

@test "chage command available" {
    command -v chage || skip "chage not available"
}

@test "script defines threshold variable" {
    run grep -q "THRESHOLD=" "$SCRIPT_PATH"
    [ "$status" -eq 0 ]
}

@test "script checks user accounts" {
    run grep -q "Checking user accounts" "$SCRIPT_PATH"
    [ "$status" -eq 0 ]
}

@test "script uses while read loop" {
    run grep -q "while IFS=: read" "$SCRIPT_PATH"
    [ "$status" -eq 0 ]
}

@test "script validates date format" {
    run grep -q "\[0-9\]{4}-\[0-9\]{2}-\[0-9\]{2}" "$SCRIPT_PATH"
    [ "$status" -eq 0 ]
}

@test "script calculates days left" {
    run grep -q "days_left=" "$SCRIPT_PATH"
    [ "$status" -eq 0 ]
}

@test "script compares days with threshold" {
    run grep -q "if \[.*days_left.*THRESHOLD" "$SCRIPT_PATH"
    [ "$status" -eq 0 ]
}

@test "script uses chage command" {
    run grep -q "chage -l" "$SCRIPT_PATH"
    [ "$status" -eq 0 ]
}

@test "script checks account expiry" {
    run grep -q "Account expires" "$SCRIPT_PATH"
    [ "$status" -eq 0 ]
}

@test "can calculate date difference" {
    future_date=$(date -d "+7 days" +%Y-%m-%d 2>/dev/null || date -v+7d +%Y-%m-%d)
    [ -n "$future_date" ]
}
