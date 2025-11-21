#!/usr/bin/env bats

# Tests for restart-containers.sh

load 'test_helper/bats-support/load'
load 'test_helper/bats-assert/load'

setup() {
    export SCRIPT_PATH="${BATS_TEST_DIRNAME}/../scripts/restart-containers.sh"
}

@test "script file exists and is executable" {
    [ -f "$SCRIPT_PATH" ]
    [ -x "$SCRIPT_PATH" ]
}

@test "docker command available" {
    command -v docker || skip "docker not installed"
}

@test "script validates argument count" {
    run grep -q "if \[\[.*-z.*CONTAINER_NAME" "$SCRIPT_PATH"
    [ "$status" -eq 0 ]
}

@test "script contains usage message" {
    run grep -q "Usage:" "$SCRIPT_PATH"
    [ "$status" -eq 0 ]
}

@test "script uses container name variable" {
    run grep -q "CONTAINER_NAME=\$1" "$SCRIPT_PATH"
    [ "$status" -eq 0 ]
}

@test "script calls docker restart" {
    run grep -q "docker restart" "$SCRIPT_PATH"
    [ "$status" -eq 0 ]
}

@test "script provides confirmation message" {
    run grep -q "Restarted Docker container" "$SCRIPT_PATH"
    [ "$status" -eq 0 ]
}
