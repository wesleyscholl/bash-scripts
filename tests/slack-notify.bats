#!/usr/bin/env bats

# Tests for slack-notify.sh

load 'test_helper/bats-support/load'
load 'test_helper/bats-assert/load'

setup() {
    export SCRIPT_PATH="${BATS_TEST_DIRNAME}/../scripts/slack-notify.sh"
}

@test "script file exists and is executable" {
    [ -f "$SCRIPT_PATH" ]
    [ -x "$SCRIPT_PATH" ]
}

@test "curl command available" {
    command -v curl
}

@test "script contains webhook URL variable" {
    run grep -q "WEBHOOK_URL" "$SCRIPT_PATH"
    [ "$status" -eq 0 ]
}

@test "script contains message variable" {
    run grep -q "MESSAGE" "$SCRIPT_PATH"
    [ "$status" -eq 0 ]
}

@test "script contains channel variable" {
    run grep -q "CHANNEL" "$SCRIPT_PATH"
    [ "$status" -eq 0 ]
}

@test "script uses POST method" {
    run grep -q "POST" "$SCRIPT_PATH"
    [ "$status" -eq 0 ]
}

@test "script sends JSON payload" {
    run grep -q "application/json" "$SCRIPT_PATH"
    [ "$status" -eq 0 ]
}

@test "script includes channel in payload" {
    run grep -q "channel" "$SCRIPT_PATH"
    [ "$status" -eq 0 ]
}

@test "script includes text in payload" {
    run grep -q "text" "$SCRIPT_PATH"
    [ "$status" -eq 0 ]
}

@test "script provides confirmation message" {
    run grep -q "Notification sent" "$SCRIPT_PATH"
    [ "$status" -eq 0 ]
}

@test "webhook URL follows Slack format" {
    webhook=$(grep "WEBHOOK_URL=" "$SCRIPT_PATH" | cut -d'"' -f2)
    [[ "$webhook" =~ ^https://hooks.slack.com ]]
}
