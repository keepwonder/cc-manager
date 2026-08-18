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

    # Build candidates from enabled providers only, so the menu number
    # and the array index always refer to the same provider
    local candidates=()
    local provider
    for provider in $(echo "${!PROVIDERS_BASE_URL[@]}" | tr ' ' '\n' | sort); do
        if [[ "${PROVIDERS_ENABLED[$provider]}" != "false" ]]; then
            candidates+=("$provider")
        fi
    done

    if [[ ${#candidates[@]} -eq 0 ]]; then
        log_error "No enabled providers"
        return 1
    fi

    local i=1
    for provider in "${candidates[@]}"; do
        echo "  $i) $provider"
        ((i++))
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
        local selected_provider="${candidates[$((selection-1))]}"
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

# Insert a provider block at the end of the providers: section.
# Appending blindly to the file would break the YAML structure when
# the providers: section is not the last one in the config file.
_insert_provider_block() {
    local block="$1"

    if ! grep -q '^providers:[[:space:]]*$' "$CC_CONFIG_FILE"; then
        # No providers section yet: append one at the end
        {
            echo ""
            echo "providers:"
            echo "$block"
        } >> "$CC_CONFIG_FILE"
        return
    fi

    # Insert right before the first top-level line that ends the section.
    # The multi-line block is passed via the environment: awk -v cannot
    # carry literal newlines (fails with "newline in string" on BSD awk).
    local tmp="${CC_CONFIG_FILE}.tmp.$$"
    CCM_BLOCK="$block" awk '
        function flush() {
            for (i = 0; i < n; i++) print buf[i]
            n = 0
        }
        !in_prov {
            print
            if ($0 ~ /^providers:[[:space:]]*$/) in_prov = 1
            next
        }
        # First non-empty, non-indented line ends the providers section
        $0 != "" && $0 !~ /^[[:space:]]/ {
            flush()
            print ""
            print ENVIRON["CCM_BLOCK"]
            print ""
            print
            in_prov = 0
            next
        }
        { buf[n++] = $0 }
        END {
            if (in_prov) {
                flush()
                print ""
                print ENVIRON["CCM_BLOCK"]
            }
        }
    ' "$CC_CONFIG_FILE" > "$tmp" && mv "$tmp" "$CC_CONFIG_FILE" || {
        rm -f "$tmp"
        return 1
    }
}

# Add provider interactively
add_provider_interactive() {
    local name="$1"

    # Provider name must match what load_config can parse back
    if [[ ! "$name" =~ ^[a-zA-Z0-9_-]+$ ]]; then
        log_error "Invalid provider name: '$name'"
        echo "Use letters, digits, dashes and underscores only"
        return 1
    fi

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

    # Get credentials (silent read: never echo secrets to the terminal)
    local api_key="" auth_token=""
    if [[ "$auth_type" == "api_key" ]]; then
        echo -n "API Key: "
        read -rs api_key
        echo ""
        [[ -z "$api_key" ]] && { log_error "API Key is required"; return 1; }
    else
        echo -n "Auth Token: "
        read -rs auth_token
        echo ""
        [[ -z "$auth_token" ]] && { log_error "Auth Token is required"; return 1; }
    fi

    # Optional: model
    echo -n "Model (optional): "
    read -r model

    # Double quotes would break the YAML quoting used when writing
    local value
    for value in "$base_url" "$api_key" "$auth_token" "$model"; do
        if [[ "$value" == *\"* ]]; then
            log_error "Values containing double quotes are not supported"
            return 1
        fi
    done

    # Build the provider block
    local block="  $name:"
    block+=$'\n'"    base_url: \"$base_url\""
    block+=$'\n'"    auth_type: \"$auth_type\""
    if [[ "$auth_type" == "api_key" ]]; then
        block+=$'\n'"    api_key: \"$api_key\""
    else
        block+=$'\n'"    auth_token: \"$auth_token\""
    fi
    [[ -n "$model" ]] && block+=$'\n'"    model: \"$model\""
    block+=$'\n'"    enabled: true"

    _insert_provider_block "$block" || {
        log_error "Failed to write provider to config file"
        return 1
    }

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
        # Backup before modifying
        local backup="${CC_CONFIG_FILE}.backup.$(date +%Y%m%d_%H%M%S)"
        cp "$CC_CONFIG_FILE" "$backup"
        log_info "Backup saved to: $backup"

        # Drop the provider block: from its "  name:" entry line up to
        # (not including) the next entry line or top-level line
        local tmp="${CC_CONFIG_FILE}.tmp.$$"
        awk -v target="  ${name}:" '
            /^  [[:alnum:]_-]+:[[:space:]]*$/ { in_target = ($0 == target) }
            /^#/ || /^[^[:space:]]/ { in_target = 0 }
            in_target { next }
            { print }
        ' "$CC_CONFIG_FILE" > "$tmp" && mv "$tmp" "$CC_CONFIG_FILE" || {
            rm -f "$tmp"
            log_error "Failed to update config file"
            return 1
        }

        # Clear current provider if it was just removed
        if [[ "$(cat "$CC_CURRENT_FILE" 2>/dev/null)" == "$name" ]]; then
            : > "$CC_CURRENT_FILE"
            log_info "Cleared current provider (was '$name')"
        fi

        # Reload config
        load_config

        if [[ "$DEFAULT_PROVIDER" == "$name" ]]; then
            log_warning "Removed provider was the default_provider"
            echo "Update default_provider in: $CC_CONFIG_FILE"
        fi

        log_success "Provider '$name' removed"
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
