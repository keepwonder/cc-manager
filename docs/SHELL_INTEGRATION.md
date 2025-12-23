# Shell Integration Guide

## The Environment Variable Problem

When you run `cc-manager switch <provider>`, the environment variables are set **inside the cc-manager process**, but they don't persist in your current shell session. This is a fundamental limitation of how processes work in Unix/Linux.

### Example of the Problem

```bash
$ cc-manager switch deepseek
✓ Switched to deepseek
  BASE_URL: https://api.deepseek.com/anthropic

$ cc-manager status
# Shows different BASE_URL! ❌
```

## The Solution: Shell Integration

To make environment variables persist in your current shell, you need to source the shell integration script. This provides wrapper functions that properly set environment variables.

## Installation

### Automatic (During Install)

If you chose "Yes" during installation, shell integration is already set up.

### Manual Setup

Add this to your `~/.bashrc` or `~/.zshrc`:

```bash
# cc-manager shell integration
if [[ -f "/usr/local/lib/cc-manager/shell-integration.sh" ]]; then
    source "/usr/local/lib/cc-manager/shell-integration.sh"
fi
```

Or for user installation (`~/.local`):

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

## Usage After Integration

Once shell integration is enabled, use these commands:

### ✅ Correct Way (With Shell Integration)

```bash
# Use the shell function (no cc-manager prefix)
cc-switch deepseek

# Or use the wrapper
ccs deepseek

# Go back
cc-back
```

### ❌ Wrong Way (Direct Command)

```bash
# Don't use this - environment variables won't persist
cc-manager switch deepseek
```

## Available Shell Functions

After sourcing shell integration, you get these functions:

### Primary Functions

| Function | Description | Example |
|----------|-------------|---------|
| `cc-switch <provider>` | Switch provider with environment variable injection | `cc-switch deepseek` |
| `ccs <provider>` | Switch and show status | `ccs deepseek` |
| `cc-back` | Go back to previous provider | `cc-back` |
| `ccmenu` | Interactive menu | `ccmenu` |

### Aliases

| Alias | Maps to | Description |
|-------|---------|-------------|
| `ccm` | `cc-manager` | Short for cc-manager |
| `ccm-sw` | `cc-manager switch` | For non-persistent switch |
| `ccm-st` | `cc-manager status` | Show status |
| `ccm-ls` | `cc-manager list` | List providers |
| `ccm-t` | `cc-manager test` | Test connection |
| `ccm-b` | `cc-manager back` | Back (non-persistent) |

## How It Works

The shell integration script provides wrapper functions that:

1. Call `cc-manager` with a special flag to output export commands
2. Capture those export commands
3. Eval them in the current shell (using `eval`)

This ensures environment variables are set in your **current shell**, not just in a subprocess.

## Verification

Test if shell integration is working:

```bash
# 1. Switch provider
cc-switch deepseek

# 2. Check environment variable directly
echo $ANTHROPIC_BASE_URL
# Should show: https://api.deepseek.com/anthropic

# 3. Verify with status
cc-manager status
# Should show the same URL ✓
```

## Troubleshooting

### Shell Integration Not Working

**Symptom**: Environment variables don't persist

**Solution**:
```bash
# Check if shell integration is loaded
type cc-switch
# Should show: cc-switch is a function

# If not found, source it manually
source /usr/local/lib/cc-manager/shell-integration.sh

# Or for user install
source ~/.local/lib/cc-manager/shell-integration.sh
```

### Functions Not Found

**Symptom**: `cc-switch: command not found`

**Solution**:
1. Make sure you sourced the integration file
2. Restart your shell or reload config:
   ```bash
   source ~/.bashrc  # or ~/.zshrc
   ```

### Environment Variables Still Wrong

**Symptom**: Status shows wrong provider after switch

**Causes**:
1. You used `cc-manager switch` instead of `cc-switch`
2. Shell integration not loaded
3. Multiple shells open with different states

**Solution**:
- Always use `cc-switch` (shell function) not `cc-manager switch`
- Check with `echo $ANTHROPIC_BASE_URL` to verify

## Best Practices

### ✅ DO

```bash
# Use shell functions for switching
cc-switch deepseek
ccs glm
cc-back

# Use cc-manager for read-only operations
cc-manager list
cc-manager status
cc-manager test
cc-manager history
```

### ❌ DON'T

```bash
# Don't use direct command for switching
cc-manager switch deepseek  # Won't persist!

# Don't expect persistence in subshells
(cc-switch deepseek)  # Won't affect parent shell
```

## For Script Usage

If you're using cc-manager in scripts where environment variable persistence is needed:

```bash
#!/bin/bash

# Source shell integration
source /usr/local/lib/cc-manager/shell-integration.sh

# Now you can switch
cc-switch deepseek

# And use the variables
echo "Using: $ANTHROPIC_BASE_URL"
```

Or get export commands manually:

```bash
#!/bin/bash

# Get export commands and eval them
eval "$(CC_EXPORT_MODE=1 cc-manager switch deepseek 2>&1 | grep -A 100 '# cc-manager export' | grep '^export\|^unset')"

# Now use the variables
echo "Using: $ANTHROPIC_BASE_URL"
```

## Uninstalling Shell Integration

To remove shell integration:

1. Remove the lines from your `~/.bashrc` or `~/.zshrc`
2. Reload shell or start a new terminal
3. The shell functions will no longer be available

## Summary

| Operation | Command | Persists in Shell? |
|-----------|---------|-------------------|
| Switch (integrated) | `cc-switch <provider>` | ✅ Yes |
| Switch (direct) | `cc-manager switch <provider>` | ❌ No |
| Status | `cc-manager status` | N/A (read-only) |
| List | `cc-manager list` | N/A (read-only) |

**Remember**: Use `cc-switch` for switching, `cc-manager` for everything else!
