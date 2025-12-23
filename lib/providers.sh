#!/usr/bin/env bash
# ==============================================================================
# Provider Management Module
# ==============================================================================

# Switch to a provider
switch_provider() {
    local provider="$1"

    # Check if provider exists
    if [[ -z "${PROVIDERS_BASE_URL[$provider]}" ]]; then
        log_error "Unknown provider: $provider"
        echo ""
        echo "Available providers:"
        list_providers_simple
        return 1
    fi

    # Check if provider is enabled
    if [[ "${PROVIDERS_ENABLED[$provider]}" == "false" ]]; then
        log_warning "Provider '$provider' is disabled"
        echo -n "Enable and switch to it? [y/N] "
        read -r answer
        [[ ! "$answer" =~ ^[Yy]$ ]] && return 1
    fi

    # Save to history
    local current_provider
    current_provider=$(cat "$CC_CURRENT_FILE" 2>/dev/null)
    if [[ -n "$current_provider" && "$current_provider" != "$provider" ]]; then
        echo "$current_provider" >> "$CC_HISTORY_FILE"
    fi

    # Set environment variables
    _set_provider_env "$provider"

    # Save current provider
    echo "$provider" > "$CC_CURRENT_FILE"

    # Display success message
    log_success "Switched to $provider"
    echo "  BASE_URL: ${PROVIDERS_BASE_URL[$provider]}"
    [[ -n "${PROVIDERS_MODEL[$provider]}" ]] && echo "  MODEL: ${PROVIDERS_MODEL[$provider]}"

    # Output export commands for eval (when called with --export)
    if [[ "${CC_EXPORT_MODE:-}" == "1" ]]; then
        _output_export_commands "$provider"
    fi
}

# Output export commands for shell eval
_output_export_commands() {
    local provider="$1"

    echo "# cc-manager export commands"
    echo "unset ANTHROPIC_API_KEY"
    echo "unset ANTHROPIC_AUTH_TOKEN"
    echo "unset ANTHROPIC_BASE_URL"
    echo "unset ANTHROPIC_MODEL"
    echo "unset ANTHROPIC_SMALL_FAST_MODEL"

    echo "export ANTHROPIC_BASE_URL=\"${PROVIDERS_BASE_URL[$provider]}\""

    local auth_type="${PROVIDERS_AUTH_TYPE[$provider]}"
    if [[ "$auth_type" == "api_key" ]]; then
        echo "export ANTHROPIC_API_KEY=\"${PROVIDERS_API_KEY[$provider]}\""
    elif [[ "$auth_type" == "auth_token" ]]; then
        echo "export ANTHROPIC_AUTH_TOKEN=\"${PROVIDERS_AUTH_TOKEN[$provider]}\""
    fi

    if [[ -n "${PROVIDERS_MODEL[$provider]}" ]]; then
        echo "export ANTHROPIC_MODEL=\"${PROVIDERS_MODEL[$provider]}\""
    fi

    if [[ -n "${PROVIDERS_SMALL_MODEL[$provider]}" ]]; then
        echo "export ANTHROPIC_SMALL_FAST_MODEL=\"${PROVIDERS_SMALL_MODEL[$provider]}\""
    fi
}

# Set environment variables for a provider
_set_provider_env() {
    local provider="$1"

    # Clear existing variables
    unset ANTHROPIC_API_KEY
    unset ANTHROPIC_AUTH_TOKEN
    unset ANTHROPIC_BASE_URL
    unset ANTHROPIC_MODEL
    unset ANTHROPIC_SMALL_FAST_MODEL

    # Set base URL
    export ANTHROPIC_BASE_URL="${PROVIDERS_BASE_URL[$provider]}"

    # Set authentication
    local auth_type="${PROVIDERS_AUTH_TYPE[$provider]}"
    if [[ "$auth_type" == "api_key" ]]; then
        export ANTHROPIC_API_KEY="${PROVIDERS_API_KEY[$provider]}"
    elif [[ "$auth_type" == "auth_token" ]]; then
        export ANTHROPIC_AUTH_TOKEN="${PROVIDERS_AUTH_TOKEN[$provider]}"
    fi

    # Set optional model
    if [[ -n "${PROVIDERS_MODEL[$provider]}" ]]; then
        export ANTHROPIC_MODEL="${PROVIDERS_MODEL[$provider]}"
    fi

    if [[ -n "${PROVIDERS_SMALL_MODEL[$provider]}" ]]; then
        export ANTHROPIC_SMALL_FAST_MODEL="${PROVIDERS_SMALL_MODEL[$provider]}"
    fi
}

