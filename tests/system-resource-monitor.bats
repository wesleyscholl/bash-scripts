#!/usr/bin/env bats

# Tests for system-resource-monitor.sh

load 'test_helper/bats-support/load'
load 'test_helper/bats-assert/load'

setup() {
    export SCRIPT_PATH="${BATS_TEST_DIRNAME}/../scripts/system-resource-monitor.sh"
    export TEST_LOG="${BATS_TEST_TMPDIR}/resource_monitor.log"
}

teardown() {
    rm -f "$TEST_LOG"
}

@test "script file exists and is executable" {
    [ -f "$SCRIPT_PATH" ]
    [ -x "$SCRIPT_PATH" ]
}

@test "top command available" {
    command -v top
}

@test "free command available or vm_stat fallback" {
    command -v free || command -v vm_stat || skip "memory commands not available"
}

@test "script defines log file variable" {
    run grep -q "LOG_FILE=" "$SCRIPT_PATH"
    [ "$status" -eq 0 ]
}

@test "script defines interval variable" {
    run grep -q "INTERVAL=" "$SCRIPT_PATH"
    [ "$status" -eq 0 ]
}

@test "script has get_cpu_usage function" {
    run grep -q "get_cpu_usage()" "$SCRIPT_PATH"
    [ "$status" -eq 0 ]
}

@test "script has get_memory_usage function" {
    run grep -q "get_memory_usage()" "$SCRIPT_PATH"
    [ "$status" -eq 0 ]
}

@test "script uses infinite while loop" {
    run grep -q "while true" "$SCRIPT_PATH"
    [ "$status" -eq 0 ]
}

@test "script gets timestamp" {
    run grep -q "TIMESTAMP=.*date" "$SCRIPT_PATH"
    [ "$status" -eq 0 ]
}

@test "script logs CPU usage" {
    run grep -q "CPU_USAGE=.*get_cpu_usage" "$SCRIPT_PATH"
    [ "$status" -eq 0 ]
}

@test "script logs memory usage" {
    run grep -q "MEM_USAGE=.*get_memory_usage" "$SCRIPT_PATH"
    [ "$status" -eq 0 ]
}

@test "script uses sleep with interval" {
    run grep -q "sleep.*INTERVAL" "$SCRIPT_PATH"
    [ "$status" -eq 0 ]
}

@test "script appends to log file" {
    run grep -q ">> \"\$LOG_FILE\"" "$SCRIPT_PATH"
    [ "$status" -eq 0 ]
}

@test "CPU usage can be extracted with top" {
    run top -bn1
    [ "$status" -eq 0 ]
}

@test "memory usage can be extracted with free" {
    run free -m 2>/dev/null || run vm_stat
    [ "$status" -eq 0 ]
}
