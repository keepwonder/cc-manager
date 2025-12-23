.PHONY: help install uninstall test clean dev-install dev-uninstall check-syntax validate

# Installation prefix
PREFIX ?= /usr/local
BIN_DIR = $(PREFIX)/bin
LIB_DIR = $(PREFIX)/lib/cc-manager

# Project info
PROJECT = cc-manager
VERSION = 1.0.2

help:
	@echo "$(PROJECT) v$(VERSION) - Makefile Commands"
	@echo ""
	@echo "Usage: make [target]"
	@echo ""
	@echo "Targets:"
	@echo "  install         Install cc-manager (requires sudo for system-wide)"
	@echo "  uninstall       Uninstall cc-manager"
	@echo "  dev-install     Install to ~/.local (no sudo required)"
	@echo "  dev-uninstall   Uninstall from ~/.local"
	@echo "  test            Run tests"
	@echo "  check-syntax    Check shell script syntax"
	@echo "  validate        Validate project structure"
	@echo "  clean           Clean temporary files"
	@echo "  help            Show this help message"
	@echo ""
	@echo "Examples:"
	@echo "  make install              # Install to /usr/local"
	@echo "  make dev-install          # Install to ~/.local"
	@echo "  PREFIX=~/opt make install # Install to custom location"

install:
	@echo "Installing $(PROJECT)..."
	@bash install.sh

uninstall:
	@echo "Uninstalling $(PROJECT)..."
	@bash uninstall.sh

dev-install:
	@echo "Installing $(PROJECT) to ~/.local..."
	@PREFIX="${HOME}/.local" bash install.sh

dev-uninstall:
	@echo "Uninstalling $(PROJECT) from ~/.local..."
	@PREFIX="${HOME}/.local" bash uninstall.sh

test:
	@echo "Running tests..."
	@if [ -d tests ]; then \
		for test in tests/test-*.sh; do \
			echo "Running $$test..."; \
			bash "$$test" || exit 1; \
		done; \
		echo "All tests passed!"; \
	else \
		echo "No tests found"; \
	fi

check-syntax:
	@echo "Checking shell script syntax..."
	@bash -n bin/cc-manager
	@bash -n bin/cc-manager-bin
	@bash -n install.sh
	@bash -n uninstall.sh
	@for lib in lib/*.sh; do \
		echo "Checking $$lib..."; \
		bash -n "$$lib" || exit 1; \
	done
	@for script in scripts/*.sh; do \
		if [ -f "$$script" ]; then \
			echo "Checking $$script..."; \
			bash -n "$$script" || exit 1; \
		fi; \
	done
	@echo "Syntax check passed!"

validate:
	@echo "Validating project structure..."
	@test -f bin/cc-manager || (echo "Missing: bin/cc-manager" && exit 1)
	@test -f bin/cc-manager-bin || (echo "Missing: bin/cc-manager-bin" && exit 1)
	@test -f lib/core.sh || (echo "Missing: lib/core.sh" && exit 1)
	@test -f lib/config.sh || (echo "Missing: lib/config.sh" && exit 1)
	@test -f lib/providers.sh || (echo "Missing: lib/providers.sh" && exit 1)
	@test -f lib/history.sh || (echo "Missing: lib/history.sh" && exit 1)
	@test -f lib/utils.sh || (echo "Missing: lib/utils.sh" && exit 1)
	@test -f install.sh || (echo "Missing: install.sh" && exit 1)
	@test -f uninstall.sh || (echo "Missing: uninstall.sh" && exit 1)
	@test -f config/config.example.yaml || (echo "Missing: config/config.example.yaml" && exit 1)
	@echo "Project structure is valid!"

clean:
	@echo "Cleaning temporary files..."
	@find . -name "*.bak" -delete
	@find . -name "*~" -delete
	@find . -name ".DS_Store" -delete
	@echo "Clean complete!"

# Set executable permissions
chmod:
	@echo "Setting executable permissions..."
	@chmod +x bin/cc-manager
	@chmod +x bin/cc-manager-bin
	@chmod +x install.sh
	@chmod +x uninstall.sh
	@if [ -d tests ]; then chmod +x tests/*.sh 2>/dev/null || true; fi
	@echo "Permissions set!"

# Development helpers
dev: dev-install
	@echo "Development installation complete"
	@echo "You can now run: cc-manager"

check: check-syntax validate
	@echo "All checks passed!"
