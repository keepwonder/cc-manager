#!/usr/bin/env bash
# ==============================================================================
# cc-manager core library
# ==============================================================================

# Version
CC_MANAGER_VERSION="1.0.0"

# Load other modules
CC_LIB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${CC_LIB_DIR}/config.sh"
source "${CC_LIB_DIR}/providers.sh"
source "${CC_LIB_DIR}/history.sh"
source "${CC_LIB_DIR}/utils.sh"

# Initialize on load
init_cc_manager() {
    # Ensure configuration directory exists
    mkdir -p "${CC_CONFIG_DIR}"
    mkdir -p "${CC_CACHE_DIR}"

    # Create default config if not exists
    if [[ ! -f "${CC_CONFIG_FILE}" ]]; then
        create_default_config
    fi

    # Load configuration
    load_config

    # Initialize history
    touch "${CC_HISTORY_FILE}"
    touch "${CC_CURRENT_FILE}"
}

# Initialize when sourced
init_cc_manager

# ==============================================================================
# Command implementations
# ==============================================================================

cmd_switch() {
    local provider="$1"

    if [[ -z "$provider" ]]; then
        echo "Usage: cc-manager switch <provider>" >&2
        echo "" >&2
        echo "Available providers:" >&2
        list_providers_simple
        return 1
    fi

    switch_provider "$provider"
}

cmd_status() {
    show_status
}

cmd_list() {
    list_providers
}

cmd_menu() {
    interactive_menu
}

cmd_back() {
    back_to_previous
}

cmd_test() {
    test_connection
}

cmd_run() {
    local provider="$1"
    shift || true

    if [[ -z "$provider" ]]; then
        echo "Usage: cc-manager run <provider> [claude-args...]" >&2
        return 1
    fi

    run_with_provider "$provider" "$@"
}

cmd_config() {
    local action="${1:-show}"

    case "$action" in
        show|s)
            show_config_paths
            ;;
        edit|e)
            edit_config
            ;;
        reset|r)
            reset_config
            ;;
        validate|v)
            validate_config
            ;;
        *)
            show_config_paths
            ;;
    esac
}

cmd_add() {
    local name="$1"

    if [[ -z "$name" ]]; then
        echo "Usage: cc-manager add <provider-name>" >&2
        return 1
    fi

    add_provider_interactive "$name"
}

cmd_remove() {
    local name="$1"

    if [[ -z "$name" ]]; then
        echo "Usage: cc-manager remove <provider-name>" >&2
        return 1
    fi

    remove_provider "$name"
}

cmd_edit() {
    local name="${1:-}"

    if [[ -z "$name" ]]; then
        # Edit config file
        edit_config
    else
        # Edit specific provider
        edit_provider "$name"
    fi
}

cmd_history() {
    local limit="${1:-10}"
    show_history "$limit"
}

cmd_clear_history() {
    clear_history
}

cmd_export() {
    local output="${1:-cc-manager-backup.yaml}"
    export_config "$output"
}

cmd_import() {
    local input="$1"

    if [[ -z "$input" ]]; then
        echo "Usage: cc-manager import <config-file>" >&2
        return 1
    fi

    import_config "$input"
}

cmd_version() {
    echo "cc-manager version ${CC_MANAGER_VERSION}"
}

cmd_help() {
    cat << 'EOF'
cc-manager - Claude Code Provider Manager

USAGE:
    cc-manager <command> [arguments]

COMMANDS:
    switch <provider>        Switch to a specific provider
    status                   Show current configuration status
    list                     List all available providers
    menu                     Interactive provider selection menu
    back                     Switch back to previous provider
    test                     Test connection to current provider
    run <provider> [args]    Run Claude Code with specific provider

    add <name>               Add a new provider interactively
    remove <name>            Remove a provider
    edit [name]              Edit provider or config file

    config [action]          Manage configuration
        show                 Show config file paths (default)
        edit                 Edit config file
        reset                Reset to default configuration
        validate             Validate configuration

    history [limit]          Show switch history (default: 10)
    clear-history            Clear switch history

    export [file]            Export configuration
    import <file>            Import configuration

    version                  Show version information
    help                     Show this help message

ALIASES:
    sw  → switch
    st  → status
    ls  → list
    m   → menu
    b   → back
    t   → test
    r   → run
    a   → add
    rm  → remove
    e   → edit
    cfg → config
    v   → version
    h   → help

EXAMPLES:
    cc-manager list                    List all providers
    cc-manager switch deepseek         Switch to DeepSeek
    cc-manager status                  Check current status
    cc-manager test                    Test connection
    cc-manager back                    Go back to previous provider
    cc-manager add my-provider         Add a new provider
    cc-manager run glm                 Run Claude with GLM

ENVIRONMENT VARIABLES:
    CC_MANAGER_HOME          Override installation directory
    CC_CONFIG_DIR            Override config directory
    EDITOR                   Preferred text editor

FILES:
    Config:   ~/.config/cc-manager/config.yaml
    History:  ~/.cache/cc-manager/history
    Current:  ~/.cache/cc-manager/current

For more information, visit:
    https://github.com/yourusername/cc-manager

EOF
}
