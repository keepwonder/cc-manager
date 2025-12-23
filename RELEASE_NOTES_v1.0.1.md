# Release Notes v1.0.1

## Critical Fix: Environment Variable Persistence

### Problem Fixed

In v1.0.0, when users ran `cc-manager switch <provider>`, the environment variables were not persisting in the current shell session. This was because environment variables set in a subprocess don't affect the parent shell.

**Example of the bug:**
```bash
$ cc-manager switch deepseek
✓ Switched to deepseek
  BASE_URL: https://api.deepseek.com/anthropic

$ cc-manager status
# Showed wrong BASE_URL! ❌
Provider: deepseek
BASE_URL: https://open.bigmodel.cn/api/anthropic  # Old value
```

### Solution

Added shell integration functions that properly inject environment variables into the current shell.

**Now it works correctly:**
```bash
$ cc-switch deepseek  # Use shell function instead
✓ Switched to deepseek
  BASE_URL: https://api.deepseek.com/anthropic

$ echo $ANTHROPIC_BASE_URL
https://api.deepseek.com/anthropic  # Correct! ✓

$ cc-manager status
Provider: deepseek
BASE_URL: https://api.deepseek.com/anthropic  # Matches! ✓
```

## What Changed

### New Shell Functions

When shell integration is enabled, you get these new functions:

- `cc-switch <provider>` - Switch with environment variable injection
- `ccs <provider>` - Switch and show status
- `cc-back` - Go back to previous provider
- `ccmenu` - Interactive menu

### Updated Files

- `lib/providers.sh` - Added `_output_export_commands()` function
- `scripts/shell-integration.sh` - Added wrapper functions
- `docs/SHELL_INTEGRATION.md` - New comprehensive guide
- `IMPORTANT_USAGE.md` - Quick reference for correct usage

## Migration Guide

### For Existing Users

If you already have v1.0.0 installed:

1. **Pull/download the latest version**

2. **Reinstall** (updates shell integration):
   ```bash
   cd cc-manager
   make dev-install  # or make install
   ```

3. **Reload your shell**:
   ```bash
   source ~/.bashrc  # or ~/.zshrc
   ```

4. **Verify shell integration**:
   ```bash
   type cc-switch
   # Should output: cc-switch is a function
   ```

5. **Use new commands**:
   ```bash
   # Old way (doesn't work properly)
   cc-manager switch deepseek  ❌

   # New way (works correctly)
   cc-switch deepseek  ✅
   ```

### Command Changes

| Old (v1.0.0) | New (v1.0.1) | Notes |
|--------------|--------------|-------|
| `cc-manager switch <provider>` | `cc-switch <provider>` | Use shell function |
| `cc-manager back` | `cc-back` | Use shell function |
| `cc-manager list` | `cc-manager list` | Unchanged |
| `cc-manager status` | `cc-manager status` | Unchanged |

## Quick Reference

### ✅ Correct Usage

```bash
# Switching (use shell functions)
cc-switch deepseek
ccs glm
cc-back

# Read-only operations (use cc-manager directly)
cc-manager list
cc-manager status
cc-manager test
cc-manager config
```

### ❌ Wrong Usage

```bash
# Don't use cc-manager for switching
cc-manager switch deepseek  # Won't persist environment variables!
```

## Testing

Run these commands to verify the fix:

```bash
# 1. Check shell integration
type cc-switch

# 2. Switch provider
cc-switch deepseek

# 3. Verify environment variable
echo $ANTHROPIC_BASE_URL

# 4. Check status matches
cc-manager status
```

All should show consistent values.

## Documentation

New documentation added:

- [`IMPORTANT_USAGE.md`](IMPORTANT_USAGE.md) - Quick start for correct usage
- [`docs/SHELL_INTEGRATION.md`](docs/SHELL_INTEGRATION.md) - Detailed guide

## Breaking Changes

**None** - All existing `cc-manager` commands still work for read-only operations.

**Behavior Change** - For provider switching to work correctly, you must:
1. Have shell integration enabled (automatic during install)
2. Use `cc-switch` instead of `cc-manager switch`

## Known Issues

None

## Credits

Thanks to user feedback for reporting the environment variable persistence issue!

---

**Version**: 1.0.1
**Release Date**: 2025-12-23
**Previous Version**: 1.0.0
