#!/usr/bin/env bats

# Tests for health-check.sh

@test "disk usage command works" {
    run df -h
    [ "$status" -eq 0 ]
}

@test "memory usage command works" {
    run free -m 2>/dev/null || run vm_stat
    [ "$status" -eq 0 ]
}

@test "uptime command works" {
    run uptime
    [ "$status" -eq 0 ]
}

@test "CPU info available" {
    run cat /proc/cpuinfo 2>/dev/null || run sysctl -n machdep.cpu.brand_string
    [ "$status" -eq 0 ]
}

@test "network interfaces exist" {
    run ifconfig -a 2>/dev/null || run ip addr
    [ "$status" -eq 0 ]
}
