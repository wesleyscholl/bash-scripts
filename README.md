# 🚀 Bash Scripts Collection

A comprehensive collection of production-ready Bash scripts for DevOps engineers, system administrators, and automation enthusiasts. These scripts handle everything from system monitoring and backups to Kubernetes management and CI/CD integrations.

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Shell](https://img.shields.io/badge/Shell-Bash-green.svg)](https://www.gnu.org/software/bash/)

<img width="600" alt="bash" src="https://github.com/user-attachments/assets/2bd21a84-eac3-4309-9404-3b21bf31ac26" />

## 📋 Table of Contents

- [Overview](#overview)
- [Scripts](#scripts)
  - [System Administration](#system-administration)
  - [DevOps & CI/CD](#devops--cicd)
  - [Monitoring & Alerting](#monitoring--alerting)
  - [Backup & Recovery](#backup--recovery)
  - [Container & Kubernetes](#container--kubernetes)
- [Prerequisites](#prerequisites)
- [Installation](#installation)
- [Usage](#usage)
- [Contributing](#contributing)
- [License](#license)

## 🎯 Overview

This repository contains battle-tested Bash scripts designed to automate common tasks in modern infrastructure management. Whether you're managing bare-metal servers, cloud infrastructure, or containerized applications, you'll find utilities to streamline your workflow.

## 📜 Scripts

### System Administration

| Script | Description |
|--------|-------------|
| `account-expiry-notify.sh` | Monitors and notifies about upcoming user account expirations |
| `user-account-management.sh` | Automates user account creation, modification, and deletion |
| `package-updates.sh` | Checks for and manages system package updates |
| `system-resource-monitor.sh` | Monitors CPU, memory, and disk usage with threshold alerts |
| `system-monitoring.sh` | Comprehensive system health monitoring script |
| `health-check.sh` | Performs system health checks and reports status |
| `http-status.sh` | Checks HTTP endpoint status and availability |
| `monitor-open-ports.sh` | Scans and monitors open network ports |
| `process-monitor-alert.sh` | Monitors specific processes and alerts on failures |

### DevOps & CI/CD

| Script | Description |
|--------|-------------|
| `jenkins-job.sh` | Triggers and manages Jenkins job executions |
| `argo-cd-sync.sh` | Synchronizes ArgoCD applications |
| `auto-deployment.sh` | Automates application deployment workflows |
| `sonarqube-slack-notify.sh` | Sends SonarQube analysis results to Slack |
| `create-confluence-page.sh` | Creates and updates Confluence documentation pages |
| `git-repo-stats.sh` | Generates comprehensive Git repository statistics |

### Monitoring & Alerting

| Script | Description |
|--------|-------------|
| `disk-usage-monitor.sh` | Monitors disk usage and sends alerts on thresholds |
| `grafana-metrics.sh` | Pushes custom metrics to Grafana |
| `slack-notify.sh` | Sends notifications to Slack channels |
| `splunk-search.sh` | Performs automated Splunk log searches |
| `check-ssl-expiry.sh` | Monitors SSL certificate expiration dates |
| `docker-log-monitor.sh` | Monitors and analyzes Docker container logs |

### Backup & Recovery

| Script | Description |
|--------|-------------|
| `backup.sh` | Performs weekly automated backups |
| `rsync-backup.sh` | Uses rsync for efficient incremental backups |
| `scp-remote-backup.sh` | Securely copies backups to remote servers |
| `rotate-old-files.sh` | Implements file rotation policies |
| `log-rotation.sh` | Manages log file rotation and archival |
| `log-file-cleanup.sh` | Cleans up old log files based on retention policies |

### Container & Kubernetes

| Script | Description |
|--------|-------------|
| `kubectl-namespace-cleanup.sh` | Cleans up unused Kubernetes namespaces |
| `scale-deployment.sh` | Scales Kubernetes deployments automatically |
| `restart-containers.sh` | Restarts Docker containers based on criteria |
| `gc-cleanup.sh` | Performs garbage collection and cleanup tasks |

### Utilities

| Script | Description |
|--------|-------------|
| `random-password-generator.sh` | Generates secure random passwords |

## 🔧 Prerequisites

- Bash 4.0 or higher
- Standard Unix utilities (grep, awk, sed, etc.)
- Specific tools required by individual scripts:
  - `kubectl` for Kubernetes scripts
  - `docker` for container management scripts
  - `curl` or `wget` for HTTP-based scripts
  - `jq` for JSON parsing (some scripts)
  - `rsync` for backup scripts
  - API tokens/credentials for integration scripts (Jenkins, Slack, etc.)

## 📥 Installation

1. Clone the repository:
```bash
git clone https://github.com/wesleyscholl/bash-scripts.git
cd bash-scripts
```

2. Make scripts executable:
```bash
chmod +x *.sh
```

3. (Optional) Add scripts to your PATH:
```bash
export PATH=$PATH:$(pwd)
```

Or copy scripts to `/usr/local/bin/`:
```bash
sudo cp *.sh /usr/local/bin/
```

## 🚀 Usage

Each script includes inline documentation and usage examples. Run any script with the `-h` or `--help` flag for detailed information:

```bash
./backup.sh --help
```

### Example: SSL Certificate Monitoring

```bash
./check-ssl-expiry.sh example.com 443
```

### Example: Disk Usage Monitoring

```bash
./disk-usage-monitor.sh /dev/sda1 80
```

### Example: Kubernetes Namespace Cleanup

```bash
./kubectl-namespace-cleanup.sh --dry-run
```

## 📝 Configuration

Many scripts support configuration through:
- Environment variables
- Configuration files (`.conf` or `.env` files)
- Command-line arguments

Check individual script documentation for specific configuration options.

## 🤝 Contributing

Contributions are welcome! Please follow these guidelines:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-script`)
3. Commit your changes (`git commit -m 'Add amazing script'`)
4. Push to the branch (`git push origin feature/amazing-script`)
5. Open a Pull Request

### Script Guidelines

- Include error handling and input validation
- Add usage documentation and examples
- Follow consistent naming conventions
- Test thoroughly before submitting
- Include comments for complex logic

## 🔒 Security

- Never commit sensitive credentials or tokens
- Use environment variables or secure vaults for secrets
- Review scripts before running in production
- Follow the principle of least privilege

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Built by [@wesleyscholl](https://github.com/wesleyscholl) with contributions from the community
- Thanks to all contributors who help improve these scripts

## 📞 Support

- Open an [issue](https://github.com/wesleyscholl/bash-scripts/issues) for bug reports
- Start a [discussion](https://github.com/wesleyscholl/bash-scripts/discussions) for questions
- Check existing scripts for examples and patterns

---

**⭐ Star this repository if you find it useful!**
