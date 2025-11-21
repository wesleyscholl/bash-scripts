#!/usr/bin/env bats

# Tests for monitor-open-ports.sh

load 'test_helper/bats-support/load'
load 'test_helper/bats-assert/load'

setup() {
    export SCRIPT_PATH="${BATS_TEST_DIRNAME}/../scripts/monitor-open-ports.sh"
    export TEST_DIR="${BATS_TEST_TMPDIR}/ports_test"
    mkdir -p "$TEST_DIR"
}

teardown() {
    rm -rf "$TEST_DIR"
}

@test "script file exists and is executable" {
    [ -f "$SCRIPT_PATH" ]
    [ -x "$SCRIPT_PATH" ]
}

@test "netstat command available or ss fallback" {
    command -v netstat || command -v ss || skip "netstat/ss not available"
}

@test "awk command available" {
    command -v awk
}

@test "script defines output file variable" {
    run grep -q "OUTPUT_FILE=" "$SCRIPT_PATH"
    [ "$status" -eq 0 ]
}

@test "script includes timestamp in output file" {
    run grep -q "date +%Y%m%d" "$SCRIPT_PATH"
    [ "$status" -eq 0 ]
}

@test "script uses netstat command" {
    run grep -q "netstat -tuln" "$SCRIPT_PATH"
    [ "$status" -eq 0 ]
}

@test "script uses awk to process output" {
    run grep -q "awk.*NR>2.*print" "$SCRIPT_PATH"
    [ "$status" -eq 0 ]
}

@test "script redirects output to file" {
    run grep -q "> \"\$OUTPUT_FILE\"" "$SCRIPT_PATH"
    [ "$status" -eq 0 ]
}

@test "script provides completion message" {
    run grep -q "Open ports logged" "$SCRIPT_PATH"
    [ "$status" -eq 0 ]
}

@test "netstat can list network connections" {
    run netstat -tuln 2>/dev/null || run ss -tuln
    [ "$status" -eq 0 ]
}

@test "awk can process network output" {
    output=$(netstat -tuln 2>/dev/null | awk 'NR>2 {print $4}' | head -1) || \
    output=$(ss -tuln 2>/dev/null | awk 'NR>2 {print $5}' | head -1)
    [ "$status" -eq 0 ]
}
