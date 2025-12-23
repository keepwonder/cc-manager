# ⚠️ IMPORTANT: Correct Usage Guide

## TL;DR

**After installation, you MUST use `cc-switch` (not `cc-manager switch`) for switching providers!**

```bash
# ✅ CORRECT
cc-switch deepseek

# ❌ WRONG - Environment variables won't persist!
cc-manager switch deepseek
```

## Why This Matters

When you run `cc-manager switch <provider>`, the command runs in a **subprocess**. Environment variables set in a subprocess don't affect your current shell - they disappear when the subprocess exits.

### The Problem

```bash
# You switch provider
$ cc-manager switch deepseek
✓ Switched to deepseek
  BASE_URL: https://api.deepseek.com/anthropic

# But the environment variable is not set in your shell
$ echo $ANTHROPIC_BASE_URL
https://open.bigmodel.cn/api/anthropic  # Still showing old value!

# And status shows wrong provider
$ cc-manager status
Provider: deepseek
BASE_URL: https://open.bigmodel.cn/api/anthropic  # Wrong! ❌
```

## The Solution: Use Shell Functions

The shell integration provides wrapper functions that properly set environment variables in your current shell.

### Setup (One Time)

During installation, you should have added shell integration. If not, add this to `~/.bashrc` or `~/.zshrc`:

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

Then reload:
```bash
source ~/.bashrc  # or ~/.zshrc
```

### Correct Usage

```bash
# ✅ Use shell function for switching
cc-switch deepseek

# ✅ Or use the shorthand
ccs deepseek

# ✅ Verify it worked
echo $ANTHROPIC_BASE_URL
# Should show: https://api.deepseek.com/anthropic

# ✅ Status should match
cc-manager status
# Shows correct BASE_URL ✓
```

## Command Reference

### For Switching (Needs Shell Integration)

| Command | Description | Use This |
|---------|-------------|----------|
| `cc-switch <provider>` | Switch provider (persistent) | ✅ YES |
| `ccs <provider>` | Switch and show status | ✅ YES |
| `cc-back` | Go back to previous | ✅ YES |

### For Read-Only Operations (No Integration Needed)

| Command | Description | Use This |
|---------|-------------|----------|
| `cc-manager list` | List providers | ✅ YES |
| `cc-manager status` | Show status | ✅ YES |
| `cc-manager test` | Test connection | ✅ YES |
| `cc-manager add <name>` | Add provider | ✅ YES |
| `cc-manager config` | Manage config | ✅ YES |

## Quick Test

Test if shell integration is working:

```bash
# 1. Check if function exists
type cc-switch
# Should output: cc-switch is a function

# 2. Switch provider
cc-switch deepseek

# 3. Check environment variable
echo $ANTHROPIC_BASE_URL
# Should show: https://api.deepseek.com/anthropic

# 4. Verify with status
cc-manager status
# BASE_URL should match the echo above
```

If `cc-switch` is not found, you need to source the shell integration file.

## Common Mistakes

### ❌ Mistake 1: Using Direct Command

```bash
# This won't work!
cc-manager switch deepseek
```

**Why**: Environment variables only set in subprocess

**Fix**: Use `cc-switch deepseek` instead

### ❌ Mistake 2: Not Sourcing Integration

```bash
# Integration not loaded
$ cc-switch deepseek
bash: cc-switch: command not found
```

**Fix**: Source the integration file or add to your shell rc file

### ❌ Mistake 3: Expecting Persistence in Subshells

```bash
# Won't work
(cc-switch deepseek)
echo $ANTHROPIC_BASE_URL  # Still old value
```

**Why**: Subshell has separate environment

**Fix**: Run in current shell (remove parentheses)

## Troubleshooting

### "cc-switch: command not found"

Shell integration not loaded. Fix:

```bash
# For system install
source /usr/local/lib/cc-manager/shell-integration.sh

# For user install
source ~/.local/lib/cc-manager/shell-integration.sh

# Then add to your ~/.bashrc or ~/.zshrc permanently
```

### Environment Variables Not Persisting

You're using `cc-manager switch` instead of `cc-switch`. Fix:

```bash
# Use this
cc-switch deepseek

# Not this
cc-manager switch deepseek
```

### Different Values in Different Terminals

Each terminal has its own environment. Switch in each terminal separately:

```bash
# In terminal 1
cc-switch deepseek

# In terminal 2 (need to switch again)
cc-switch deepseek
```

## Summary

| What You Want | Command to Use | Why |
|---------------|----------------|-----|
| Switch provider | `cc-switch <provider>` | Sets env vars in current shell |
| Quick switch + status | `ccs <provider>` | Convenient wrapper |
| Go back | `cc-back` | Uses shell function |
| List providers | `cc-manager list` | Read-only, no env needed |
| Show status | `cc-manager status` | Read-only |
| Test connection | `cc-manager test` | Read-only |
| Manage config | `cc-manager config` | Doesn't need env vars |

## More Information

See [docs/SHELL_INTEGRATION.md](docs/SHELL_INTEGRATION.md) for detailed explanation.

---

**Remember**: `cc-switch` for switching, `cc-manager` for everything else!
