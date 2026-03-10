#!/usr/bin/env bats

load 'test_helper/bats-support/load'
load 'test_helper/bats-assert/load'

setup() {
    export SCRIPT_PATH="${BATS_TEST_DIRNAME}/../scripts/process-zombie-report.sh"
}

@test "script exists" {
    [ -f "$SCRIPT_PATH" ]
}

@test "script checks ps command" {
    run grep -q "command -v ps" "$SCRIPT_PATH"
    [ "$status" -eq 0 ]
}

@test "script supports help" {
    run "$SCRIPT_PATH" --help
    [ "$status" -eq 0 ]
}

@test "script reports no zombies or alerts" {
    run "$SCRIPT_PATH"
    [[ "$status" -eq 0 || "$status" -eq 1 ]]
}
