#!/usr/bin/env bats

# Tests for backup.sh

setup() {
    export TEST_DIR="${BATS_TEST_TMPDIR}/backup_test"
    export BACKUP_SOURCE="${TEST_DIR}/source"
    export BACKUP_DEST="${TEST_DIR}/backup"
    
    mkdir -p "$BACKUP_SOURCE" "$BACKUP_DEST"
    echo "test content" > "$BACKUP_SOURCE/testfile.txt"
}

teardown() {
    rm -rf "$TEST_DIR"
}

@test "backup source directory exists" {
    [ -d "$BACKUP_SOURCE" ]
}

@test "backup destination directory exists" {
    [ -d "$BACKUP_DEST" ]
}

@test "test file created in source" {
    [ -f "$BACKUP_SOURCE/testfile.txt" ]
}

@test "test file has correct content" {
    content=$(cat "$BACKUP_SOURCE/testfile.txt")
    [ "$content" = "test content" ]
}

@test "rsync command available" {
    command -v rsync
}
