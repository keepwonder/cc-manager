# Quick Start Guide

Get up and running with cc-manager in minutes!

## Installation

### Option 1: Quick Install (Recommended)

```bash
# Clone the repository
git clone https://github.com/yourusername/cc-manager.git
cd cc-manager

# Install to ~/.local (no sudo required)
make dev-install
```

### Option 2: System-wide Install

```bash
# Clone the repository
git clone https://github.com/yourusername/cc-manager.git
cd cc-manager

# Install to /usr/local (requires sudo)
make install
```

### Option 3: One-liner Install (Coming Soon)

```bash
curl -fsSL https://raw.githubusercontent.com/yourusername/cc-manager/main/install.sh | bash
```

## Initial Configuration

After installation, configure your API providers:

```bash
# Edit the configuration file
cc-manager config edit
```

Update the configuration with your API keys:

```yaml
version: "1.0"
default_provider: "deepseek"  # Choose your default

providers:
  deepseek:
    base_url: "https://api.deepseek.com/anthropic"
    auth_type: "auth_token"
    auth_token: "YOUR_ACTUAL_TOKEN_HERE"  # Replace with your token
    model: "deepseek-chat"
    enabled: true

  # Add more providers as needed
```

Save and exit (in vi/vim: press `Esc`, then type `:wq`).

## Basic Usage

### 1. List Providers

```bash
cc-manager list
```

Output:
```
Available Claude Code Providers:

→  deepseek        https://api.deepseek.com/anthropic
   glm             https://open.bigmodel.cn/api/anthropic
   aicodemirror    https://api.aicodemirror.com/api/claudecode
```

### 2. Check Status

```bash
cc-manager status
```

Output:
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Claude Code Configuration Status
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Provider:    deepseek

Environment Variables:
  BASE_URL:   https://api.deepseek.com/anthropic
  AUTH_TOKEN: ***b9d9fd
  MODEL:      deepseek-chat
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

### 3. Switch Providers

```bash
cc-manager switch glm
```

Output:
```
✓ Switched to glm
  BASE_URL: https://open.bigmodel.cn/api/anthropic
  MODEL: GLM-4.7
```

### 4. Test Connection

```bash
cc-manager test
```

Output:
```
Testing connection to https://api.deepseek.com/anthropic...
✓ Connection successful (HTTP 200)
```

### 5. Use with Claude Code

After switching to a provider, simply use Claude Code normally:

```bash
claude
```

The environment variables are automatically set!

## Common Tasks

### Switch and Check Status

```bash
cc-manager switch deepseek
cc-manager status
```

Or with shell integration:

```bash
ccs deepseek  # Switch and show status in one command
```

### Interactive Menu

Don't remember provider names? Use the interactive menu:

```bash
cc-manager menu
```

Select with numbers:
```
Select a Claude Code provider:

  1) aicodemirror
  2) deepseek
  3) glm
  0) Cancel

Enter selection: 2
```

### Go Back

Made a mistake? Go back to the previous provider:

```bash
cc-manager back
```

### Add a New Provider

```bash
cc-manager add my-provider
```

Follow the prompts:
```
Adding new provider: my-provider

Base URL: https://api.example.com
Auth type (api_key/auth_token): api_key
API Key: sk-your-key-here
Model (optional):

✓ Provider 'my-provider' added successfully
```

## Shell Integration (Optional but Recommended)

If you enabled shell integration during installation, you get convenient aliases:

```bash
ccm          # Short for cc-manager
ccm-ls       # List providers
ccm-st       # Show status
ccm-sw glm   # Switch provider
ccm-t        # Test connection
ccm-b        # Go back

ccs deepseek # Switch and show status
ccmenu       # Interactive menu
```

### Enable Shell Integration Manually

Add to your `~/.bashrc` or `~/.zshrc`:

```bash
# cc-manager shell integration
if [[ -f "/usr/local/lib/cc-manager/shell-integration.sh" ]]; then
    source "/usr/local/lib/cc-manager/shell-integration.sh"
fi
```

Or for user installation:

```bash
# cc-manager shell integration
if [[ -f "$HOME/.local/lib/cc-manager/shell-integration.sh" ]]; then
    source "$HOME/.local/lib/cc-manager/shell-integration.sh"
fi
```

Then reload your shell:

```bash
source ~/.bashrc  # or ~/.zshrc
```

## Troubleshooting

### Command Not Found

```bash
# Check installation
which cc-manager

# If using user install, add to PATH
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc
```

### Provider Not Working

```bash
# Validate configuration
cc-manager config validate

# Check status
cc-manager status

# Test connection
cc-manager test
```

### Reset Configuration

```bash
# This creates a backup and resets to defaults
cc-manager config reset
```

## Next Steps

- Read the full [README.md](README.md) for detailed documentation
- Check the [CHANGELOG.md](CHANGELOG.md) for version history
- Report issues on [GitHub](https://github.com/yourusername/cc-manager/issues)

## Cheat Sheet

```bash
# Core commands
cc-manager list              # List providers
cc-manager switch <name>     # Switch provider
cc-manager status            # Show status
cc-manager test              # Test connection
cc-manager back              # Go to previous

# Management
cc-manager add <name>        # Add provider
cc-manager remove <name>     # Remove provider
cc-manager edit [name]       # Edit config/provider

# Configuration
cc-manager config show       # Show config paths
cc-manager config edit       # Edit config
cc-manager config validate   # Validate config
cc-manager config reset      # Reset config

# History
cc-manager history           # Show history
cc-manager clear-history     # Clear history

# Helpers
cc-manager menu              # Interactive menu
cc-manager help              # Show help
cc-manager version           # Show version
```

## Getting Help

```bash
# Built-in help
cc-manager help

# Command-specific help
cc-manager switch --help
```

---

Happy coding with Claude! 🚀
