#!/usr/bin/env bats

# Tests for rotate-old-files.sh

load 'test_helper/bats-support/load'
load 'test_helper/bats-assert/load'

setup() {
    export SCRIPT_PATH="${BATS_TEST_DIRNAME}/../scripts/rotate-old-files.sh"
    export TEST_DIR="${BATS_TEST_TMPDIR}/rotate_test"
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

@test "script defines target directory variable" {
    run grep -q "TARGET_DIR=" "$SCRIPT_PATH"
    [ "$status" -eq 0 ]
}

@test "script defines days variable" {
    run grep -q "DAYS=" "$SCRIPT_PATH"
    [ "$status" -eq 0 ]
}

@test "script uses find command" {
    run grep -q "find.*TARGET_DIR" "$SCRIPT_PATH"
    [ "$status" -eq 0 ]
}

@test "script searches for files only" {
    run grep -q "\-type f" "$SCRIPT_PATH"
    [ "$status" -eq 0 ]
}

@test "script uses modification time filter" {
    run grep -q "\-mtime +\$DAYS" "$SCRIPT_PATH"
    [ "$status" -eq 0 ]
}

@test "script executes rm on files" {
    run grep -q "\-exec rm -f" "$SCRIPT_PATH"
    [ "$status" -eq 0 ]
}

@test "script provides completion message" {
    run grep -q "Files older than.*days have been deleted" "$SCRIPT_PATH"
    [ "$status" -eq 0 ]
}

@test "find can search for old files" {
    # Create an old file (touch with -t can set timestamp)
    touch "${TEST_DIR}/test.txt"
    run find "$TEST_DIR" -type f -name "*.txt"
    [ "$status" -eq 0 ]
    [[ "$output" =~ "test.txt" ]]
}

@test "can delete files with find exec" {
    touch "${TEST_DIR}/delete_me.txt"
    run find "$TEST_DIR" -name "delete_me.txt" -exec rm -f {} \;
    [ "$status" -eq 0 ]
    [ ! -f "${TEST_DIR}/delete_me.txt" ]
}
