#!/usr/bin/env bash
# ==============================================================================
# Utility Functions
# ==============================================================================

# Color codes
if [[ -t 1 ]]; then
    RED='\033[0;31m'
    GREEN='\033[0;32m'
    YELLOW='\033[0;33m'
    BLUE='\033[0;34m'
    CYAN='\033[0;36m'
    NC='\033[0m' # No Color
else
    RED=''
    GREEN=''
    YELLOW=''
    BLUE=''
    CYAN=''
    NC=''
fi

# Logging functions
log_error() {
    echo -e "${RED}✗${NC} $*" >&2
}

log_success() {
    echo -e "${GREEN}✓${NC} $*"
}

log_warning() {
    echo -e "${YELLOW}⚠${NC} $*"
}

log_info() {
    echo -e "${BLUE}ℹ${NC} $*"
}

log_debug() {
    if [[ "${CC_DEBUG:-}" == "1" ]]; then
        echo -e "${CYAN}DEBUG:${NC} $*" >&2
    fi
}

# Check if a command exists
command_exists() {
    command -v "$1" &> /dev/null
}

# Validate URL format
is_valid_url() {
    local url="$1"
    [[ "$url" =~ ^https?:// ]]
}

# Trim whitespace
trim() {
    local var="$*"
    var="${var#"${var%%[![:space:]]*}"}"
    var="${var%"${var##*[![:space:]]}"}"
    echo "$var"
}

# Get current timestamp
timestamp() {
    date +"%Y-%m-%d %H:%M:%S"
}

# Confirm action
confirm() {
    local prompt="${1:-Are you sure?}"
    echo -n "$prompt [y/N] "
    read -r answer
    [[ "$answer" =~ ^[Yy]$ ]]
}

# Display a spinner for long operations
spinner() {
    local pid=$1
    local delay=0.1
    local spinstr='|/-\'
    while ps -p "$pid" > /dev/null 2>&1; do
        local temp=${spinstr#?}
        printf " [%c]  " "$spinstr"
        local spinstr=$temp${spinstr%"$temp"}
        sleep $delay
        printf "\b\b\b\b\b\b"
    done
    printf "    \b\b\b\b"
}
