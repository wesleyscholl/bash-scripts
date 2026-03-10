#!/usr/bin/env bats

load 'test_helper/bats-support/load'
load 'test_helper/bats-assert/load'

setup() {
    export SCRIPT_PATH="${BATS_TEST_DIRNAME}/../scripts/github-release-check.sh"
}

@test "script exists" {
    [ -f "$SCRIPT_PATH" ]
}

@test "script defines repo variable" {
    run grep -q "REPO=" "$SCRIPT_PATH"
    [ "$status" -eq 0 ]
}

@test "script supports help" {
    run "$SCRIPT_PATH" --help
    [ "$status" -eq 0 ]
}

@test "script validates curl dependency" {
    run grep -q "command -v curl" "$SCRIPT_PATH"
    [ "$status" -eq 0 ]
}
