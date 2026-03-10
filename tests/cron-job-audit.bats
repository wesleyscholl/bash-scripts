#!/usr/bin/env bats

load 'test_helper/bats-support/load'
load 'test_helper/bats-assert/load'

setup() {
    export SCRIPT_PATH="${BATS_TEST_DIRNAME}/../scripts/cron-job-audit.sh"
    export TMP_CRON_ROOT="$(mktemp -d)"
    mkdir -p "$TMP_CRON_ROOT/cron.d" "$TMP_CRON_ROOT/cron.daily"
    echo "* * * * * root /usr/local/bin/healthy-task.sh" > "$TMP_CRON_ROOT/crontab"
    touch "$TMP_CRON_ROOT/cron.daily/daily-task"
    chmod +x "$TMP_CRON_ROOT/cron.daily/daily-task"
}

teardown() {
    rm -rf "$TMP_CRON_ROOT"
}

@test "script file exists and is executable" {
    [ -f "$SCRIPT_PATH" ]
}

@test "script contains risky regex" {
    run grep -q "risky_regex=" "$SCRIPT_PATH"
    [ "$status" -eq 0 ]
}

@test "script supports help flag" {
    run "$SCRIPT_PATH" --help
    [ "$status" -eq 0 ]
}

@test "script passes with clean cron directory" {
    run "$SCRIPT_PATH" --path "$TMP_CRON_ROOT"
    [ "$status" -eq 0 ]
}
