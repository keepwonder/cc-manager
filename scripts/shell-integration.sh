#!/usr/bin/env bash
# ==============================================================================
# cc-manager Shell Integration
# ==============================================================================
# This file provides aliases and completions for cc-manager
# Source this file in your .bashrc or .zshrc

# Aliases
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

# Function to quickly switch and show status
ccs() {
    if [[ -z "$1" ]]; then
        cc-manager list
    else
        cc-manager switch "$1" && cc-manager status
    fi
}

# Function to switch with menu
ccmenu() {
    cc-manager menu
}
