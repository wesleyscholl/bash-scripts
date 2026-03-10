#!/usr/bin/env bats

load 'test_helper/bats-support/load'
load 'test_helper/bats-assert/load'

setup() {
    export SCRIPT_PATH="${BATS_TEST_DIRNAME}/../scripts/url-encode.sh"
}

@test "script exists" {
    [ -f "$SCRIPT_PATH" ]
}

@test "script supports help" {
    run "$SCRIPT_PATH" --help
    [ "$status" -eq 0 ]
}

@test "script encodes spaces" {
    run "$SCRIPT_PATH" "hello world"
    [ "$status" -eq 0 ]
    [ "$output" = "hello%20world" ]
}

@test "script contains encoding loop" {
    run grep -q "for (( i=0; i<\${#INPUT}; i++ ))" "$SCRIPT_PATH"
    [ "$status" -eq 0 ]
}
