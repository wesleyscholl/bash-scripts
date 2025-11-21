#!/usr/bin/env bats

# Tests for gc-cleanup.sh

load 'test_helper/bats-support/load'
load 'test_helper/bats-assert/load'

setup() {
    export SCRIPT_PATH="${BATS_TEST_DIRNAME}/../scripts/gc-cleanup.sh"
}

@test "script file exists and is executable" {
    [ -f "$SCRIPT_PATH" ]
    [ -x "$SCRIPT_PATH" ]
}

@test "git command available" {
    command -v git
}

@test "script runs git gc with prune" {
    run grep -q "git gc --prune=now" "$SCRIPT_PATH"
    [ "$status" -eq 0 ]
}

@test "script runs git repack" {
    run grep -q "git repack" "$SCRIPT_PATH"
    [ "$status" -eq 0 ]
}

@test "script uses repack with aggressive flags" {
    run grep -q "\-a -d -f" "$SCRIPT_PATH"
    [ "$status" -eq 0 ]
}

@test "script runs git prune" {
    run grep -q "^git prune" "$SCRIPT_PATH"
    [ "$status" -eq 0 ]
}

@test "script expires reflog" {
    run grep -q "git reflog expire" "$SCRIPT_PATH"
    [ "$status" -eq 0 ]
}

@test "script sets reflog expiry time" {
    run grep -q "expire=30.days" "$SCRIPT_PATH"
    [ "$status" -eq 0 ]
}

@test "script runs fsck" {
    run grep -q "git fsck" "$SCRIPT_PATH"
    [ "$status" -eq 0 ]
}

@test "script uses verbose fsck" {
    run grep -q "fsck.*verbose" "$SCRIPT_PATH"
    [ "$status" -eq 0 ]
}

@test "script runs aggressive gc" {
    run grep -q "git gc --aggressive" "$SCRIPT_PATH"
    [ "$status" -eq 0 ]
}
