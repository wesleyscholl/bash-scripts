#!/usr/bin/env bats

# Tests for kubectl-namespace-cleanup.sh

load 'test_helper/bats-support/load'
load 'test_helper/bats-assert/load'

setup() {
    export SCRIPT_PATH="${BATS_TEST_DIRNAME}/../scripts/kubectl-namespace-cleanup.sh"
}

@test "script file exists and is executable" {
    [ -f "$SCRIPT_PATH" ]
    [ -x "$SCRIPT_PATH" ]
}

@test "kubectl command available" {
    command -v kubectl || skip "kubectl not installed"
}

@test "script defines namespace variable" {
    run grep -q "NAMESPACE=" "$SCRIPT_PATH"
    [ "$status" -eq 0 ]
}

@test "script prompts for confirmation" {
    run grep -q "read -p" "$SCRIPT_PATH"
    [ "$status" -eq 0 ]
}

@test "script checks confirmation response" {
    run grep -q "CONFIRMATION" "$SCRIPT_PATH"
    [ "$status" -eq 0 ]
}

@test "script can abort on negative confirmation" {
    run grep -q "Aborted" "$SCRIPT_PATH"
    [ "$status" -eq 0 ]
}

@test "script deletes all resources" {
    run grep -q "kubectl delete all --all" "$SCRIPT_PATH"
    [ "$status" -eq 0 ]
}

@test "script deletes namespace" {
    run grep -q "kubectl delete namespace" "$SCRIPT_PATH"
    [ "$status" -eq 0 ]
}

@test "script uses namespace parameter" {
    run grep -q "\-n.*NAMESPACE" "$SCRIPT_PATH"
    [ "$status" -eq 0 ]
}

@test "script provides completion message" {
    run grep -q "have been deleted" "$SCRIPT_PATH"
    [ "$status" -eq 0 ]
}
