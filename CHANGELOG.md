# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

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

[Unreleased]: https://github.com/yourusername/cc-manager/compare/v1.0.0...HEAD
[1.0.0]: https://github.com/yourusername/cc-manager/releases/tag/v1.0.0
