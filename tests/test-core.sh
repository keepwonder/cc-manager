#!/usr/bin/env bash
# ==============================================================================
# Test Suite for cc-manager
# ==============================================================================

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m'

# Test counters
TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0

# Test helpers
assert_eq() {
    local expected="$1"
    local actual="$2"
    local message="${3:-Assertion failed}"

    ((TESTS_RUN++))

    if [[ "$expected" == "$actual" ]]; then
        echo -e "${GREEN}✓${NC} $message"
        ((TESTS_PASSED++))
        return 0
    else
        echo -e "${RED}✗${NC} $message"
        echo "  Expected: $expected"
        echo "  Actual:   $actual"
        ((TESTS_FAILED++))
        return 1
    fi
}

assert_file_exists() {
    local file="$1"
    local message="${2:-File should exist: $file}"

    ((TESTS_RUN++))

    if [[ -f "$file" ]]; then
        echo -e "${GREEN}✓${NC} $message"
        ((TESTS_PASSED++))
        return 0
    else
        echo -e "${RED}✗${NC} $message"
        ((TESTS_FAILED++))
        return 1
    fi
}

assert_command_exists() {
    local cmd="$1"
    local message="${2:-Command should exist: $cmd}"

    ((TESTS_RUN++))

    if command -v "$cmd" &> /dev/null; then
        echo -e "${GREEN}✓${NC} $message"
        ((TESTS_PASSED++))
        return 0
    else
        echo -e "${RED}✗${NC} $message"
        ((TESTS_FAILED++))
        return 1
    fi
}

# Setup test environment
setup() {
    echo "Setting up test environment..."
    export CC_CONFIG_DIR="/tmp/cc-manager-test-$$"
    export CC_CACHE_DIR="/tmp/cc-manager-test-cache-$$"
    mkdir -p "$CC_CONFIG_DIR"
    mkdir -p "$CC_CACHE_DIR"
}

# Cleanup test environment
cleanup() {
    echo "Cleaning up test environment..."
    rm -rf "/tmp/cc-manager-test-$$"
    rm -rf "/tmp/cc-manager-test-cache-$$"
}

# Run tests
run_tests() {
    echo "================================"
    echo "cc-manager Test Suite"
    echo "================================"
    echo ""

    # Test 1: Check if main script exists
    echo "Test 1: Main script existence"
    assert_file_exists "../bin/cc-manager" "Main script should exist"
    echo ""

    # Test 2: Check if libraries exist
    echo "Test 2: Library files existence"
    assert_file_exists "../lib/core.sh" "core.sh should exist"
    assert_file_exists "../lib/config.sh" "config.sh should exist"
    assert_file_exists "../lib/providers.sh" "providers.sh should exist"
    assert_file_exists "../lib/history.sh" "history.sh should exist"
    assert_file_exists "../lib/utils.sh" "utils.sh should exist"
    echo ""

    # Test 3: Check syntax of all shell scripts
    echo "Test 3: Syntax validation"
    ((TESTS_RUN++))
    if bash -n "../bin/cc-manager" &> /dev/null; then
        echo -e "${GREEN}✓${NC} Main script syntax is valid"
        ((TESTS_PASSED++))
    else
        echo -e "${RED}✗${NC} Main script has syntax errors"
        ((TESTS_FAILED++))
    fi

    for lib in ../lib/*.sh; do
        ((TESTS_RUN++))
        if bash -n "$lib" &> /dev/null; then
            echo -e "${GREEN}✓${NC} $(basename "$lib") syntax is valid"
            ((TESTS_PASSED++))
        else
            echo -e "${RED}✗${NC} $(basename "$lib") has syntax errors"
            ((TESTS_FAILED++))
        fi
    done
    echo ""

    # Test 4: Check installation scripts
    echo "Test 4: Installation scripts"
    assert_file_exists "../install.sh" "install.sh should exist"
    assert_file_exists "../uninstall.sh" "uninstall.sh should exist"

    ((TESTS_RUN++))
    if bash -n "../install.sh" &> /dev/null; then
        echo -e "${GREEN}✓${NC} install.sh syntax is valid"
        ((TESTS_PASSED++))
    else
        echo -e "${RED}✗${NC} install.sh has syntax errors"
        ((TESTS_FAILED++))
    fi

    ((TESTS_RUN++))
    if bash -n "../uninstall.sh" &> /dev/null; then
        echo -e "${GREEN}✓${NC} uninstall.sh syntax is valid"
        ((TESTS_PASSED++))
    else
        echo -e "${RED}✗${NC} uninstall.sh has syntax errors"
        ((TESTS_FAILED++))
    fi
    echo ""

    # Test 5: Check configuration example
    echo "Test 5: Configuration files"
    assert_file_exists "../config/config.example.yaml" "Example config should exist"
    echo ""

    # Print summary
    echo "================================"
    echo "Test Summary"
    echo "================================"
    echo "Tests run:    $TESTS_RUN"
    echo -e "Tests passed: ${GREEN}$TESTS_PASSED${NC}"
    echo -e "Tests failed: ${RED}$TESTS_FAILED${NC}"
    echo ""

    if [[ $TESTS_FAILED -eq 0 ]]; then
        echo -e "${GREEN}All tests passed!${NC}"
        return 0
    else
        echo -e "${RED}Some tests failed!${NC}"
        return 1
    fi
}

# Main
main() {
    # Change to script directory
    cd "$(dirname "$0")"

    setup
    trap cleanup EXIT

    run_tests
    exit $?
}

main "$@"
