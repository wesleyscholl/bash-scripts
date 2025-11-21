#!/usr/bin/env bats

# Tests for scp-remote-backup.sh

load 'test_helper/bats-support/load'
load 'test_helper/bats-assert/load'

setup() {
    export SCRIPT_PATH="${BATS_TEST_DIRNAME}/../scripts/scp-remote-backup.sh"
    export TEST_DIR="${BATS_TEST_TMPDIR}/scp_test"
    mkdir -p "$TEST_DIR"
}

teardown() {
    rm -rf "$TEST_DIR"
}

@test "script file exists and is executable" {
    [ -f "$SCRIPT_PATH" ]
    [ -x "$SCRIPT_PATH" ]
}

@test "tar command available" {
    command -v tar
}

@test "scp command available" {
    command -v scp
}

@test "script defines log directory variable" {
    run grep -q "LOG_DIR=" "$SCRIPT_PATH"
    [ "$status" -eq 0 ]
}

@test "script defines backup directory variable" {
    run grep -q "BACKUP_DIR=" "$SCRIPT_PATH"
    [ "$status" -eq 0 ]
}

@test "script generates archive name with timestamp" {
    run grep -q "ARCHIVE_NAME=.*date" "$SCRIPT_PATH"
    [ "$status" -eq 0 ]
}

@test "script defines remote user variable" {
    run grep -q "REMOTE_USER=" "$SCRIPT_PATH"
    [ "$status" -eq 0 ]
}

@test "script defines remote host variable" {
    run grep -q "REMOTE_HOST=" "$SCRIPT_PATH"
    [ "$status" -eq 0 ]
}

@test "script defines remote directory variable" {
    run grep -q "REMOTE_DIR=" "$SCRIPT_PATH"
    [ "$status" -eq 0 ]
}

@test "script creates tar archive" {
    run grep -q "tar -czf" "$SCRIPT_PATH"
    [ "$status" -eq 0 ]
}

@test "script transfers archive via scp" {
    run grep -q "scp.*REMOTE_USER@\$REMOTE_HOST" "$SCRIPT_PATH"
    [ "$status" -eq 0 ]
}

@test "script cleans up local backup" {
    run grep -q "rm.*ARCHIVE_NAME" "$SCRIPT_PATH"
    [ "$status" -eq 0 ]
}

@test "script provides completion message" {
    run grep -q "Logs backed up" "$SCRIPT_PATH"
    [ "$status" -eq 0 ]
}

@test "can create tar archive" {
    echo "test" > "${TEST_DIR}/test.txt"
    run tar -czf "${TEST_DIR}/test.tar.gz" -C "$TEST_DIR" .
    [ "$status" -eq 0 ]
}
