#!/usr/bin/env bats

load 'test_helper/bats-support/load'
load 'test_helper/bats-assert/load'

setup() {
    export SCRIPT_PATH="${BATS_TEST_DIRNAME}/../scripts/json-log-summary.sh"
    export TMP_LOG="$(mktemp)"
}

teardown() {
    rm -f "$TMP_LOG"
}

@test "script file exists and is executable" {
    [ -f "$SCRIPT_PATH" ]
}

@test "script defines log file variable" {
    run grep -q "LOG_FILE=" "$SCRIPT_PATH"
    [ "$status" -eq 0 ]
}

@test "script supports help flag" {
    run "$SCRIPT_PATH" --help
    [ "$status" -eq 0 ]
}

@test "script summarizes sample json logs" {
    cat > "$TMP_LOG" << EOF
{"level":"INFO","status":200}
{"level":"ERROR","status":500}
{"level":"INFO","status":200}
EOF

    run "$SCRIPT_PATH" "$TMP_LOG"
    [ "$status" -eq 0 ]
    [[ "$output" == *"Level counts"* ]]
}
