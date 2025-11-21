#!/usr/bin/env bats

# Tests for system-resource-reporter.sh

load 'test_helper/bats-support/load'
load 'test_helper/bats-assert/load'

setup() {
    export SCRIPT_PATH="${BATS_TEST_DIRNAME}/../scripts/system-resource-reporter.sh"
}

@test "script file exists and is executable" {
    [ -f "$SCRIPT_PATH" ]
    [ -x "$SCRIPT_PATH" ]
}

@test "script defines output file variable" {
    run grep -q "OUTPUT_FILE=" "$SCRIPT_PATH"
    [ "$status" -eq 0 ]
}

@test "script defines show CPU variable" {
    run grep -q "SHOW_CPU=" "$SCRIPT_PATH"
    [ "$status" -eq 0 ]
}

@test "script defines show memory variable" {
    run grep -q "SHOW_MEMORY=" "$SCRIPT_PATH"
    [ "$status" -eq 0 ]
}

@test "script defines show disk variable" {
    run grep -q "SHOW_DISK=" "$SCRIPT_PATH"
    [ "$status" -eq 0 ]
}

@test "script defines show network variable" {
    run grep -q "SHOW_NETWORK=" "$SCRIPT_PATH"
    [ "$status" -eq 0 ]
}

@test "script defines output format variable" {
    run grep -q "OUTPUT_FORMAT=" "$SCRIPT_PATH"
    [ "$status" -eq 0 ]
}

@test "script has show_usage function" {
    run grep -q "show_usage()" "$SCRIPT_PATH"
    [ "$status" -eq 0 ]
}

@test "script has get_cpu_info function" {
    run grep -q "get_cpu_info()" "$SCRIPT_PATH"
    [ "$status" -eq 0 ]
}

@test "script has get_memory_info function" {
    run grep -q "get_memory_info()" "$SCRIPT_PATH"
    [ "$status" -eq 0 ]
}

@test "script has get_disk_info function" {
    run grep -q "get_disk_info()" "$SCRIPT_PATH"
    [ "$status" -eq 0 ]
}

@test "script has get_network_info function" {
    run grep -q "get_network_info()" "$SCRIPT_PATH"
    [ "$status" -eq 0 ]
}

@test "script has format_table function" {
    run grep -q "format_table()" "$SCRIPT_PATH"
    [ "$status" -eq 0 ]
}

@test "script has format_json function" {
    run grep -q "format_json()" "$SCRIPT_PATH"
    [ "$status" -eq 0 ]
}

@test "script has format_csv function" {
    run grep -q "format_csv()" "$SCRIPT_PATH"
    [ "$status" -eq 0 ]
}

@test "script accepts output flag" {
    run grep -q "\-o|\-\-output" "$SCRIPT_PATH"
    [ "$status" -eq 0 ]
}

@test "script accepts cpu-only flag" {
    run grep -q "\-c|\-\-cpu-only" "$SCRIPT_PATH"
    [ "$status" -eq 0 ]
}

@test "script accepts memory-only flag" {
    run grep -q "\-m|\-\-memory-only" "$SCRIPT_PATH"
    [ "$status" -eq 0 ]
}

@test "script accepts disk-only flag" {
    run grep -q "\-d|\-\-disk-only" "$SCRIPT_PATH"
    [ "$status" -eq 0 ]
}

@test "script accepts network-only flag" {
    run grep -q "\-n|\-\-network-only" "$SCRIPT_PATH"
    [ "$status" -eq 0 ]
}

@test "script accepts format flag" {
    run grep -q "\-f|\-\-format" "$SCRIPT_PATH"
    [ "$status" -eq 0 ]
}

@test "script validates format values" {
    run grep -q "table.*json.*csv" "$SCRIPT_PATH"
    [ "$status" -eq 0 ]
}

@test "script checks for CPU model" {
    run grep -q "model name.*cpuinfo" "$SCRIPT_PATH"
    [ "$status" -eq 0 ]
}

@test "script counts CPU cores" {
    run grep -q "processor.*cpuinfo" "$SCRIPT_PATH"
    [ "$status" -eq 0 ]
}

@test "script gets load average" {
    run grep -q "uptime.*load average" "$SCRIPT_PATH"
    [ "$status" -eq 0 ]
}

@test "script checks for free command" {
    run grep -q "command -v free" "$SCRIPT_PATH"
    [ "$status" -eq 0 ]
}

@test "script checks for df command" {
    run grep -q "command -v df" "$SCRIPT_PATH"
    [ "$status" -eq 0 ]
}

@test "script reads /proc/net/dev for network stats" {
    run grep -q "/proc/net/dev" "$SCRIPT_PATH"
    [ "$status" -eq 0 ]
}
