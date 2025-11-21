#!/usr/bin/env bats

# Tests for system-monitoring.sh

load 'test_helper/bats-support/load'
load 'test_helper/bats-assert/load'

setup() {
    export SCRIPT_PATH="${BATS_TEST_DIRNAME}/../scripts/system-monitoring.sh"
    export TEST_LOG="${BATS_TEST_TMPDIR}/system_monitor.log"
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

@test "df command available" {
    command -v df
}

@test "mail command available" {
    command -v mail || command -v sendmail || skip "mail command not available"
}

@test "script defines CPU threshold" {
    run grep -q "CPU_THRESHOLD" "$SCRIPT_PATH"
    [ "$status" -eq 0 ]
}

@test "script defines memory threshold" {
    run grep -q "MEM_THRESHOLD" "$SCRIPT_PATH"
    [ "$status" -eq 0 ]
}

@test "script defines disk threshold" {
    run grep -q "DISK_THRESHOLD" "$SCRIPT_PATH"
    [ "$status" -eq 0 ]
}

@test "script has log file variable" {
    run grep -q "LOGFILE" "$SCRIPT_PATH"
    [ "$status" -eq 0 ]
}

@test "script contains send_alert function" {
    run grep -q "send_alert()" "$SCRIPT_PATH"
    [ "$status" -eq 0 ]
}

@test "script checks CPU usage" {
    run grep -q "cpu_usage" "$SCRIPT_PATH"
    [ "$status" -eq 0 ]
}

@test "script checks memory usage" {
    run grep -q "mem_usage" "$SCRIPT_PATH"
    [ "$status" -eq 0 ]
}

@test "script checks disk usage" {
    run grep -q "disk_usage" "$SCRIPT_PATH"
    [ "$status" -eq 0 ]
}

@test "script logs monitoring events" {
    run grep -q ">> \"\$LOGFILE\"" "$SCRIPT_PATH"
    [ "$status" -eq 0 ]
}

@test "CPU usage can be calculated" {
    run top -bn1
    [ "$status" -eq 0 ]
}

@test "memory usage can be calculated" {
    run free 2>/dev/null || run vm_stat
    [ "$status" -eq 0 ]
}

@test "disk usage can be calculated" {
    run df /
    [ "$status" -eq 0 ]
}