# List all providers
list_providers() {
    echo "Available Claude Code Providers:"
    echo ""

    local current_provider
    current_provider=$(cat "$CC_CURRENT_FILE" 2>/dev/null)

    for provider in $(echo "${!PROVIDERS_BASE_URL[@]}" | tr ' ' '\n' | sort); do
        local marker="  "
        local status=""

        # Mark current provider
        if [[ "$provider" == "$current_provider" ]]; then
            marker="→ "
        fi

        # Show enabled/disabled status
        if [[ "${PROVIDERS_ENABLED[$provider]}" == "false" ]]; then
            status=" (disabled)"
        fi

        printf "%s %-20s %s%s\n" \
            "$marker" \
            "$provider" \
            "${PROVIDERS_BASE_URL[$provider]}" \
            "$status"
    done
}

# List providers in simple format
list_providers_simple() {
    for provider in $(echo "${!PROVIDERS_BASE_URL[@]}" | tr ' ' '\n' | sort); do
        if [[ "${PROVIDERS_ENABLED[$provider]}" != "false" ]]; then
            echo "  - $provider"
        fi
    done
}

# Show current status
show_status() {
    local current_provider
    current_provider=$(cat "$CC_CURRENT_FILE" 2>/dev/null)

    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "  Claude Code Configuration Status"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

    if [[ -n "$current_provider" ]]; then
        echo "Provider:    $current_provider"
    else
        echo "Provider:    Not set"
    fi

    echo ""
    echo "Environment Variables:"
    echo "  BASE_URL:   ${ANTHROPIC_BASE_URL:-Not set}"

    if [[ -n "$ANTHROPIC_API_KEY" ]]; then
        echo "  API_KEY:    ***${ANTHROPIC_API_KEY: -6}"
    elif [[ -n "$ANTHROPIC_AUTH_TOKEN" ]]; then
        echo "  AUTH_TOKEN: ***${ANTHROPIC_AUTH_TOKEN: -6}"
    else
        echo "  AUTH:       Not set"
    fi

    if [[ -n "$ANTHROPIC_MODEL" ]]; then
        echo "  MODEL:      $ANTHROPIC_MODEL"
    fi

    if [[ -n "$ANTHROPIC_SMALL_FAST_MODEL" ]]; then
        echo "  SMALL_MODEL: $ANTHROPIC_SMALL_FAST_MODEL"
    fi

    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
}

# Interactive menu
interactive_menu() {
    echo "Select a Claude Code provider:"
    echo ""

    local providers=($(echo "${!PROVIDERS_BASE_URL[@]}" | tr ' ' '\n' | sort))
    local i=1

    for provider in "${providers[@]}"; do
        if [[ "${PROVIDERS_ENABLED[$provider]}" != "false" ]]; then
            echo "  $i) $provider"
            ((i++))
        fi
    done

    echo "  0) Cancel"
    echo ""
    echo -n "Enter selection: "

    read -r selection

    if [[ "$selection" == "0" ]]; then
        log_info "Cancelled"
        return 0
    fi

    if [[ "$selection" =~ ^[0-9]+$ ]] && [[ $selection -ge 1 ]] && [[ $selection -lt $i ]]; then
        local selected_provider="${providers[$((selection-1))]}"
        switch_provider "$selected_provider"
    else
        log_error "Invalid selection"
        return 1
    fi
}

