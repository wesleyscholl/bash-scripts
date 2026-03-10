#!/usr/bin/env bats

load 'test_helper/bats-support/load'
load 'test_helper/bats-assert/load'

setup() {
    export SCRIPT_PATH="${BATS_TEST_DIRNAME}/../scripts/ssh-config-audit.sh"
    export TMP_CFG="$(mktemp)"
    cat > "$TMP_CFG" << EOF
PermitRootLogin no
PasswordAuthentication no
PubkeyAuthentication yes
Protocol 2
EOF
}

teardown() {
    rm -f "$TMP_CFG"
}

@test "script exists" {
    [ -f "$SCRIPT_PATH" ]
}

@test "script supports help" {
    run "$SCRIPT_PATH" --help
    [ "$status" -eq 0 ]
}

@test "script passes hardened sample config" {
    run "$SCRIPT_PATH" "$TMP_CFG"
    [ "$status" -eq 0 ]
}

@test "script checks settings function" {
    run grep -q "check_setting" "$SCRIPT_PATH"
    [ "$status" -eq 0 ]
}
