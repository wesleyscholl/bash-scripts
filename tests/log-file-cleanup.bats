#!/usr/bin/env bats

# Tests for log-file-cleanup.sh

load 'test_helper/bats-support/load'
load 'test_helper/bats-assert/load'

setup() {
    export SCRIPT_PATH="${BATS_TEST_DIRNAME}/../scripts/log-file-cleanup.sh"
    export TEST_DIR="${BATS_TEST_TMPDIR}/log_cleanup_test"
    mkdir -p "$TEST_DIR"
}

teardown() {
    rm -rf "$TEST_DIR"
}

@test "script file exists and is executable" {
    [ -f "$SCRIPT_PATH" ]
    [ -x "$SCRIPT_PATH" ]
}

@test "find command available" {
    command -v find
}

@test "gzip command available" {
    command -v gzip
}

@test "script defines log directory variable" {
    run grep -q "LOG_DIR=" "$SCRIPT_PATH"
    [ "$status" -eq 0 ]
}

@test "script uses find command" {
    run grep -q "find.*LOG_DIR" "$SCRIPT_PATH"
    [ "$status" -eq 0 ]
}

@test "script searches for log files" {
    run grep -q "\-name \"\*.log\"" "$SCRIPT_PATH"
    [ "$status" -eq 0 ]
}

@test "script uses size filter" {
    run grep -q "\-size +1M" "$SCRIPT_PATH"
    [ "$status" -eq 0 ]
}

@test "script executes gzip on files" {
    run grep -q "\-exec gzip" "$SCRIPT_PATH"
    [ "$status" -eq 0 ]
}

@test "script provides completion message" {
    run grep -q "Log file cleanup completed" "$SCRIPT_PATH"
    [ "$status" -eq 0 ]
}

@test "find can locate files" {
    touch "${TEST_DIR}/test.log"
    run find "$TEST_DIR" -name "*.log"
    [ "$status" -eq 0 ]
    [[ "$output" =~ "test.log" ]]
}

@test "gzip can compress files" {
    echo "test content" > "${TEST_DIR}/test.log"
    run gzip "${TEST_DIR}/test.log"
    [ "$status" -eq 0 ]
    [ -f "${TEST_DIR}/test.log.gz" ]
}
