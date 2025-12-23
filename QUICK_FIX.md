# 🚀 Quick Fix for Environment Variable Issue

## The Problem You Encountered

```bash
jone@kvm-aigc:/data/cc-manager$ cc-manager sw deepseek
✓ Switched to deepseek
  BASE_URL: https://api.deepseek.com/anthropic

jone@kvm-aigc:/data/cc-manager$ cc-manager st
Provider:    deepseek
BASE_URL:    https://open.bigmodel.cn/api/anthropic  # ❌ Wrong!
```

## Why This Happens

`cc-manager` runs as a subprocess. Environment variables set in a subprocess don't affect the parent shell.

## The Solution (2 Steps)

### Step 1: Update to v1.0.1

On your remote server:

```bash
cd /data/cc-manager

# Pull latest version
git pull

# Or if you downloaded manually, re-download the files
# Make sure you have the updated files:
# - lib/providers.sh
# - scripts/shell-integration.sh
```

### Step 2: Enable Shell Integration

Add this to your `~/.bashrc`:

```bash
# cc-manager shell integration
if [[ -f "/usr/local/lib/cc-manager/shell-integration.sh" ]]; then
    source "/usr/local/lib/cc-manager/shell-integration.sh"
elif [[ -f "/data/cc-manager/scripts/shell-integration.sh" ]]; then
    # For development/manual install
    source "/data/cc-manager/scripts/shell-integration.sh"
fi
```

Then reload:

```bash
source ~/.bashrc
```

### Step 3: Use the New Commands

```bash
# ✅ Use this (shell function)
cc-switch deepseek

# ✅ Or this shorthand
ccs deepseek

# ❌ Don't use this anymore for switching
cc-manager switch deepseek
```

## Verify It Works

```bash
# 1. Switch provider
cc-switch deepseek

# 2. Check environment variable directly
echo $ANTHROPIC_BASE_URL
# Should show: https://api.deepseek.com/anthropic

# 3. Verify status matches
cc-manager status
# Should show the same BASE_URL ✓
```

## One-Liner Fix (For Your Server)

```bash
# Add shell integration and reload
echo 'source /data/cc-manager/scripts/shell-integration.sh' >> ~/.bashrc && source ~/.bashrc && cc-switch deepseek && cc-manager status
```

## Before and After

### Before (Broken)
```bash
$ cc-manager switch deepseek
✓ Switched to deepseek
  BASE_URL: https://api.deepseek.com/anthropic

$ cc-manager status
BASE_URL: https://open.bigmodel.cn/api/anthropic  # ❌ Wrong
```

### After (Fixed)
```bash
$ cc-switch deepseek
✓ Switched to deepseek
  BASE_URL: https://api.deepseek.com/anthropic

$ echo $ANTHROPIC_BASE_URL
https://api.deepseek.com/anthropic  # ✓ Correct

$ cc-manager status
BASE_URL: https://api.deepseek.com/anthropic  # ✓ Matches!
```

## Quick Reference Card

| Task | Command | Works? |
|------|---------|--------|
| Switch provider | `cc-switch deepseek` | ✅ |
| Switch + status | `ccs deepseek` | ✅ |
| Go back | `cc-back` | ✅ |
| List providers | `cc-manager list` | ✅ |
| Show status | `cc-manager status` | ✅ |
| Test connection | `cc-manager test` | ✅ |
| ~~Old switch~~ | ~~`cc-manager switch`~~ | ❌ |

## More Help

- Full guide: [IMPORTANT_USAGE.md](IMPORTANT_USAGE.md)
- Detailed docs: [docs/SHELL_INTEGRATION.md](docs/SHELL_INTEGRATION.md)
- Release notes: [RELEASE_NOTES_v1.0.1.md](RELEASE_NOTES_v1.0.1.md)
