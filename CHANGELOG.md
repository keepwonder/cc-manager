# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Removed
- Obsolete v1.0.x process documents (QUICK_FIX, IMPORTANT_USAGE, USAGE_GUIDE,
  QUICKSTART, PROJECT_SUMMARY, UNIFIED_COMMAND_SUMMARY, RELEASE_NOTES_v1.0.1/2):
  their content is covered by README / README.zh-CN, CHANGELOG, and docs/.
  The root now keeps only README (both languages), CHANGELOG, and CONTRIBUTING.

## [1.1.0] - 2026-08-18

### Added
- **Custom `env` blocks per provider**: any environment variables (e.g.
  `ANTHROPIC_DEFAULT_OPUS_MODEL`, `CLAUDE_CODE_AUTO_COMPACT_WINDOW`) can now
  be declared in a provider's `env:` section and are set on switch. Existing
  five fields are unchanged; old configs work as-is.
- `cc-manager add` interactively accepts extra `KEY=value` environment variables
- `cc-manager status` shows the current provider's custom env variables
- `cc-manager config validate` checks env variable name syntax
- Chinese README (`README.zh-CN.md`) with cross-links from the English README

### Changed
- Switching now unsets the union of all env-block variables declared across
  providers (derived from config), so values never leak between providers
- Export commands are single-quoted, making `eval` safe for values containing
  spaces, `$`, or quotes

### Fixed
- `config validate` aborted on the first error under `set -e` (`((errors++))`
  arithmetic trap); it now reports all errors

## [1.0.2] - 2025-12-23

### Changed
- **Unified command interface**: All commands now use `cc-manager` (no need for separate `cc-switch`)
- Redesigned shell integration to make `cc-manager` itself a smart shell function
- Improved user experience with clearer setup instructions

### Added
- Wrapper script that provides helpful messages when shell integration is not enabled
- `USAGE_GUIDE.md` with comprehensive usage instructions in Chinese
- Dual-binary architecture: `cc-manager` (wrapper) + `cc-manager-bin` (actual binary)

### Fixed
- Simplified command interface - no need to remember multiple command names
- Better error messages and user guidance

### Removed
- Deprecated separate `cc-switch`, `cc-back` commands (now unified under `cc-manager`)
- Simplified documentation by consolidating usage guides

## [1.0.1] - 2025-12-23

### Fixed
- **Critical**: Environment variables now persist correctly in current shell
  - `cc-manager switch` was setting variables only in subprocess
  - Added shell integration functions (`cc-switch`, `ccs`, `cc-back`)
  - Variables now properly injected into current shell session

### Added
- Shell integration wrapper functions for proper environment management
- `_output_export_commands()` function for exporting environment variables
- Comprehensive documentation in `docs/SHELL_INTEGRATION.md`
- `IMPORTANT_USAGE.md` for quick reference
- `RELEASE_NOTES_v1.0.1.md` for migration guide

### Changed
- Shell integration now provides `cc-switch` instead of using `cc-manager switch` directly
- Updated `ccmenu` to use new switch mechanism
- Enhanced `cc-back` to work with shell integration

### Documentation
- Added detailed shell integration guide
- Added important usage guide
- Updated examples to show correct usage
- Added troubleshooting section for environment variable issues

### Planned
- Homebrew formula for easy installation
- Fish shell support
- PowerShell support for Windows
- Provider health monitoring
- Usage statistics
- Configuration encryption
- Cloud configuration sync

## [1.0.0] - 2025-12-23

### Added
- Initial release
- Provider management (list, switch, add, remove)
- Configuration management (YAML-based)
- History management with back functionality
- Interactive menu for provider selection
- Connection testing
- Shell integration (Bash and Zsh)
- Comprehensive command-line interface
- Installation and uninstallation scripts
- Makefile for build automation
- Complete documentation
- Example configuration
- MIT License

### Features
- Support for multiple authentication types (API key and Auth token)
- Secure configuration file with proper permissions
- Color-coded output for better readability
- Tab completion for commands and providers
- Export/Import configuration
- Configuration validation
- Provider enable/disable functionality
- Temporary provider switching without changing current config

### Documentation
- Complete README with usage examples
- Installation guide
- Configuration reference
- Troubleshooting section
- Contributing guidelines

[Unreleased]: https://github.com/keepwonder/cc-manager/compare/v1.0.0...HEAD
[1.0.0]: https://github.com/keepwonder/cc-manager/releases/tag/v1.0.0
