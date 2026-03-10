## Description

Briefly describe what this PR adds or changes and why.

Fixes # (issue number, if applicable)

## Type of Change

- [ ] New script
- [ ] Bug fix (existing script)
- [ ] Enhancement (existing script)
- [ ] Documentation update
- [ ] CI / tooling change

## Checklist

- [ ] Script follows the style guide (`set -euo pipefail`, `show_usage()`, `--help` flag, input validation)
- [ ] Script is executable (`chmod 755`)
- [ ] A corresponding `.bats` test file is included or updated
- [ ] All tests pass locally (`make test` or `bats tests/<script-name>.bats`)
- [ ] ShellCheck passes locally (`make lint` or `shellcheck scripts/<script-name>.sh`)
- [ ] `README.md` updated with the new script details and usage example
- [ ] `CHANGELOG.md` updated under `[Unreleased]`

## Testing

Describe how you tested this change. Include the test commands you ran and their output where relevant.
