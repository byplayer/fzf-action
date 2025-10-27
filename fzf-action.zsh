#!/usr/bin/env zsh
# fzf-action.zsh - ZSH plugin for fzf-based action selection menus

# Core function to handle fzf action workflow
# Usage: fzf-action <candidates> <actions> <action_descriptions>
function fzf-action-core() {
    local -a candidates=("${(@f)1}")
    local -a actions=("${(@f)2}")
    local -a action_descriptions=("${(@f)3}")
    local default_action="${4:-1}"

    # Check if fzf is available
    if ! command -v fzf >/dev/null 2>&1; then
        echo "Error: fzf is not installed" >&2
        return 1
    fi

    # Check if we have candidates
    if [[ ${#candidates[@]} -eq 0 ]]; then
        echo "No candidates available" >&2
        return 1
    fi

    # Select candidate with fzf (expect TAB for action selection or ENTER for default)
    local selected
    selected=$(printf "%s\n" "${candidates[@]}" | \
        fzf --ansi \
            --expect=tab \
            --header="ENTER: default action | TAB: select action" \
            --preview-window=right:50% \
            --border \
            --no-clear \
            --layout=reverse)

    local exit_code=$?
    if [[ $exit_code -ne 0 ]]; then
        return $exit_code
    fi

    # Parse fzf output (first line is key pressed, rest is selection)
    local key=$(echo "$selected" | head -1)
    local candidate=$(echo "$selected" | tail -n +2)

    if [[ -z "$candidate" ]]; then
        return 0
    fi

    local action_index=$default_action

    # If TAB was pressed, show action menu
    if [[ "$key" == "tab" ]]; then
        local selected_action
        selected_action=$(printf "%s\n" "${action_descriptions[@]}" | \
            fzf --header="Select action for: $candidate" \
                --border \
                --no-clear \
                --layout=reverse \
                --height=~100%)

        if [[ -z "$selected_action" ]]; then
            return 0
        fi

        # Find the index of the selected action
        for i in {1..${#action_descriptions[@]}}; do
            if [[ "${action_descriptions[$i]}" == "$selected_action" ]]; then
                action_index=$i
                break
            fi
        done
    fi

    # Clear screen before executing action
    zle && zle clear-screen

    # Execute the selected action
    local action_func="${actions[$action_index]}"
    if [[ -n "$action_func" ]]; then
        "$action_func" "$candidate"
    fi
}

# Helper function to strip color codes and formatting
function fzf-action-strip-ansi() {
    echo "$1" | sed 's/\x1b\[[0-9;]*m//g'
}
