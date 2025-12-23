#!/usr/bin/env bash
# ==============================================================================
# History Management Module
# ==============================================================================

# Go back to previous provider
back_to_previous() {
    if [[ ! -s "$CC_HISTORY_FILE" ]]; then
        log_error "No history available"
        return 1
    fi

    # Get last provider from history
    local prev_provider
    prev_provider=$(tail -1 "$CC_HISTORY_FILE")

    # Remove last line from history
    if [[ "$(uname)" == "Darwin" ]]; then
        # macOS
        sed -i '' -e '$ d' "$CC_HISTORY_FILE" 2>/dev/null
    else
        # Linux
        sed -i '$ d' "$CC_HISTORY_FILE" 2>/dev/null
    fi

    # Switch to previous provider
    switch_provider "$prev_provider"
}

# Show history
show_history() {
    local limit="${1:-10}"

    if [[ ! -s "$CC_HISTORY_FILE" ]]; then
        echo "No history available"
        return 0
    fi

    echo "Provider Switch History (last $limit):"
    echo ""

    local count=0
    while IFS= read -r provider; do
        ((count++))
        echo "  $count. $provider"
    done < <(tail -"$limit" "$CC_HISTORY_FILE")
}

# Clear history
clear_history() {
    echo -n "Clear all switch history? [y/N] "
    read -r answer

    if [[ "$answer" =~ ^[Yy]$ ]]; then
        > "$CC_HISTORY_FILE"
        log_success "History cleared"
    else
        log_info "Operation cancelled"
    fi
}
