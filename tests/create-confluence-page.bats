#!/usr/bin/env bats

# Tests for create-confluence-page.sh

load 'test_helper/bats-support/load'
load 'test_helper/bats-assert/load'

setup() {
    export SCRIPT_PATH="${BATS_TEST_DIRNAME}/../scripts/create-confluence-page.sh"
}

@test "script file exists and is executable" {
    [ -f "$SCRIPT_PATH" ]
    [ -x "$SCRIPT_PATH" ]
}

@test "curl command available" {
    command -v curl
}

@test "script defines Confluence URL variable" {
    run grep -q "CONFLUENCE_URL=" "$SCRIPT_PATH"
    [ "$status" -eq 0 ]
}

@test "script defines Confluence user variable" {
    run grep -q "CONFLUENCE_USER=" "$SCRIPT_PATH"
    [ "$status" -eq 0 ]
}

@test "script defines Confluence API token variable" {
    run grep -q "CONFLUENCE_API_TOKEN=" "$SCRIPT_PATH"
    [ "$status" -eq 0 ]
}

@test "script defines space key variable" {
    run grep -q "SPACE_KEY=" "$SCRIPT_PATH"
    [ "$status" -eq 0 ]
}

@test "script defines page title variable" {
    run grep -q "PAGE_TITLE=" "$SCRIPT_PATH"
    [ "$status" -eq 0 ]
}

@test "script defines page content variable" {
    run grep -q "PAGE_CONTENT=" "$SCRIPT_PATH"
    [ "$status" -eq 0 ]
}

@test "script uses POST method" {
    run grep -q "curl -X POST" "$SCRIPT_PATH"
    [ "$status" -eq 0 ]
}

@test "script uses REST API endpoint" {
    run grep -q "/rest/api/content" "$SCRIPT_PATH"
    [ "$status" -eq 0 ]
}

@test "script includes authentication" {
    run grep -q "\-u.*CONFLUENCE_USER:.*CONFLUENCE_API_TOKEN" "$SCRIPT_PATH"
    [ "$status" -eq 0 ]
}

@test "script sends JSON payload" {
    run grep -q "Content-Type: application/json" "$SCRIPT_PATH"
    [ "$status" -eq 0 ]
}

@test "script includes page type" {
    run grep -q "type.*page" "$SCRIPT_PATH"
    [ "$status" -eq 0 ]
}

@test "script includes page title" {
    run grep -q "title" "$SCRIPT_PATH"
    [ "$status" -eq 0 ]
}

@test "script includes space key" {
    run grep -q "space.*key" "$SCRIPT_PATH"
    [ "$status" -eq 0 ]
}

@test "script includes page body" {
    run grep -q "body" "$SCRIPT_PATH"
    [ "$status" -eq 0 ]
}

@test "script provides confirmation message" {
    run grep -q "Page.*created in Confluence" "$SCRIPT_PATH"
    [ "$status" -eq 0 ]
}
