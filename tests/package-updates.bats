#!/usr/bin/env bats

# Tests for package-updates.sh

load 'test_helper/bats-support/load'
load 'test_helper/bats-assert/load'

setup() {
    export SCRIPT_PATH="${BATS_TEST_DIRNAME}/../scripts/package-updates.sh"
}

@test "script file exists and is executable" {
    [ -f "$SCRIPT_PATH" ]
    [ -x "$SCRIPT_PATH" ]
}

@test "apt command available or yum fallback" {
    command -v apt || command -v yum || skip "package manager not available"
}

@test "script updates package list" {
    run grep -q "apt update" "$SCRIPT_PATH"
    [ "$status" -eq 0 ]
}

@test "script uses sudo for apt update" {
    run grep -q "sudo apt update" "$SCRIPT_PATH"
    [ "$status" -eq 0 ]
}

@test "script checks for upgradable packages" {
    run grep -q "apt list --upgradable" "$SCRIPT_PATH"
    [ "$status" -eq 0 ]
}

@test "script counts upgradable packages" {
    run grep -q "UPGRADES=.*grep -c upgradable" "$SCRIPT_PATH"
    [ "$status" -eq 0 ]
}

@test "script compares upgrade count" {
    run grep -q "if \[.*UPGRADES.*-gt 0" "$SCRIPT_PATH"
    [ "$status" -eq 0 ]
}

@test "script performs upgrade" {
    run grep -q "apt upgrade" "$SCRIPT_PATH"
    [ "$status" -eq 0 ]
}

@test "script uses non-interactive upgrade" {
    run grep -q "apt upgrade -y" "$SCRIPT_PATH"
    [ "$status" -eq 0 ]
}

@test "script reports when no updates needed" {
    run grep -q "No packages need to be upgraded" "$SCRIPT_PATH"
    [ "$status" -eq 0 ]
}

@test "script reports when updates are available" {
    run grep -q "can be upgraded.*Installing updates" "$SCRIPT_PATH"
    [ "$status" -eq 0 ]
}
