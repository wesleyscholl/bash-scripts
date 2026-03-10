#!/usr/bin/env bats

load 'test_helper/bats-support/load'
load 'test_helper/bats-assert/load'

setup() {
    SCRIPT_PATH="$(cd "$(dirname "$BATS_TEST_FILENAME")/.." && pwd)/scripts/mysql-slow-query-report.sh"
    export SCRIPT_PATH
    chmod +x "$SCRIPT_PATH"
    TEST_DIR=$(mktemp -d)
    export TEST_DIR
}

teardown() {
    rm -rf "$TEST_DIR"
}

@test "script file exists and is executable" {
    [ -f "$SCRIPT_PATH" ]
    [ -x "$SCRIPT_PATH" ]
}

@test "script defines TOP_N variable" {
    run grep -q "^TOP_N=" "$SCRIPT_PATH"
    assert_success
}

@test "--help flag exits with status 0" {
    run bash "$SCRIPT_PATH" --help
    assert_success
    assert_output --partial "Usage:"
}

@test "missing log file argument exits with error" {
    run bash "$SCRIPT_PATH"
    assert_failure
}

@test "script exits with error for nonexistent log file" {
    run bash "$SCRIPT_PATH" /nonexistent/slow.log
    assert_failure
}

@test "script reports no queries found for empty log" {
    local empty_log="${TEST_DIR}/empty.log"
    touch "$empty_log"
    run bash "$SCRIPT_PATH" "$empty_log"
    assert_success
    assert_output --partial "No slow queries"
}

@test "script reports query time from sample log" {
    local sample_log="${TEST_DIR}/slow.log"
    cat > "$sample_log" << 'EOF'
# Query_time: 3.456000 Lock_time: 0.000123 Rows_sent: 1 Rows_examined: 10000
SELECT * FROM users WHERE email = 'test@example.com';
EOF
    run bash "$SCRIPT_PATH" "$sample_log"
    assert_success
    assert_output --partial "3.456"
}

@test "script validates top is positive integer" {
    local log="${TEST_DIR}/empty.log"
    touch "$log"
    run bash "$SCRIPT_PATH" --top 0 "$log"
    assert_failure
}

@test "script uses awk to parse log" {
    run grep -q "awk" "$SCRIPT_PATH"
    assert_success
}
