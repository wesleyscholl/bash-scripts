#!/usr/bin/env bats

# Tests for rsync-backup.sh

load 'test_helper/bats-support/load'
load 'test_helper/bats-assert/load'

setup() {
    export SCRIPT_PATH="${BATS_TEST_DIRNAME}/../scripts/rsync-backup.sh"
    export TEST_LOG="${BATS_TEST_TMPDIR}/backup.log"
}

teardown() {
    rm -f "$TEST_LOG"
}

@test "script file exists and is executable" {
    [ -f "$SCRIPT_PATH" ]
    [ -x "$SCRIPT_PATH" ]
}

@test "rsync command available" {
    command -v rsync
}

@test "script defines source directory variable" {
    run grep -q "SOURCE_DIR=" "$SCRIPT_PATH"
    [ "$status" -eq 0 ]
}

@test "script defines destination user variable" {
    run grep -q "DEST_USER=" "$SCRIPT_PATH"
    [ "$status" -eq 0 ]
}

@test "script defines destination host variable" {
    run grep -q "DEST_HOST=" "$SCRIPT_PATH"
    [ "$status" -eq 0 ]
}

@test "script defines destination directory variable" {
    run grep -q "DEST_DIR=" "$SCRIPT_PATH"
    [ "$status" -eq 0 ]
}

@test "script defines log file variable" {
    run grep -q "LOG_FILE=" "$SCRIPT_PATH"
    [ "$status" -eq 0 ]
}

@test "script uses rsync with archive and compress flags" {
    run grep -q "rsync -avz" "$SCRIPT_PATH"
    [ "$status" -eq 0 ]
}

@test "script uses delete flag" {
    run grep -q "\-\-delete" "$SCRIPT_PATH"
    [ "$status" -eq 0 ]
}

@test "script redirects output to log file" {
    run grep -q ">> \"\$LOG_FILE\"" "$SCRIPT_PATH"
    [ "$status" -eq 0 ]
}

@test "script checks rsync exit status" {
    run grep -q "if \[ \$? -eq 0 \]" "$SCRIPT_PATH"
    [ "$status" -eq 0 ]
}

@test "script logs success message" {
    run grep -q "Backup successful" "$SCRIPT_PATH"
    [ "$status" -eq 0 ]
}

@test "script logs failure message" {
    run grep -q "Backup failed" "$SCRIPT_PATH"
    [ "$status" -eq 0 ]
}

@test "script includes timestamp in log" {
    run grep -q "date.*%Y-%m-%d %H:%M:%S" "$SCRIPT_PATH"
    [ "$status" -eq 0 ]
}
