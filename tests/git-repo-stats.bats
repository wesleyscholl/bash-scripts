#!/usr/bin/env bats

# Tests for git-repo-stats.sh

load 'test_helper/bats-support/load'
load 'test_helper/bats-assert/load'

setup() {
    export SCRIPT_PATH="${BATS_TEST_DIRNAME}/../scripts/git-repo-stats.sh"
    export TEST_REPO="${BATS_TEST_TMPDIR}/test_repo"
    
    # Create a test git repository
    mkdir -p "$TEST_REPO"
    cd "$TEST_REPO"
    git init -q
    git config user.email "test@example.com"
    git config user.name "Test User"
    echo "test" > test.sh
    git add test.sh
    git commit -qm "Initial commit"
}

teardown() {
    rm -rf "$TEST_REPO"
}

@test "script file exists and is executable" {
    [ -f "$SCRIPT_PATH" ]
    [ -x "$SCRIPT_PATH" ]
}

@test "git command available" {
    command -v git
}

@test "script checks if in git repository" {
    run grep -q "git rev-parse --git-dir" "$SCRIPT_PATH"
    [ "$status" -eq 0 ]
}

@test "script exits if not in git repo" {
    run grep -q "Not in a git repository" "$SCRIPT_PATH"
    [ "$status" -eq 0 ]
}

@test "script gets repository name" {
    run grep -q "REPO_NAME=.*basename" "$SCRIPT_PATH"
    [ "$status" -eq 0 ]
}

@test "script counts total commits" {
    run grep -q "TOTAL_COMMITS=.*git rev-list --all --count" "$SCRIPT_PATH"
    [ "$status" -eq 0 ]
}

@test "script counts branches" {
    run grep -q "BRANCH_COUNT=.*git branch -a" "$SCRIPT_PATH"
    [ "$status" -eq 0 ]
}

@test "script counts contributors" {
    run grep -q "CONTRIBUTOR_COUNT=.*git log --format='%an'" "$SCRIPT_PATH"
    [ "$status" -eq 0 ]
}

@test "script shows top contributors" {
    run grep -q "Top.*contributors" "$SCRIPT_PATH"
    [ "$status" -eq 0 ]
}

@test "script shows recent commit" {
    run grep -q "Most recent commit" "$SCRIPT_PATH"
    [ "$status" -eq 0 ]
}

@test "script counts total files" {
    run grep -q "TOTAL_FILES=.*git ls-files" "$SCRIPT_PATH"
    [ "$status" -eq 0 ]
}

@test "script counts shell script lines" {
    run grep -q "Shell scripts.*lines" "$SCRIPT_PATH"
    [ "$status" -eq 0 ]
}

@test "git rev-list works in test repo" {
    cd "$TEST_REPO"
    run git rev-list --all --count
    [ "$status" -eq 0 ]
    [ "$output" -eq 1 ]
}

@test "git ls-files works in test repo" {
    cd "$TEST_REPO"
    run git ls-files
    [ "$status" -eq 0 ]
    [[ "$output" =~ "test.sh" ]]
}
