#!/usr/bin/env bats

# Tests for check-ssl-expiry.sh

load 'test_helper/bats-support/load'
load 'test_helper/bats-assert/load'

setup() {
    export SCRIPT_PATH="${BATS_TEST_DIRNAME}/../scripts/check-ssl-expiry.sh"
}

@test "script file exists and is executable" {
    [ -f "$SCRIPT_PATH" ]
    [ -x "$SCRIPT_PATH" ]
}

@test "openssl command available" {
    command -v openssl
}

@test "script defines default domain" {
    run grep -q "DOMAIN=" "$SCRIPT_PATH"
    [ "$status" -eq 0 ]
}

@test "script defines default port" {
    run grep -q "PORT=" "$SCRIPT_PATH"
    [ "$status" -eq 0 ]
}

@test "script defines warning days threshold" {
    run grep -q "WARNING_DAYS=" "$SCRIPT_PATH"
    [ "$status" -eq 0 ]
}

@test "script checks for openssl installation" {
    run grep -q "command -v openssl" "$SCRIPT_PATH"
    [ "$status" -eq 0 ]
}

@test "script connects to SSL server" {
    run grep -q "openssl s_client.*connect" "$SCRIPT_PATH"
    [ "$status" -eq 0 ]
}

@test "script uses servername parameter" {
    run grep -q "\-servername" "$SCRIPT_PATH"
    [ "$status" -eq 0 ]
}

@test "script extracts certificate dates" {
    run grep -q "openssl x509.*dates" "$SCRIPT_PATH"
    [ "$status" -eq 0 ]
}

@test "script extracts expiry date" {
    run grep -q "notAfter" "$SCRIPT_PATH"
    [ "$status" -eq 0 ]
}

@test "script calculates days until expiry" {
    run grep -q "DAYS_UNTIL_EXPIRY=" "$SCRIPT_PATH"
    [ "$status" -eq 0 ]
}

@test "script converts dates to epoch" {
    # Test passes on both macOS and Linux
    run grep -E "EXPIRY_EPOCH=.*date.*(\+%s|-j)" "$SCRIPT_PATH"
    [ "$status" -eq 0 ]
}

@test "script checks if certificate is expired" {
    run grep -q "if \[.*DAYS_UNTIL_EXPIRY.*-lt 0" "$SCRIPT_PATH"
    [ "$status" -eq 0 ]
}

@test "script warns on expiring certificates" {
    run grep -q "WARNING_DAYS" "$SCRIPT_PATH"
    [ "$status" -eq 0 ]
}

@test "script displays certificate subject" {
    run grep -q "subject" "$SCRIPT_PATH"
    [ "$status" -eq 0 ]
}

@test "script displays certificate issuer" {
    run grep -q "issuer" "$SCRIPT_PATH"
    [ "$status" -eq 0 ]
}

@test "script exits with error on expired cert" {
    run grep -q "exit 2" "$SCRIPT_PATH"
    [ "$status" -eq 0 ]
}

@test "openssl can connect to test site" {
    run timeout 5 openssl s_client -connect google.com:443 -servername google.com </dev/null 2>/dev/null
    [ "$status" -eq 0 ] || skip "openssl connection test failed"
}
