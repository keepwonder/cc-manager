#!/usr/bin/env bash
# ==============================================================================
# cc-manager Uninstallation Script
# ==============================================================================

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Installation paths
PREFIX="${PREFIX:-/usr/local}"
BIN_DIR="${BIN_DIR:-$PREFIX/bin}"
LIB_DIR="${LIB_DIR:-$PREFIX/lib/cc-manager}"
CONFIG_DIR="${HOME}/.config/cc-manager"
CACHE_DIR="${HOME}/.cache/cc-manager}"

# Print functions
print_success() {
    echo -e "${GREEN}✓${NC} $*"
}

print_error() {
    echo -e "${RED}✗${NC} $*" >&2
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $*"
}

print_info() {
    echo -e "${BLUE}ℹ${NC} $*"
}

# Confirm uninstallation
confirm_uninstall() {
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "  cc-manager Uninstallation"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    print_warning "This will remove cc-manager from your system"
    echo ""
    echo "The following will be removed:"
    echo "  - Binary: $BIN_DIR/cc-manager"
    echo "  - Library: $LIB_DIR"
    echo ""
    echo "Configuration and cache can be optionally removed."
    echo ""
    echo -n "Continue with uninstallation? [y/N] "
    read -r answer

    if [[ ! "$answer" =~ ^[Yy]$ ]]; then
        print_info "Uninstallation cancelled"
        exit 0
    fi
}

# Remove files
remove_files() {
    print_info "Removing cc-manager files..."

    # Remove binary
    if [[ -f "$BIN_DIR/cc-manager" ]]; then
        rm -f "$BIN_DIR/cc-manager"
        print_success "Removed binary"
    fi

    # Remove library directory
    if [[ -d "$LIB_DIR" ]]; then
        rm -rf "$LIB_DIR"
        print_success "Removed library directory"
    fi
}

# Remove configuration
remove_config() {
    echo ""
    echo -n "Remove configuration files? [y/N] "
    read -r answer

    if [[ "$answer" =~ ^[Yy]$ ]]; then
        # Backup config before removing
        if [[ -d "$CONFIG_DIR" ]]; then
            local backup="${CONFIG_DIR}.backup.$(date +%Y%m%d_%H%M%S)"
            cp -r "$CONFIG_DIR" "$backup" 2>/dev/null || true
            rm -rf "$CONFIG_DIR"
            print_success "Configuration removed (backed up to: $backup)"
        fi
    else
        print_info "Configuration preserved at: $CONFIG_DIR"
    fi
}

# Remove cache
remove_cache() {
    echo ""
    echo -n "Remove cache files? [y/N] "
    read -r answer

    if [[ "$answer" =~ ^[Yy]$ ]]; then
        if [[ -d "$CACHE_DIR" ]]; then
            rm -rf "$CACHE_DIR"
            print_success "Cache removed"
        fi
    else
        print_info "Cache preserved at: $CACHE_DIR"
    fi
}

# Remove shell integration
remove_shell_integration() {
    echo ""
    echo -n "Remove shell integration from rc files? [y/N] "
    read -r answer

    if [[ "$answer" =~ ^[Yy]$ ]]; then
        local shell_configs=("$HOME/.bashrc" "$HOME/.zshrc" "$HOME/.bash_profile" "$HOME/.zprofile")

        for config in "${shell_configs[@]}"; do
            if [[ -f "$config" ]] && grep -q "cc-manager" "$config"; then
                # Create backup
                cp "$config" "${config}.backup"

                # Remove cc-manager integration
                sed -i.bak '/# cc-manager shell integration/,+3d' "$config" 2>/dev/null || \
                sed -i '/# cc-manager shell integration/,+3d' "$config" 2>/dev/null || true

                print_success "Removed integration from $(basename "$config")"
            fi
        done
    else
        print_info "Shell integration preserved"
        print_warning "You may want to manually remove cc-manager integration from your shell rc files"
    fi
}

# Post-uninstall message
post_uninstall() {
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    print_success "cc-manager has been uninstalled"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""

    if [[ -d "$CONFIG_DIR" ]]; then
        echo "Configuration files remain at:"
        echo "  $CONFIG_DIR"
        echo ""
    fi

    echo "Thank you for using cc-manager!"
    echo ""
}

# Main uninstallation
main() {
    confirm_uninstall
    echo ""

    # Check if we need sudo
    if [[ ! -w "$PREFIX" ]]; then
        print_warning "Uninstallation requires elevated privileges"
        print_info "You may be prompted for your password"
        echo ""

        if ! sudo -v; then
            print_error "Sudo access required for uninstallation"
            exit 1
        fi

        # Remove files with sudo
        sudo rm -f "$BIN_DIR/cc-manager"
        sudo rm -rf "$LIB_DIR"
        print_success "Removed system files"
    else
        remove_files
    fi

    remove_config
    remove_cache
    remove_shell_integration

    post_uninstall
}

# Run uninstallation
main "$@"
