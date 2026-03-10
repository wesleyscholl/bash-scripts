#!/usr/bin/env bats

load 'test_helper/bats-support/load'
load 'test_helper/bats-assert/load'

setup() {
    SCRIPT_PATH="$(cd "$(dirname "$BATS_TEST_FILENAME")/.." && pwd)/scripts/disk-throughput-test.sh"
    export SCRIPT_PATH
    chmod +x "$SCRIPT_PATH"
}

@test "script file exists and is executable" {
    [ -f "$SCRIPT_PATH" ]
    [ -x "$SCRIPT_PATH" ]
}

@test "script defines FILE_SIZE_MB variable" {
    run grep -q "FILE_SIZE_MB=" "$SCRIPT_PATH"
    assert_success
}

@test "--help flag exits with status 0" {
    run bash "$SCRIPT_PATH" --help
    assert_success
    assert_output --partial "Usage:"
}

@test "script rejects non-numeric size" {
    run bash "$SCRIPT_PATH" --size abc
    assert_failure
}

@test "script exits with error for nonexistent directory" {
    run bash "$SCRIPT_PATH" /nonexistent/dir
    assert_failure
}

@test "script requires dd command" {
    run grep -q "dd" "$SCRIPT_PATH"
    assert_success
}

@test "script performs write test" {
    run grep -q "Write test" "$SCRIPT_PATH"
    assert_success
}

@test "script performs read test" {
    run grep -q "Read test" "$SCRIPT_PATH"
    assert_success
}

@test "script runs benchmark on /tmp with small file" {
    if ! command -v dd >/dev/null 2>&1; then skip "dd not available"; fi
    run bash "$SCRIPT_PATH" --size 1 /tmp
    assert_success
    assert_output --partial "Benchmark complete"
}
