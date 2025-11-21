#!/usr/bin/env bats

# Tests for splunk-search.sh

load 'test_helper/bats-support/load'
load 'test_helper/bats-assert/load'

setup() {
    export SCRIPT_PATH="${BATS_TEST_DIRNAME}/../scripts/splunk-search.sh"
}

@test "script file exists and is executable" {
    [ -f "$SCRIPT_PATH" ]
    [ -x "$SCRIPT_PATH" ]
}

@test "curl command available" {
    command -v curl
}

@test "script validates argument count" {
    run grep -q "if \[\[.*-z.*SPLUNK_URL" "$SCRIPT_PATH"
    [ "$status" -eq 0 ]
}

@test "script contains usage message" {
    run grep -q "Usage:" "$SCRIPT_PATH"
    [ "$status" -eq 0 ]
}

@test "script uses Splunk URL variable" {
    run grep -q "SPLUNK_URL=\$1" "$SCRIPT_PATH"
    [ "$status" -eq 0 ]
}

@test "script uses username variable" {
    run grep -q "USERNAME=\$2" "$SCRIPT_PATH"
    [ "$status" -eq 0 ]
}

@test "script uses password variable" {
    run grep -q "PASSWORD=\$3" "$SCRIPT_PATH"
    [ "$status" -eq 0 ]
}

@test "script uses query variable" {
    run grep -q "QUERY=\$4" "$SCRIPT_PATH"
    [ "$status" -eq 0 ]
}

@test "script uses output file variable" {
    run grep -q "OUTPUT_FILE=\$5" "$SCRIPT_PATH"
    [ "$status" -eq 0 ]
}

@test "script uses POST method" {
    run grep -q "curl -X POST" "$SCRIPT_PATH"
    [ "$status" -eq 0 ]
}

@test "script includes authentication" {
    run grep -q "\-u.*USERNAME:.*PASSWORD" "$SCRIPT_PATH"
    [ "$status" -eq 0 ]
}

@test "script uses search endpoint" {
    run grep -q "services/search/jobs" "$SCRIPT_PATH"
    [ "$status" -eq 0 ]
}

@test "script sends search parameter" {
    run grep -q "\-d \"search=\$QUERY\"" "$SCRIPT_PATH"
    [ "$status" -eq 0 ]
}

@test "script requests JSON output" {
    run grep -q "output_mode=json" "$SCRIPT_PATH"
    [ "$status" -eq 0 ]
}

@test "script saves output to file" {
    run grep -q "\-o.*OUTPUT_FILE" "$SCRIPT_PATH"
    [ "$status" -eq 0 ]
}

@test "script provides completion message" {
    run grep -q "Saved Splunk query results" "$SCRIPT_PATH"
    [ "$status" -eq 0 ]
}