# Test connection
test_connection() {
    if [[ -z "$ANTHROPIC_BASE_URL" ]]; then
        log_error "No provider configured"
        echo "Run 'cc-manager switch <provider>' first"
        return 1
    fi

    echo "Testing connection to $ANTHROPIC_BASE_URL..."

    local status_code
    status_code=$(curl -s -o /dev/null -w "%{http_code}" \
        --connect-timeout 5 \
        --max-time 10 \
        "$ANTHROPIC_BASE_URL" 2>/dev/null)

    local curl_exit=$?

    if [[ $curl_exit -eq 0 ]]; then
        if [[ $status_code -ge 200 ]] && [[ $status_code -lt 500 ]]; then
            log_success "Connection successful (HTTP $status_code)"
            return 0
        else
            log_warning "Server responded with HTTP $status_code"
            return 1
        fi
    else
        log_error "Connection failed (curl exit code: $curl_exit)"
        return 1
    fi
}

# Run Claude Code with specific provider
run_with_provider() {
    local provider="$1"
    shift

    # Check if provider exists
    if [[ -z "${PROVIDERS_BASE_URL[$provider]}" ]]; then
        log_error "Unknown provider: $provider"
        return 1
    fi

    # Temporarily set environment
    _set_provider_env "$provider"

    log_info "Running Claude Code with $provider..."
    echo ""

    # Run claude command
    if command -v claude &> /dev/null; then
        claude "$@"
    else
        log_error "Claude Code CLI not found"
        echo "Please install Claude Code first"
        return 1
    fi
}

# Add provider interactively
add_provider_interactive() {
    local name="$1"

    # Check if provider already exists
    if [[ -n "${PROVIDERS_BASE_URL[$name]}" ]]; then
        log_error "Provider '$name' already exists"
        echo "Use 'cc-manager edit $name' to modify it"
        return 1
    fi

    echo "Adding new provider: $name"
    echo ""

    # Get base URL
    echo -n "Base URL: "
    read -r base_url
    [[ -z "$base_url" ]] && { log_error "Base URL is required"; return 1; }

    # Get auth type
    echo -n "Auth type (api_key/auth_token): "
    read -r auth_type
    [[ -z "$auth_type" ]] && auth_type="api_key"

    # Get credentials
    if [[ "$auth_type" == "api_key" ]]; then
        echo -n "API Key: "
        read -r api_key
        [[ -z "$api_key" ]] && { log_error "API Key is required"; return 1; }
    else
        echo -n "Auth Token: "
        read -r auth_token
        [[ -z "$auth_token" ]] && { log_error "Auth Token is required"; return 1; }
    fi

    # Optional: model
    echo -n "Model (optional): "
    read -r model

    # Add to config file
    {
        echo ""
        echo "  $name:"
        echo "    base_url: \"$base_url\""
        echo "    auth_type: \"$auth_type\""
        if [[ "$auth_type" == "api_key" ]]; then
            echo "    api_key: \"$api_key\""
        else
            echo "    auth_token: \"$auth_token\""
        fi
        [[ -n "$model" ]] && echo "    model: \"$model\""
        echo "    enabled: true"
    } >> "$CC_CONFIG_FILE"

    # Reload config
    load_config

    log_success "Provider '$name' added successfully"
}

# Remove provider
remove_provider() {
    local name="$1"

    # Check if provider exists
    if [[ -z "${PROVIDERS_BASE_URL[$name]}" ]]; then
        log_error "Provider '$name' not found"
        return 1
    fi

    echo -n "Remove provider '$name'? [y/N] "
    read -r answer

    if [[ "$answer" =~ ^[Yy]$ ]]; then
        # Remove from config file (simple approach: recreate without this provider)
        log_warning "Manual removal required"
        echo "Please edit the config file and remove the provider:"
        echo "  $CC_CONFIG_FILE"
        edit_config
    else
        log_info "Operation cancelled"
    fi
}

# Edit provider
edit_provider() {
    local name="$1"

    # Check if provider exists
    if [[ -z "${PROVIDERS_BASE_URL[$name]}" ]]; then
        log_error "Provider '$name' not found"
        return 1
    fi

    log_info "Editing provider '$name'"
    echo "Current configuration:"
    echo "  Base URL: ${PROVIDERS_BASE_URL[$name]}"
    echo "  Auth Type: ${PROVIDERS_AUTH_TYPE[$name]}"
    [[ -n "${PROVIDERS_MODEL[$name]}" ]] && echo "  Model: ${PROVIDERS_MODEL[$name]}"
    echo ""
    echo "Opening config file for editing..."

    edit_config
}
