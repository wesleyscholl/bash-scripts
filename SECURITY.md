# Security Policy

## Supported Versions

The latest version on the `main` branch is actively maintained. Older commits are not patched individually.

| Branch | Supported |
|--------|-----------|
| `main` | ✅ Yes |
| older commits | ❌ No |

## Reporting a Vulnerability

**Please do not open a public GitHub issue for security vulnerabilities.**

Use GitHub's [private vulnerability reporting](https://github.com/wesleyscholl/bash-scripts/security/advisories/new) to report security issues confidentially.

Include as much of the following as possible in your report:

- The affected script(s) and line number(s)
- A description of the vulnerability and its potential impact
- Steps to reproduce the issue
- A suggested fix (optional but appreciated)

## Response Timeline

| Milestone | Target |
|-----------|--------|
| Acknowledgement | Within 48 hours |
| Initial assessment | Within 5 business days |
| Patch or mitigation | Within 90 days of confirmation |
| Public disclosure | After patch is released |

## Out of Scope

The following are **not** considered vulnerabilities for this project:

- Issues in tools that the scripts call (e.g., `curl`, `openssl`, `kubectl`) — report those upstream
- Scripts intentionally requiring elevated privileges (e.g., `ssh-config-audit.sh`) — such requirements are documented
- Denial-of-service conditions on the operator's own system caused by misconfiguration

## Responsible Disclosure

We follow a coordinated disclosure model. We ask that you give us a reasonable amount of time to address the issue before making it public. We will credit reporters in the release notes unless you prefer to remain anonymous.
