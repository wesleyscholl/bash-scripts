#!/usr/bin/env bats

load 'test_helper/bats-support/load'
load 'test_helper/bats-assert/load'

setup() {
    export SCRIPT_PATH="${BATS_TEST_DIRNAME}/../scripts/docker-image-age-report.sh"
}

@test "script exists" {
    [ -f "$SCRIPT_PATH" ]
}

@test "script checks docker dependency" {
    run grep -q "command -v docker" "$SCRIPT_PATH"
    [ "$status" -eq 0 ]
}

@test "script supports help" {
    run "$SCRIPT_PATH" --help
    [ "$status" -eq 0 ]
}

@test "script rejects invalid days" {
    run "$SCRIPT_PATH" bad
    [ "$status" -eq 1 ]
}
