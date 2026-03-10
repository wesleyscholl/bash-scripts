# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- `scripts/dns-lookup-check.sh` — verify DNS resolution for hostnames with optional expected-IP validation
- `scripts/network-latency-report.sh` — ping-based latency monitor with configurable count and threshold
- `scripts/swap-usage-monitor.sh` — alert when swap usage percentage exceeds a threshold
- `scripts/mysql-slow-query-report.sh` — parse MySQL slow query log and rank top offenders by query time
- `scripts/disk-throughput-test.sh` — dd-based sequential read/write benchmark for a target directory
- `scripts/kernel-parameter-audit.sh` — audit sysctl parameters against a hardened security baseline
- `scripts/certificate-renewal-check.sh` — check TLS certificates (files or live hosts) for expiry status
- `scripts/large-file-finder.sh` — find the largest files in a directory tree with human-readable output
- `scripts/uptime-reporter.sh` — report system uptime, boot time, load averages, and recent reboots
- `scripts/log-error-summary.sh` — count and rank error patterns in log files for rapid incident triage
- Corresponding BATS test files for all 10 scripts above (100 new tests, 568 total)

## [1.3.0] - 2026-06-28

### Added
- CI pipeline (`.github/workflows/ci.yml`) — ShellCheck lint + BATS test suite on every push and PR
- `CONTRIBUTING.md` — contributor guide with script style guide, test requirements, and PR workflow
- `SECURITY.md` — vulnerability reporting policy and responsible disclosure guidelines
- `CODE_OF_CONDUCT.md` — Contributor Covenant v2.1
- `.github/ISSUE_TEMPLATE/bug_report.md` — structured bug report template
- `.github/ISSUE_TEMPLATE/feature_request.md` — feature request template
- `.github/PULL_REQUEST_TEMPLATE.md` — PR checklist template
- `.github/CODEOWNERS` — auto-assign reviewer on all PRs
- `.github/dependabot.yml` — monthly GitHub Actions dependency updates
- `.github/FUNDING.yml` — GitHub Sponsors funding link
- `.shellcheckrc` — project-wide ShellCheck configuration
- `.gitignore` — ignore editor artefacts, credentials, and test output
- `.editorconfig` — consistent editor settings across all contributors
- `Makefile` — `make test`, `make lint`, `make install`, `make clean`, `make help`
- `.pre-commit-config.yaml` — shellcheck and general hygiene pre-commit hooks

## [1.2.0] - 2026-01-20

### Added
- `scripts/service-status-check.sh` — check systemd service active/enabled status
- `scripts/env-var-audit.sh` — audit required environment variables for completeness
- `scripts/process-zombie-report.sh` — detect and report zombie processes
- `scripts/github-release-check.sh` — query GitHub API for latest release information
- `scripts/git-commit-signoff-check.sh` — verify commits carry a Signed-off-by trailer
- `scripts/api-latency-monitor.sh` — measure HTTP endpoint response time with threshold alerting
- `scripts/tcp-connectivity-check.sh` — verify TCP port reachability with timeout support
- `scripts/cpu-load-watch.sh` — monitor CPU load average against a configurable threshold
- `scripts/backup-size-trend.sh` — report backup directory size trend (newest first)
- `scripts/remote-backup-verifier.sh` — verify remote backup directory is non-empty over SSH
- `scripts/docker-image-age-report.sh` — report Docker images older than a threshold
- `scripts/k8s-pod-age-report.sh` — report Kubernetes pods running longer than a threshold
- `scripts/ssh-config-audit.sh` — audit `sshd_config` for insecure settings
- `scripts/file-permission-audit.sh` — detect world-writable files in a given path
- `scripts/url-encode.sh` — percent-encode a string for use in URLs
- Corresponding BATS test files for all 15 scripts above

## [1.1.0] - 2025-09-10

### Added
- `scripts/backup-integrity-check.sh` — validate archive integrity for .tar, .gz, and .zip files
- `scripts/disk-inode-monitor.sh` — monitor filesystem inode usage with threshold alerting
- `scripts/failed-login-monitor.sh` — detect SSH brute-force attempts from auth.log
- `scripts/cron-job-audit.sh` — audit cron jobs for risky patterns and insecure permissions
- `scripts/git-stale-branches-report.sh` — report branches with no commits in N days
- `scripts/k8s-pod-restart-report.sh` — report Kubernetes pods with high restart counts
- `scripts/secrets-pattern-scan.sh` — scan files for common secret patterns (API keys, tokens)
- `scripts/json-log-summary.sh` — summarise NDJSON log files by log level and HTTP status
- `scripts/file-integrity-snapshot.sh` — create and verify SHA-256 file integrity manifests
- `scripts/ssl-chain-check.sh` — validate full TLS certificate chain and report expiry
- Corresponding BATS test files for all 10 scripts above
- `Security & Compliance` and `Git & Developer Productivity` categories added to README

## [1.0.0] - 2024-10-01

### Added
- Initial release with 34 production-ready Bash automation scripts
- Full BATS test suite with 100% script coverage
- Script categories: System Administration, DevOps & CI/CD, Monitoring & Alerting, Backup & Recovery, Container & Kubernetes, Utilities
- Vendored `bats-support` and `bats-assert` test helpers
- MIT License

[Unreleased]: https://github.com/wesleyscholl/bash-scripts/compare/v1.2.0...HEAD
[1.2.0]: https://github.com/wesleyscholl/bash-scripts/compare/v1.1.0...v1.2.0
[1.1.0]: https://github.com/wesleyscholl/bash-scripts/compare/v1.0.0...v1.1.0
[1.0.0]: https://github.com/wesleyscholl/bash-scripts/releases/tag/v1.0.0
