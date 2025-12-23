#!/usr/bin/env bash
# ==============================================================================
# cc-manager Shell Integration
# ==============================================================================
# This file provides proper environment variable handling for cc-manager
# Source this file in your .bashrc or .zshrc

# Find the real cc-manager binary
_find_cc_manager_bin() {
    local bin_path

    # Try common installation locations
    for path in \
        "/usr/local/bin/cc-manager-bin" \
        "$HOME/.local/bin/cc-manager-bin" \
        "$(dirname "${BASH_SOURCE[0]}")/../bin/cc-manager-bin" \
        "$(which cc-manager-bin 2>/dev/null)"; do

        if [[ -f "$path" ]] && [[ -x "$path" ]]; then
            echo "$path"
            return 0
        fi
    done

    # Fallback to cc-manager if cc-manager-bin not found
    which cc-manager 2>/dev/null
}

CC_MANAGER_BIN="$(_find_cc_manager_bin)"

# Main cc-manager function that handles environment variables
cc-manager() {
    if [[ -z "$CC_MANAGER_BIN" ]]; then
        echo "Error: cc-manager binary not found" >&2
        return 1
    fi

    local command="$1"

    # Commands that need environment variable injection
    case "$command" in
        switch|sw)
            local provider="$2"
            if [[ -z "$provider" ]]; then
                "$CC_MANAGER_BIN" "$@"
                return $?
            fi

            # Get export commands and eval them
            local output
            output=$(CC_EXPORT_MODE=1 "$CC_MANAGER_BIN" "$@" 2>&1)
            local exit_code=$?

            # Show the output (except export commands)
            echo "$output" | grep -v "^export\|^unset\|^# cc-manager export"

            # Extract and eval export commands
            local export_commands
            export_commands=$(echo "$output" | grep -A 100 "# cc-manager export commands" | grep "^export\|^unset")

            if [[ -n "$export_commands" ]] && [[ $exit_code -eq 0 ]]; then
                eval "$export_commands"
            fi

            return $exit_code
            ;;

        back|b)
            # Handle back command
            local history_file="${HOME}/.cache/cc-manager/history"
            if [[ ! -s "$history_file" ]]; then
                echo "No history available"
                return 1
            fi

            local prev_provider
            prev_provider=$(tail -1 "$history_file")

            if [[ -z "$prev_provider" ]]; then
                echo "No previous provider in history"
                return 1
            fi

            # Remove from history (will be re-added by switch)
            if [[ "$(uname)" == "Darwin" ]]; then
                sed -i '' -e '$ d' "$history_file" 2>/dev/null
            else
                sed -i '$ d' "$history_file" 2>/dev/null
            fi

            # Switch to previous provider
            cc-manager switch "$prev_provider"
            return $?
            ;;

        *)
            # For all other commands, just pass through
            "$CC_MANAGER_BIN" "$@"
            return $?
            ;;
    esac
}

# Legacy aliases (for backward compatibility)
alias ccm='cc-manager'
alias ccm-sw='cc-manager switch'
alias ccm-st='cc-manager status'
alias ccm-ls='cc-manager list'
alias ccm-t='cc-manager test'
alias ccm-b='cc-manager back'

# Bash completion
if [[ -n "$BASH_VERSION" ]]; then
    _cc_manager_completion() {
        local cur prev commands
        COMPREPLY=()
        cur="${COMP_WORDS[COMP_CWORD]}"
        prev="${COMP_WORDS[COMP_CWORD-1]}"

        commands="switch status list menu back test run config add remove edit history clear-history export import version help"

        case "$prev" in
            switch|sw|run|r|remove|rm|edit|e)
                # Complete with provider names
                local providers
                if [[ -f "${HOME}/.config/cc-manager/config.yaml" ]]; then
                    providers=$(grep -E "^  [a-zA-Z0-9_-]+:" "${HOME}/.config/cc-manager/config.yaml" | sed 's/://g' | awk '{print $1}')
                fi
                COMPREPLY=( $(compgen -W "$providers" -- "$cur") )
                return 0
                ;;
            config|cfg)
                COMPREPLY=( $(compgen -W "show edit reset validate" -- "$cur") )
                return 0
                ;;
            cc-manager|ccm)
                COMPREPLY=( $(compgen -W "$commands" -- "$cur") )
                return 0
                ;;
        esac

        if [[ ${COMP_CWORD} -eq 1 ]]; then
            COMPREPLY=( $(compgen -W "$commands" -- "$cur") )
        fi

        return 0
    }

    complete -F _cc_manager_completion cc-manager ccm
fi

# Zsh completion
if [[ -n "$ZSH_VERSION" ]]; then
    _cc_manager_completion() {
        local -a commands providers config_actions

        commands=(
            'switch:Switch to a provider'
            'status:Show current status'
            'list:List all providers'
            'menu:Interactive menu'
            'back:Go back to previous provider'
            'test:Test connection'
            'run:Run with specific provider'
            'config:Manage configuration'
            'add:Add a provider'
            'remove:Remove a provider'
            'edit:Edit provider or config'
            'history:Show history'
            'clear-history:Clear history'
            'export:Export configuration'
            'import:Import configuration'
            'version:Show version'
            'help:Show help'
        )

        config_actions=(
            'show:Show config paths'
            'edit:Edit config file'
            'reset:Reset configuration'
            'validate:Validate configuration'
        )

        if (( CURRENT == 2 )); then
            _describe 'command' commands
        elif (( CURRENT == 3 )); then
            case "$words[2]" in
                switch|sw|run|r|remove|rm|edit|e)
                    if [[ -f "${HOME}/.config/cc-manager/config.yaml" ]]; then
                        providers=(${(f)"$(grep -E "^  [a-zA-Z0-9_-]+:" "${HOME}/.config/cc-manager/config.yaml" | sed 's/://g' | awk '{print $1}')"})
                        _describe 'provider' providers
                    fi
                    ;;
                config|cfg)
                    _describe 'action' config_actions
                    ;;
            esac
        fi
    }

    compdef _cc_manager_completion cc-manager ccm
fi

# Convenience function: switch and show status
ccs() {
    if [[ -z "$1" ]]; then
        cc-manager list
    else
        cc-manager switch "$1" && cc-manager status
    fi
}
