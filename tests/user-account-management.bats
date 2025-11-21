#!/usr/bin/env bats

# Tests for user-account-management.sh

load 'test_helper/bats-support/load'
load 'test_helper/bats-assert/load'

setup() {
    export SCRIPT_PATH="${BATS_TEST_DIRNAME}/../scripts/user-account-management.sh"
}

@test "script file exists and is executable" {
    [ -f "$SCRIPT_PATH" ]
    [ -x "$SCRIPT_PATH" ]
}

@test "getent command available" {
    command -v getent || skip "getent not available"
}

@test "groupadd command available" {
    command -v groupadd || skip "groupadd not available (requires root)"
}

@test "useradd command available" {
    command -v useradd || skip "useradd not available (requires root)"
}

@test "chpasswd command available" {
    command -v chpasswd || skip "chpasswd not available (requires root)"
}

@test "script defines username variable" {
    run grep -q "USERNAME=" "$SCRIPT_PATH"
    [ "$status" -eq 0 ]
}

@test "script defines password variable" {
    run grep -q "PASSWORD=" "$SCRIPT_PATH"
    [ "$status" -eq 0 ]
}

@test "script defines group variable" {
    run grep -q "GROUP=" "$SCRIPT_PATH"
    [ "$status" -eq 0 ]
}

@test "script checks if group exists" {
    run grep -q "getent group.*GROUP" "$SCRIPT_PATH"
    [ "$status" -eq 0 ]
}

@test "script creates group if not exists" {
    run grep -q "groupadd.*GROUP" "$SCRIPT_PATH"
    [ "$status" -eq 0 ]
}

@test "script reports group creation" {
    run grep -q "Group.*created" "$SCRIPT_PATH"
    [ "$status" -eq 0 ]
}

@test "script reports group exists" {
    run grep -q "Group.*already exists" "$SCRIPT_PATH"
    [ "$status" -eq 0 ]
}

@test "script checks if user exists" {
    run grep -q "id -u.*USERNAME" "$SCRIPT_PATH"
    [ "$status" -eq 0 ]
}

@test "script creates user with home directory" {
    run grep -q "useradd -m" "$SCRIPT_PATH"
    [ "$status" -eq 0 ]
}

@test "script assigns user to group" {
    run grep -q "useradd.*-g.*GROUP" "$SCRIPT_PATH"
    [ "$status" -eq 0 ]
}

@test "script sets user shell" {
    run grep -q "useradd.*-s /bin/bash" "$SCRIPT_PATH"
    [ "$status" -eq 0 ]
}

@test "script sets user password" {
    run grep -q "chpasswd" "$SCRIPT_PATH"
    [ "$status" -eq 0 ]
}

@test "script reports user creation" {
    run grep -q "User.*created" "$SCRIPT_PATH"
    [ "$status" -eq 0 ]
}

@test "script reports user exists" {
    run grep -q "User.*already exists" "$SCRIPT_PATH"
    [ "$status" -eq 0 ]
}

@test "id command can check current user" {
    run id -u
    [ "$status" -eq 0 ]
    [[ "$output" =~ ^[0-9]+$ ]]
}
