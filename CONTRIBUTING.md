# Contributing to Bash Scripts Collection

Thank you for your interest in contributing! This guide explains everything you need to know to add a new script, fix a bug, or improve documentation.

---

## Table of Contents

- [Getting Started](#getting-started)
- [Workflow](#workflow)
- [Branch Naming](#branch-naming)
- [Commit Messages](#commit-messages)
- [Script Style Guide](#script-style-guide)
- [Testing Requirements](#testing-requirements)
- [Pull Request Process](#pull-request-process)

---

## Getting Started

1. **Fork** the repository on GitHub.
2. **Clone** your fork locally:
   ```bash
   git clone https://github.com/<your-username>/bash-scripts.git
   cd bash-scripts
   ```
3. **Install dev tools**:
   ```bash
   # BATS test runner
   sudo apt-get install -y bats       # Debian/Ubuntu
   brew install bats-core             # macOS

   # ShellCheck linter
   sudo apt-get install -y shellcheck # Debian/Ubuntu
   brew install shellcheck            # macOS
   ```
4. **Verify your setup**:
   ```bash
   make test   # run the full test suite
   make lint   # run ShellCheck on all scripts
   ```

---

## Workflow

```
main ← feature/your-script-name
     ← fix/short-description
     ← docs/what-you-updated
     ← chore/tooling-change
```

1. Create a branch from `main`.
2. Make your changes.
3. Run `make test` and `make lint` — both must pass.
4. Open a pull request against `main`.

---

## Branch Naming

| Type | Pattern | Example |
|------|---------|---------|
| New script | `feature/<script-name>` | `feature/disk-quota-monitor` |
| Bug fix | `fix/<short-description>` | `fix/ssl-chain-check-date-parsing` |
| Documentation | `docs/<what>` | `docs/update-readme-examples` |
| Tooling / CI | `chore/<what>` | `chore/update-ci-actions` |

---

## Commit Messages

Follow the [Conventional Commits](https://www.conventionalcommits.org/) format:

```
<type>(<scope>): <short summary>
```

**Types**: `feat`, `fix`, `docs`, `chore`, `test`, `refactor`

**Examples**:
```
feat(scripts): add disk-quota-monitor.sh with threshold alerting
fix(ssl-chain-check): correct expiry date parsing on macOS
docs(readme): add usage example for api-latency-monitor
test(backup): add edge case tests for empty archive
```

- Use the imperative mood: "add" not "added", "fix" not "fixed"
- Keep the summary line under 72 characters
- Reference issues with `Closes #123` or `Fixes #123` in the body

---

## Script Style Guide

Every script **must** follow this standard. Run `shellcheck scripts/<name>.sh` before opening a PR.

### Required Header

```bash
#!/bin/bash
# script-name.sh — one-line description of what this script does
# Usage: ./scripts/script-name.sh [OPTIONS] <required-arg>

set -euo pipefail
```

### Required: show_usage() and --help

```bash
show_usage() {
    echo "Usage: $(basename "$0") [OPTIONS] <required-arg>"
    echo ""
    echo "Description of what the script does."
    echo ""
    echo "Options:"
    echo "  -h, --help    Show this help message"
    echo ""
    echo "Arguments:"
    echo "  <required-arg>  Description of the argument"
    echo ""
    echo "Examples:"
    echo "  $(basename "$0") my-value"
    echo "  $(basename "$0") --help"
    exit 0
}

[[ "${1:-}" =~ ^(-h|--help)$ ]] && show_usage
```

### Required: Input Validation

Validate required arguments before doing any work:

```bash
if [[ $# -lt 1 ]]; then
    echo "Error: <required-arg> is required."
    show_usage
fi
```

### Exit Codes

| Code | Meaning |
|------|---------|
| `0` | Success / check passed |
| `1` | Alert condition met, check failed, or runtime error |
| `2` | Missing argument or invalid input |

### Style Rules

- Use `[[ ]]` for all conditionals (not `[ ]`)
- Always quote variables: `"$VAR"` not `$VAR`
- Use `$(command)` not `` `command` `` for command substitution
- Prefer `local` variables inside functions
- Write descriptive `echo` output — the user should understand what happened without reading the script
- Avoid hardcoded paths; use environment variables or flags

---

## Testing Requirements

Every script **must** have a corresponding test file at `tests/<script-name>.bats`.

### Minimum test cases (4 required)

```bash
@test "script file exists" { ... }
@test "required variable or constant is defined" { ... }
@test "--help flag exits cleanly" { ... }
@test "missing required argument exits with error" { ... }
```

Add more tests for functional behavior, edge cases, and error paths.

### Test template

```bash
#!/usr/bin/env bats

load 'test_helper/bats-support/load'
load 'test_helper/bats-assert/load'

setup() {
    SCRIPT_PATH="$(cd "$(dirname "$BATS_TEST_FILENAME")/.." && pwd)/scripts/your-script.sh"
    export SCRIPT_PATH
    chmod +x "$SCRIPT_PATH"
}

teardown() {
    rm -f /tmp/test_your_script_*
}

@test "script file exists" {
    [ -f "$SCRIPT_PATH" ]
}

@test "--help flag exits with status 0" {
    run bash "$SCRIPT_PATH" --help
    assert_success
    assert_output --partial "Usage:"
}

@test "missing required argument exits with error" {
    run bash "$SCRIPT_PATH"
    assert_failure
}
```

---

## Pull Request Process

1. Fill out the PR template completely.
2. Ensure the CI checks (ShellCheck + BATS) pass — the PR will not be merged until they do.
3. Keep each PR focused on one change. Large PRs are harder to review.
4. Update `CHANGELOG.md` under `[Unreleased]` with a brief summary of your change.
5. A maintainer will review and merge approved PRs.

---

## Questions?

Open a [GitHub Discussion](https://github.com/wesleyscholl/bash-scripts/discussions) or file an issue using the feature request template.
