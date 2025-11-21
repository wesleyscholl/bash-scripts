#!/usr/bin/env bats

# Tests for disk-usage-monitor.sh

load 'test_helper/bats-support/load'
load 'test_helper/bats-assert/load'

setup() {
    export SCRIPT_PATH="${BATS_TEST_DIRNAME}/../scripts/disk-usage-monitor.sh"
    export TEST_DIR="${BATS_TEST_TMPDIR}/disk_usage_test"
    mkdir -p "$TEST_DIR"
}

teardown() {
    rm -rf "$TEST_DIR"
}

@test "script file exists and is executable" {
    [ -f "$SCRIPT_PATH" ]
    [ -x "$SCRIPT_PATH" ]
}

@test "df command available" {
    command -v df
}

@test "awk command available" {
    command -v awk
}

@test "mail command available or sendmail fallback" {
    command -v mail || command -v sendmail || skip "mail command not available"
}

@test "script contains threshold variable" {
    run grep -q "THRESHOLD" "$SCRIPT_PATH"
    [ "$status" -eq 0 ]
}

@test "script contains email alert variable" {
    run grep -q "ALERT_EMAIL" "$SCRIPT_PATH"
    [ "$status" -eq 0 ]
}

@test "disk usage percentage can be extracted" {
    run df -h
    [ "$status" -eq 0 ]
    # Check if output contains percentage values
    [[ "$output" =~ [0-9]+% ]]
}

@test "script checks disk usage properly" {
    run grep -q "df -h" "$SCRIPT_PATH"
    [ "$status" -eq 0 ]
}

@test "script uses sed to remove percentage symbol" {
    run grep -q "sed 's/%//'" "$SCRIPT_PATH"
    [ "$status" -eq 0 ]
}

@test "script has threshold comparison logic" {
    run grep -q "if \[" "$SCRIPT_PATH"
    [ "$status" -eq 0 ]
}

@test "mount points are identified correctly" {
    run sh -c "df -h | awk '{if(NR>1) print \$6}' | head -1"
    [ "$status" -eq 0 ]
    [ -n "$output" ]
}

@test "usage percentage can be calculated" {
    usage=$(df -h | awk '{if(NR>1) print $5}' | head -1 | sed 's/%//')
    [[ "$usage" =~ ^[0-9]+$ ]]
}
