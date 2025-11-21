#!/usr/bin/env bats

# Tests for argo-cd-sync.sh

load 'test_helper/bats-support/load'
load 'test_helper/bats-assert/load'

setup() {
    export SCRIPT_PATH="${BATS_TEST_DIRNAME}/../scripts/argo-cd-sync.sh"
}

@test "script file exists and is executable" {
    [ -f "$SCRIPT_PATH" ]
    [ -x "$SCRIPT_PATH" ]
}

@test "curl command available" {
    command -v curl
}

@test "script defines ArgoCD server variable" {
    run grep -q "ARGOCD_SERVER=" "$SCRIPT_PATH"
    [ "$status" -eq 0 ]
}

@test "script defines ArgoCD app variable" {
    run grep -q "ARGOCD_APP=" "$SCRIPT_PATH"
    [ "$status" -eq 0 ]
}

@test "script defines ArgoCD token variable" {
    run grep -q "ARGOCD_TOKEN=" "$SCRIPT_PATH"
    [ "$status" -eq 0 ]
}

@test "script uses POST method" {
    run grep -q "curl -X POST" "$SCRIPT_PATH"
    [ "$status" -eq 0 ]
}

@test "script uses ArgoCD API endpoint" {
    run grep -q "/api/v1/applications" "$SCRIPT_PATH"
    [ "$status" -eq 0 ]
}

@test "script uses sync endpoint" {
    run grep -q "/sync" "$SCRIPT_PATH"
    [ "$status" -eq 0 ]
}

@test "script includes bearer token authentication" {
    run grep -q "Authorization: Bearer" "$SCRIPT_PATH"
    [ "$status" -eq 0 ]
}

@test "script provides confirmation message" {
    run grep -q "Triggered sync for application" "$SCRIPT_PATH"
    [ "$status" -eq 0 ]
}
