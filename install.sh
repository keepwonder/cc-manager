#!/usr/bin/env bash
# ==============================================================================
# cc-manager Installation Script
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
CACHE_DIR="${HOME}/.cache/cc-manager"

# Determine script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

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

# Check prerequisites
check_prerequisites() {
    print_info "Checking prerequisites..."

    # Check if running on supported OS
    case "$(uname -s)" in
        Darwin|Linux)
            print_success "Operating system: $(uname -s)"
            ;;
        *)
            print_error "Unsupported operating system: $(uname -s)"
            echo "This installer supports macOS and Linux only"
            exit 1
            ;;
    esac

    # Check for bash
    if ! command -v bash &> /dev/null; then
        print_error "bash not found"
        exit 1
    fi
    print_success "bash found: $(bash --version | head -1)"

    # Check for required commands
    for cmd in curl sed; do
        if ! command -v "$cmd" &> /dev/null; then
            print_warning "$cmd not found (optional)"
        fi
    done
}

# Install files
install_files() {
    print_info "Installing cc-manager..."

    # Create directories
    mkdir -p "$BIN_DIR"
    mkdir -p "$LIB_DIR"
    mkdir -p "$CONFIG_DIR"
    mkdir -p "$CACHE_DIR"

    # Install binaries
    if [[ -f "$SCRIPT_DIR/bin/cc-manager" ]]; then
        install -m 755 "$SCRIPT_DIR/bin/cc-manager" "$BIN_DIR/cc-manager"
        print_success "Installed wrapper to $BIN_DIR/cc-manager"
    else
        print_error "Wrapper not found: $SCRIPT_DIR/bin/cc-manager"
        exit 1
    fi

    if [[ -f "$SCRIPT_DIR/bin/cc-manager-bin" ]]; then
        install -m 755 "$SCRIPT_DIR/bin/cc-manager-bin" "$BIN_DIR/cc-manager-bin"
        print_success "Installed binary to $BIN_DIR/cc-manager-bin"
    else
        print_error "Binary not found: $SCRIPT_DIR/bin/cc-manager-bin"
        exit 1
    fi

    # Install libraries
    for lib in core.sh config.sh providers.sh history.sh utils.sh; do
        if [[ -f "$SCRIPT_DIR/lib/$lib" ]]; then
            install -m 644 "$SCRIPT_DIR/lib/$lib" "$LIB_DIR/$lib"
            print_success "Installed library: $lib"
        else
            print_error "Library not found: $SCRIPT_DIR/lib/$lib"
            exit 1
        fi
    done

    # Install shell integration script if exists
    if [[ -f "$SCRIPT_DIR/scripts/shell-integration.sh" ]]; then
        install -m 644 "$SCRIPT_DIR/scripts/shell-integration.sh" "$LIB_DIR/shell-integration.sh"
        print_success "Installed shell integration script"
    fi

    # Create default config if not exists
    if [[ ! -f "$CONFIG_DIR/config.yaml" ]]; then
        if [[ -f "$SCRIPT_DIR/config/config.example.yaml" ]]; then
            cp "$SCRIPT_DIR/config/config.example.yaml" "$CONFIG_DIR/config.yaml"
            chmod 600 "$CONFIG_DIR/config.yaml"
            print_success "Created default config"
        fi
    else
        print_info "Config already exists, skipping"
    fi
}

# Setup shell integration
setup_shell_integration() {
    print_info "Setting up shell integration..."

    local shell_config=""
    local shell_name=""

    # Detect shell
    if [[ -n "$BASH_VERSION" ]]; then
        shell_name="bash"
        shell_config="$HOME/.bashrc"
    elif [[ -n "$ZSH_VERSION" ]]; then
        shell_name="zsh"
        shell_config="$HOME/.zshrc"
    else
        shell_name=$(basename "$SHELL")
        case "$shell_name" in
            bash)
                shell_config="$HOME/.bashrc"
                ;;
            zsh)
                shell_config="$HOME/.zshrc"
                ;;
            *)
                print_warning "Unknown shell: $shell_name"
                print_info "You may need to manually source shell integration"
                return 0
                ;;
        esac
    fi

    print_info "Detected shell: $shell_name"

    # Check if already integrated
    if [[ -f "$shell_config" ]] && grep -q "cc-manager" "$shell_config"; then
        print_info "Shell integration already configured"
        return 0
    fi

    # Ask user if they want to add integration
    echo ""
    echo "Would you like to add shell integration to $shell_config?"
    echo "This will add aliases and completion for cc-manager."
    echo -n "Add integration? [Y/n] "
    read -r answer

    if [[ ! "$answer" =~ ^[Nn]$ ]]; then
        {
            echo ""
            echo "# cc-manager shell integration"
            echo "if [[ -f \"$LIB_DIR/shell-integration.sh\" ]]; then"
            echo "    source \"$LIB_DIR/shell-integration.sh\""
            echo "fi"
        } >> "$shell_config"

        print_success "Shell integration added to $shell_config"
        print_warning "Please restart your shell or run: source $shell_config"
    else
        print_info "Skipped shell integration"
    fi
}

# Post-installation message
post_install() {
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    print_success "cc-manager installed successfully!"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "Installation directories:"
    echo "  Binary:  $BIN_DIR/cc-manager"
    echo "  Library: $LIB_DIR"
    echo "  Config:  $CONFIG_DIR"
    echo ""
    echo "Next steps:"
    echo "  1. Edit your configuration:"
    echo "     \$EDITOR $CONFIG_DIR/config.yaml"
    echo ""
    echo "  2. Verify installation:"
    echo "     cc-manager version"
    echo ""
    echo "  3. List providers:"
    echo "     cc-manager list"
    echo ""
    echo "  4. Switch to a provider:"
    echo "     cc-manager switch <provider-name>"
    echo ""
    echo "For help, run: cc-manager help"
    echo ""
}

# Main installation
main() {
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "  cc-manager Installation"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""

    # Check if we need sudo
    if [[ ! -w "$PREFIX" ]]; then
        print_warning "Installation directory requires elevated privileges"
        print_info "You may be prompted for your password"
        echo ""

        if ! sudo -v; then
            print_error "Sudo access required for installation"
            exit 1
        fi

        # Re-run with sudo
        exec sudo bash "$0" "$@"
    fi

    check_prerequisites
    echo ""

    install_files
    echo ""

    setup_shell_integration
    echo ""

    post_install
}

# Run installation
main "$@"
