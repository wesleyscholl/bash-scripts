#!/usr/bin/env bats

# Tests for health-check.sh

@test "disk usage command works" {
    run df -h
    [ "$status" -eq 0 ]
}

@test "memory usage command works" {
    # Use vm_stat on macOS, free on Linux
    if command -v free &>/dev/null; then
        run free -m
    elif command -v vm_stat &>/dev/null; then
        run vm_stat
    else
        skip "no memory command available"
    fi
    [ "$status" -eq 0 ]
}

@test "uptime command works" {
    run uptime
    [ "$status" -eq 0 ]
}

@test "CPU info available" {
    # Use sysctl on macOS, /proc/cpuinfo on Linux
    if [ -f /proc/cpuinfo ]; then
        run cat /proc/cpuinfo
    elif command -v sysctl &>/dev/null; then
        run sysctl -n machdep.cpu.brand_string
    else
        skip "no CPU info command available"
    fi
    [ "$status" -eq 0 ]
}

@test "network interfaces exist" {
    run ifconfig -a 2>/dev/null || run ip addr
    [ "$status" -eq 0 ]
}
