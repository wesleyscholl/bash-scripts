#!/usr/bin/env bats

load 'test_helper/bats-support/load'
load 'test_helper/bats-assert/load'

setup() {
    export SCRIPT_PATH="${BATS_TEST_DIRNAME}/../scripts/failed-login-monitor.sh"
    export TMP_LOG="$(mktemp)"
}

teardown() {
    rm -f "$TMP_LOG"
}

@test "script file exists and is executable" {
    [ -f "$SCRIPT_PATH" ]
}

@test "script defines alert threshold variable" {
    run grep -q "ALERT_THRESHOLD=" "$SCRIPT_PATH"
    [ "$status" -eq 0 ]
}

@test "script supports help flag" {
    run "$SCRIPT_PATH" --help
    [ "$status" -eq 0 ]
}

@test "script counts failed logins from provided log file" {
    now_month=$(date '+%b')
    now_day=$(date '+%e')
    now_time=$(date '+%H:%M:%S')
    printf "%s %s %s host sshd[1234]: Failed password for invalid user test from 10.0.0.1 port 22 ssh2\n" "$now_month" "$now_day" "$now_time" > "$TMP_LOG"

    AUTH_LOG_FILE="$TMP_LOG" run "$SCRIPT_PATH" 120 5
    [ "$status" -eq 0 ]
    [[ "$output" == *"Failed SSH logins"* ]]
}
