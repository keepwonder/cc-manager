# Contributing to cc-manager

Thank you for your interest in contributing to cc-manager! This document provides guidelines and instructions for contributing.

## Code of Conduct

Be respectful, inclusive, and professional in all interactions.

## How Can I Contribute?

### Reporting Bugs

Before creating bug reports, please check existing issues. When creating a bug report, include:

- Clear, descriptive title
- Exact steps to reproduce
- Expected vs actual behavior
- Environment details (OS, shell, version)
- Error messages and logs
- Configuration (with secrets removed)

Use the bug report template in `.github/ISSUE_TEMPLATE/bug_report.md`.

### Suggesting Features

Feature suggestions are welcome! Include:

- Clear use case
- Expected behavior
- Why it would be useful
- Possible implementation approach

Use the feature request template in `.github/ISSUE_TEMPLATE/feature_request.md`.

### Code Contributions

#### Development Setup

1. **Fork and clone**
   ```bash
   git clone https://github.com/YOUR_USERNAME/cc-manager.git
   cd cc-manager
   ```

2. **Install for development**
   ```bash
   make dev-install
   ```

3. **Make changes**
   - Edit files in `lib/`, `bin/`, etc.
   - Follow existing code style
   - Add comments for complex logic

4. **Test your changes**
   ```bash
   # Check syntax
   make check-syntax

   # Run tests
   make test

   # Validate structure
   make validate
   ```

5. **Commit your changes**
   ```bash
   git add .
   git commit -m "Brief description of changes"
   ```

6. **Push and create PR**
   ```bash
   git push origin your-branch-name
   ```
   Then create a pull request on GitHub.

#### Coding Standards

**Shell Script Guidelines:**

1. **Use bash-compatible syntax**
   - Test with `bash -n script.sh`
   - Avoid bashisms if possible

2. **Error handling**
   ```bash
   set -e  # Exit on error

   # Check return values
   if ! some_command; then
       log_error "Command failed"
       return 1
   fi
   ```

3. **Variables**
   ```bash
   # Use UPPER_CASE for constants
   CONFIG_DIR="/etc/cc-manager"

   # Use lower_case for locals
   local provider="deepseek"

   # Quote variables
   echo "$provider"
   rm -f "$file"
   ```

4. **Functions**
   ```bash
   # Clear function names
   switch_provider() {
       local provider="$1"
       # ...
   }

   # Document complex functions
   # Description: Switches to a provider
   # Arguments: $1 - provider name
   # Returns: 0 on success, 1 on error
   ```

5. **Comments**
   ```bash
   # Explain why, not what
   # Load config before switching (needed for validation)
   load_config
   ```

6. **Output**
   ```bash
   # Use logging functions
   log_success "Operation completed"
   log_error "Operation failed"
   log_warning "Warning message"
   log_info "Info message"
   ```

#### Testing

**Add tests for new features:**

```bash
# In tests/test-your-feature.sh
assert_eq "expected" "actual" "Feature X should work"
assert_file_exists "/path/to/file" "File should exist"
```

**Run tests before submitting:**

```bash
make test
```

#### Documentation

Update documentation for:
- New commands: Update README.md and `cc-manager help`
- Configuration changes: Update config.example.yaml
- API changes: Update relevant docs

#### Pull Request Process

1. **Before submitting:**
   - [ ] Tests pass (`make test`)
   - [ ] Syntax is valid (`make check-syntax`)
   - [ ] Documentation is updated
   - [ ] Commits are clear and atomic
   - [ ] No sensitive information in code

2. **PR description should include:**
   - What problem it solves
   - How it solves it
   - Any breaking changes
   - Testing performed

3. **Review process:**
   - Maintainers will review your PR
   - Address feedback and comments
   - Once approved, it will be merged

#### Commit Messages

Format:
```
type: Brief description (50 chars or less)

More detailed explanation if needed (wrap at 72 chars).
Explain what and why, not how.

Fixes #123
```

Types:
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation
- `style`: Formatting, no code change
- `refactor`: Code refactoring
- `test`: Adding tests
- `chore`: Maintenance tasks

Examples:
```
feat: Add provider health check command

Implements a new `health` command that checks if all configured
providers are accessible.

Fixes #42
```

```
fix: Handle missing config file gracefully

Previously crashed when config file was missing. Now creates a
default config with user prompt.

Fixes #56
```

## Project Structure

```
cc-manager/
├── bin/cc-manager          # Main entry point
├── lib/                    # Core functionality
│   ├── core.sh            # Command dispatcher
│   ├── config.sh          # Config management
│   ├── providers.sh       # Provider operations
│   ├── history.sh         # History tracking
│   └── utils.sh           # Utilities
├── config/                # Configuration templates
├── scripts/               # Shell integration
├── tests/                 # Test suite
└── docs/                  # Documentation
```

When adding features:
- Core logic → `lib/`
- New commands → `lib/core.sh` (cmd_* functions)
- Utilities → `lib/utils.sh`
- Tests → `tests/`

## Release Process

(For maintainers)

1. Update version in:
   - `lib/core.sh` (`CC_MANAGER_VERSION`)
   - `Makefile` (`VERSION`)
   - `CHANGELOG.md`

2. Create release commit:
   ```bash
   git commit -m "Release v1.x.x"
   git tag -a v1.x.x -m "Release v1.x.x"
   git push origin main --tags
   ```

3. Create GitHub release with changelog

## Questions?

- Check existing issues
- Ask in GitHub Discussions
- Contact maintainers

## Recognition

Contributors will be recognized in:
- CHANGELOG.md
- GitHub contributors page
- Release notes (for significant contributions)

Thank you for contributing! 🎉
