#!/usr/bin/env bash
# ==============================================================================
# Configuration Management Module
# ==============================================================================

# Configuration paths
CC_CONFIG_DIR="${CC_CONFIG_DIR:-${HOME}/.config/cc-manager}"
CC_CACHE_DIR="${CC_CACHE_DIR:-${HOME}/.cache/cc-manager}"
CC_CONFIG_FILE="${CC_CONFIG_DIR}/config.yaml"
CC_HISTORY_FILE="${CC_CACHE_DIR}/history"
CC_CURRENT_FILE="${CC_CACHE_DIR}/current"

# Associative arrays for providers
declare -A PROVIDERS_BASE_URL
declare -A PROVIDERS_AUTH_TYPE
declare -A PROVIDERS_API_KEY
declare -A PROVIDERS_AUTH_TOKEN
declare -A PROVIDERS_MODEL
declare -A PROVIDERS_SMALL_MODEL
declare -A PROVIDERS_ENABLED

DEFAULT_PROVIDER=""

# Load configuration from YAML file
load_config() {
    if [[ ! -f "$CC_CONFIG_FILE" ]]; then
        log_error "Configuration file not found: $CC_CONFIG_FILE"
        return 1
    fi

    local current_provider=""
    local in_providers=false

    while IFS= read -r line; do
        # Skip comments and empty lines
        [[ "$line" =~ ^[[:space:]]*# ]] && continue
        [[ -z "$line" ]] && continue

        # Remove leading/trailing whitespace
        line="${line#"${line%%[![:space:]]*}"}"
        line="${line%"${line##*[![:space:]]}"}"

        # Parse default provider
        if [[ "$line" =~ ^default_provider:[[:space:]]*(.+)$ ]]; then
            DEFAULT_PROVIDER="${BASH_REMATCH[1]}"
            DEFAULT_PROVIDER="${DEFAULT_PROVIDER//\"/}"
            continue
        fi

        # Enter providers section
        if [[ "$line" == "providers:" ]]; then
            in_providers=true
            continue
        fi

        if [[ "$in_providers" == true ]]; then
            # New provider entry
            if [[ "$line" =~ ^([a-zA-Z0-9_-]+):$ ]]; then
                current_provider="${BASH_REMATCH[1]}"
                PROVIDERS_ENABLED[$current_provider]="true"
                continue
            fi

            # Provider properties
            if [[ -n "$current_provider" ]]; then
                if [[ "$line" =~ ^base_url:[[:space:]]*(.+)$ ]]; then
                    PROVIDERS_BASE_URL[$current_provider]="${BASH_REMATCH[1]//\"/}"
                elif [[ "$line" =~ ^auth_type:[[:space:]]*(.+)$ ]]; then
                    PROVIDERS_AUTH_TYPE[$current_provider]="${BASH_REMATCH[1]//\"/}"
                elif [[ "$line" =~ ^api_key:[[:space:]]*(.+)$ ]]; then
                    PROVIDERS_API_KEY[$current_provider]="${BASH_REMATCH[1]//\"/}"
                elif [[ "$line" =~ ^auth_token:[[:space:]]*(.+)$ ]]; then
                    PROVIDERS_AUTH_TOKEN[$current_provider]="${BASH_REMATCH[1]//\"/}"
                elif [[ "$line" =~ ^model:[[:space:]]*(.+)$ ]]; then
                    PROVIDERS_MODEL[$current_provider]="${BASH_REMATCH[1]//\"/}"
                elif [[ "$line" =~ ^small_fast_model:[[:space:]]*(.+)$ ]]; then
                    PROVIDERS_SMALL_MODEL[$current_provider]="${BASH_REMATCH[1]//\"/}"
                elif [[ "$line" =~ ^enabled:[[:space:]]*(.+)$ ]]; then
                    PROVIDERS_ENABLED[$current_provider]="${BASH_REMATCH[1]//\"/}"
                fi
            fi
        fi
    done < "$CC_CONFIG_FILE"
}

# Create default configuration
create_default_config() {
    mkdir -p "$CC_CONFIG_DIR"

    cat > "$CC_CONFIG_FILE" << 'EOF'
# cc-manager configuration file
# Format: YAML

version: "1.0"
default_provider: "aicodemirror"

providers:
  aicodemirror:
    base_url: "https://api.aicodemirror.com/api/claudecode"
    auth_type: "api_key"
    api_key: "your-api-key-here"
    enabled: true

  deepseek:
    base_url: "https://api.deepseek.com/anthropic"
    auth_type: "auth_token"
    auth_token: "your-auth-token-here"
    model: "deepseek-chat"
    small_fast_model: "deepseek-chat"
    enabled: true

  glm:
    base_url: "https://open.bigmodel.cn/api/anthropic"
    auth_type: "auth_token"
    auth_token: "your-auth-token-here"
    model: "GLM-4.7"
    enabled: true

# Add more providers as needed
# Template:
#  provider_name:
#    base_url: "https://api.example.com"
#    auth_type: "api_key"  # or "auth_token"
#    api_key: "your-key"   # if auth_type is api_key
#    # auth_token: "your-token"  # if auth_type is auth_token
#    # model: "model-name"  # optional
#    # small_fast_model: "model-name"  # optional
#    enabled: true
EOF

    chmod 600 "$CC_CONFIG_FILE"
    log_success "Created default configuration: $CC_CONFIG_FILE"
    log_info "Please edit the configuration file to add your API keys"
}

# Show configuration file paths
show_config_paths() {
    echo "Configuration Files:"
    echo "  Config:   $CC_CONFIG_FILE"
    echo "  History:  $CC_HISTORY_FILE"
    echo "  Current:  $CC_CURRENT_FILE"
    echo ""
    echo "To edit: cc-manager config edit"
    echo "         or"
    echo "         \$EDITOR $CC_CONFIG_FILE"
}

# Edit configuration file
edit_config() {
    local editor="${EDITOR:-vi}"

    if [[ ! -f "$CC_CONFIG_FILE" ]]; then
        log_error "Configuration file not found"
        return 1
    fi

    "$editor" "$CC_CONFIG_FILE"

    # Reload configuration
    load_config
    log_success "Configuration reloaded"
}

# Reset configuration to defaults
reset_config() {
    echo -n "This will reset your configuration to defaults. Continue? [y/N] "
    read -r answer

    if [[ "$answer" =~ ^[Yy]$ ]]; then
        # Backup existing config
        if [[ -f "$CC_CONFIG_FILE" ]]; then
            local backup="${CC_CONFIG_FILE}.backup.$(date +%Y%m%d_%H%M%S)"
            cp "$CC_CONFIG_FILE" "$backup"
            log_info "Backup saved to: $backup"
        fi

        create_default_config
        load_config
        log_success "Configuration reset to defaults"
    else
        log_info "Operation cancelled"
    fi
}

# Validate configuration
validate_config() {
    local errors=0

    echo "Validating configuration..."
    echo ""

    # Check if file exists
    if [[ ! -f "$CC_CONFIG_FILE" ]]; then
        log_error "Configuration file not found"
        return 1
    fi

    # Check if we have any providers
    if [[ ${#PROVIDERS_BASE_URL[@]} -eq 0 ]]; then
        log_error "No providers configured"
        ((errors++))
    else
        log_success "Found ${#PROVIDERS_BASE_URL[@]} provider(s)"
    fi

    # Validate each provider
    for provider in "${!PROVIDERS_BASE_URL[@]}"; do
        echo ""
        echo "Validating provider: $provider"

        # Check base URL
        if [[ -z "${PROVIDERS_BASE_URL[$provider]}" ]]; then
            log_error "  Missing base_url"
            ((errors++))
        else
            log_success "  base_url: ${PROVIDERS_BASE_URL[$provider]}"
        fi

        # Check authentication
        local auth_type="${PROVIDERS_AUTH_TYPE[$provider]}"
        if [[ "$auth_type" == "api_key" ]]; then
            if [[ -z "${PROVIDERS_API_KEY[$provider]}" ]]; then
                log_error "  Missing api_key"
                ((errors++))
            else
                log_success "  api_key: ***${PROVIDERS_API_KEY[$provider]: -6}"
            fi
        elif [[ "$auth_type" == "auth_token" ]]; then
            if [[ -z "${PROVIDERS_AUTH_TOKEN[$provider]}" ]]; then
                log_error "  Missing auth_token"
                ((errors++))
            else
                log_success "  auth_token: ***${PROVIDERS_AUTH_TOKEN[$provider]: -6}"
            fi
        else
            log_error "  Invalid or missing auth_type: $auth_type"
            ((errors++))
        fi
    done

    echo ""
    if [[ $errors -eq 0 ]]; then
        log_success "Configuration is valid!"
        return 0
    else
        log_error "Configuration has $errors error(s)"
        return 1
    fi
}

# Export configuration
export_config() {
    local output="$1"

    if [[ -f "$output" ]]; then
        echo -n "File exists. Overwrite? [y/N] "
        read -r answer
        [[ ! "$answer" =~ ^[Yy]$ ]] && return 1
    fi

    cp "$CC_CONFIG_FILE" "$output"
    log_success "Configuration exported to: $output"
}

# Import configuration
import_config() {
    local input="$1"

    if [[ ! -f "$input" ]]; then
        log_error "Input file not found: $input"
        return 1
    fi

    # Backup current config
    if [[ -f "$CC_CONFIG_FILE" ]]; then
        local backup="${CC_CONFIG_FILE}.backup.$(date +%Y%m%d_%H%M%S)"
        cp "$CC_CONFIG_FILE" "$backup"
        log_info "Current config backed up to: $backup"
    fi

    cp "$input" "$CC_CONFIG_FILE"
    chmod 600 "$CC_CONFIG_FILE"

    # Reload configuration
    load_config
    log_success "Configuration imported and reloaded"
}
