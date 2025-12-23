# cc-manager

> **Claude Code Provider Manager** - Easily manage and switch between Claude Code API providers

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Shell Script](https://img.shields.io/badge/Shell-Bash-green.svg)](https://www.gnu.org/software/bash/)

## Overview

`cc-manager` is a lightweight command-line tool that helps you manage multiple Claude Code API providers. Switch between different AI service providers, manage configurations, and track your usage history with ease.

## Features

- ✨ **Easy Provider Switching** - Switch between providers with a single command
- 🔐 **Secure Configuration** - Keep your API keys safe with proper file permissions
- 📊 **Status Monitoring** - View current provider and configuration at a glance
- 📝 **History Management** - Track provider switches and quickly go back
- 🎯 **Interactive Menu** - User-friendly menu for provider selection
- 🔍 **Connection Testing** - Test provider connectivity before use
- 🚀 **Shell Integration** - Aliases and completions for faster workflow
- 📦 **No Dependencies** - Pure Bash, works on any Unix-like system

## Quick Start

### Installation

```bash
# Clone the repository
git clone https://github.com/keepwonder/cc-manager.git
cd cc-manager

# Install (requires sudo for system-wide installation)
make install

# Or install to ~/.local (no sudo required)
make dev-install
```

### Configuration

Edit the configuration file to add your API keys:

```bash
# Edit configuration
cc-manager config edit

# Or directly with your preferred editor
$EDITOR ~/.config/cc-manager/config.yaml
```

### Basic Usage

```bash
# List all providers
cc-manager list

# Switch to a provider
cc-manager switch deepseek

# Check current status
cc-manager status

# Test connection
cc-manager test

# Go back to previous provider
cc-manager back
```

## Installation

### System-wide Installation

```bash
make install
```

This installs to `/usr/local` by default. You can customize the installation prefix:

```bash
PREFIX=/opt/cc-manager make install
```

### User Installation (No sudo)

```bash
make dev-install
```

This installs to `~/.local`.

### Manual Installation

```bash
# Run the installation script
bash install.sh

# For custom installation location
PREFIX=/custom/path bash install.sh
```

## Usage

### Commands

| Command | Alias | Description |
|---------|-------|-------------|
| `cc-manager switch <provider>` | `sw` | Switch to a specific provider |
| `cc-manager status` | `st` | Show current configuration status |
| `cc-manager list` | `ls` | List all available providers |
| `cc-manager menu` | `m` | Interactive provider selection menu |
| `cc-manager back` | `b` | Switch back to previous provider |
| `cc-manager test` | `t` | Test connection to current provider |
| `cc-manager run <provider>` | `r` | Run Claude Code with specific provider |
| `cc-manager add <name>` | `a` | Add a new provider interactively |
| `cc-manager remove <name>` | `rm` | Remove a provider |
| `cc-manager edit [name]` | `e` | Edit provider or config file |
| `cc-manager config [action]` | `cfg` | Manage configuration |
| `cc-manager history [limit]` | | Show switch history |
| `cc-manager clear-history` | `ch` | Clear switch history |
| `cc-manager export [file]` | | Export configuration |
| `cc-manager import <file>` | | Import configuration |
| `cc-manager version` | `v` | Show version information |
| `cc-manager help` | `h` | Show help message |

### Shell Aliases (with integration)

When shell integration is enabled, you get convenient aliases:

```bash
ccm              # Short for cc-manager
ccm-sw deepseek  # Switch provider
ccm-st           # Show status
ccm-ls           # List providers
ccm-t            # Test connection
ccm-b            # Go back

ccs deepseek     # Switch and show status
ccmenu           # Interactive menu
```

### Examples

#### Basic Workflow

```bash
# List available providers
cc-manager list

# Switch to DeepSeek
cc-manager switch deepseek

# Check status
cc-manager status

# Test connection
cc-manager test

# Run Claude Code
claude

# Switch to another provider
cc-manager switch glm

# Go back to DeepSeek
cc-manager back
```

#### Add a New Provider

```bash
# Interactive add
cc-manager add my-provider
# Follow the prompts to enter URL and credentials

# Or edit config directly
cc-manager config edit
```

#### Configuration Management

```bash
# Show config file locations
cc-manager config show

# Edit configuration
cc-manager config edit

# Validate configuration
cc-manager config validate

# Reset to defaults (with backup)
cc-manager config reset

# Export configuration
cc-manager export my-backup.yaml

# Import configuration
cc-manager import my-backup.yaml
```

#### History Management

```bash
# Show recent history
cc-manager history

# Show last 20 switches
cc-manager history 20

# Clear history
cc-manager clear-history
```

## Configuration

### Configuration File

The configuration file is located at `~/.config/cc-manager/config.yaml`:

```yaml
version: "1.0"
default_provider: "aicodemirror"

providers:
  aicodemirror:
    base_url: "https://api.aicodemirror.com/api/claudecode"
    auth_type: "api_key"
    api_key: "your-api-key-here"
    enabled: true

  deepseek:
    base_url: "https://api.deepseek.com/anthropic"
    auth_type: "auth_token"
    auth_token: "your-auth-token-here"
    model: "deepseek-chat"
    small_fast_model: "deepseek-chat"
    enabled: true
```

### Provider Configuration

Each provider requires:

- `base_url` - API endpoint URL (required)
- `auth_type` - Either `api_key` or `auth_token` (required)
- `api_key` or `auth_token` - Your credentials (required)
- `model` - Model name (optional)
- `small_fast_model` - Smaller/faster model (optional)
- `enabled` - Enable/disable provider (optional, default: true)

### Environment Variables

`cc-manager` respects these environment variables:

- `CC_MANAGER_HOME` - Override installation directory
- `CC_CONFIG_DIR` - Override config directory (default: `~/.config/cc-manager`)
- `EDITOR` - Preferred text editor for config editing
- `CC_DEBUG` - Enable debug output (set to `1`)

## Development

### Project Structure

```
cc-manager/
├── bin/
│   └── cc-manager          # Main executable
├── lib/
│   ├── core.sh             # Core functionality
│   ├── config.sh           # Configuration management
│   ├── providers.sh        # Provider management
│   ├── history.sh          # History management
│   └── utils.sh            # Utility functions
├── config/
│   └── config.example.yaml # Example configuration
├── scripts/
│   └── shell-integration.sh # Shell integration
├── docs/
│   └── ...                 # Documentation
├── tests/
│   └── ...                 # Test scripts
├── install.sh              # Installation script
├── uninstall.sh            # Uninstallation script
├── Makefile                # Build automation
└── README.md               # This file
```

### Running Tests

```bash
make test
```

### Syntax Check

```bash
make check-syntax
```

### Validation

```bash
make validate
```

## Troubleshooting

### Command Not Found

If `cc-manager` is not found after installation:

```bash
# Check if binary exists
ls -la /usr/local/bin/cc-manager

# Or for user installation
ls -la ~/.local/bin/cc-manager

# Add to PATH if needed
export PATH="$PATH:~/.local/bin"
```

### Configuration Issues

```bash
# Validate configuration
cc-manager config validate

# Reset to defaults
cc-manager config reset

# Check config file location
cc-manager config show
```

### Provider Not Working

```bash
# Test connection
cc-manager test

# Check status
cc-manager status

# Validate configuration
cc-manager config validate
```

## Uninstallation

```bash
# System-wide
make uninstall

# User installation
make dev-uninstall

# Or run the script directly
bash uninstall.sh
```

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- Built for [Claude Code](https://github.com/anthropics/claude-code)
- Inspired by version managers like `nvm`, `rbenv`, etc.

## Support

- 📖 [Documentation](docs/)
- 🐛 [Issue Tracker](https://github.com/yourusername/cc-manager/issues)
- 💬 [Discussions](https://github.com/yourusername/cc-manager/discussions)

## Roadmap

- [ ] Homebrew formula
- [ ] Fish shell support
- [ ] PowerShell support for Windows
- [ ] Provider health monitoring
- [ ] Usage statistics
- [ ] Configuration encryption
- [ ] Cloud configuration sync

---

Made with ❤️ for the Claude Code community
