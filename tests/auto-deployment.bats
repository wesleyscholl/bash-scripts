#!/usr/bin/env bats

# Tests for auto-deployment.sh

load 'test_helper/bats-support/load'
load 'test_helper/bats-assert/load'

setup() {
    export SCRIPT_PATH="${BATS_TEST_DIRNAME}/../scripts/auto-deployment.sh"
    export TEST_DIR="${BATS_TEST_TMPDIR}/deploy_test"
    mkdir -p "$TEST_DIR"
}

teardown() {
    rm -rf "$TEST_DIR"
}

@test "script file exists and is executable" {
    [ -f "$SCRIPT_PATH" ]
    [ -x "$SCRIPT_PATH" ]
}

@test "git command available" {
    command -v git
}

@test "systemctl command available or service fallback" {
    command -v systemctl || command -v service || skip "systemctl not available"
}

@test "script contains repository directory variable" {
    run grep -q "REPO_DIR" "$SCRIPT_PATH"
    [ "$status" -eq 0 ]
}

@test "script contains service name variable" {
    run grep -q "SERVICE" "$SCRIPT_PATH"
    [ "$status" -eq 0 ]
}

@test "script changes to repository directory" {
    run grep -q "cd.*REPO_DIR" "$SCRIPT_PATH"
    [ "$status" -eq 0 ]
}

@test "script checks if directory exists" {
    run grep -q "Repository directory not found" "$SCRIPT_PATH"
    [ "$status" -eq 0 ]
}

@test "script performs git pull" {
    run grep -q "git pull" "$SCRIPT_PATH"
    [ "$status" -eq 0 ]
}

@test "script checks git pull status" {
    run grep -q "if \[ \$? -eq 0 \]" "$SCRIPT_PATH"
    [ "$status" -eq 0 ]
}

@test "script restarts service" {
    run grep -q "systemctl restart" "$SCRIPT_PATH"
    [ "$status" -eq 0 ]
}

@test "script verifies service status" {
    run grep -q "systemctl is-active" "$SCRIPT_PATH"
    [ "$status" -eq 0 ]
}

@test "script handles deployment failure" {
    run grep -q "Deployment aborted" "$SCRIPT_PATH"
    [ "$status" -eq 0 ]
}

@test "script provides status messages" {
    run grep -c "echo" "$SCRIPT_PATH"
    [ "$status" -eq 0 ]
    [ "$output" -ge 5 ]
}
