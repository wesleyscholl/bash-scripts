SHELL      := /bin/bash
SCRIPTS_DIR := scripts
TESTS_DIR  := tests
INSTALL_DIR ?= /usr/local/bin

.PHONY: all test lint install clean help

all: lint test  ## Run lint then test (default target)

help:  ## Show available targets
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | \
		awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-12s\033[0m %s\n", $$1, $$2}'

test:  ## Run the full BATS test suite
	bats $(TESTS_DIR)/*.bats

lint:  ## Lint all scripts with ShellCheck
	@echo "Running ShellCheck on all scripts..."
	@find $(SCRIPTS_DIR)/ -name "*.sh" -type f | sort | xargs shellcheck
	@echo "ShellCheck passed."

install:  ## Install all scripts to INSTALL_DIR (default: /usr/local/bin)
	@chmod 755 $(SCRIPTS_DIR)/*.sh
	@cp $(SCRIPTS_DIR)/*.sh $(INSTALL_DIR)/
	@echo "Installed $$(ls $(SCRIPTS_DIR)/*.sh | wc -l | tr -d ' ') scripts to $(INSTALL_DIR)"

clean:  ## Remove temporary test artefacts
	@rm -f /tmp/bats_test_* /tmp/test_*
	@echo "Cleaned up test artefacts."
