#!/usr/bin/env zsh
# command-history.zsh - Command history management with fzf action

# Get command history with formatting
function fzf-action-command-history-get-candidates() {
    local selected
    setopt localoptions noglobsubst noposixbuiltins pipefail 2> /dev/null

    # Get history with line numbers (similar to fc -rl 1)
    fc -rl 1
}

# Extract clean command from formatted output
function fzf-action-command-history-extract-command() {
    local formatted="$1"
    # Strip ANSI codes first
    local clean=$(fzf-action-strip-ansi "$formatted")
    # Remove leading number and whitespace using ZSH built-ins
    # Format is typically: "  123  command here"
    clean="${clean#${clean%%[! ]*}}"  # Remove leading whitespace
    clean="${clean#*[0-9] }"           # Remove number and following space
    clean="${clean#${clean%%[! ]*}}"  # Remove any remaining leading whitespace
    echo "$clean"
}

# Action: Execute command (accept-line) - Default
function fzf-action-command-history-execute() {
    if [[ -z "$1" ]]; then
        echo "Error: No command specified" >&2
        return 1
    fi
    local command=$(fzf-action-command-history-extract-command "$1")
    if [[ -z "$command" ]]; then
        echo "Error: Could not extract command" >&2
        return 1
    fi
    BUFFER="$command"
    zle accept-line
}

# Action: Append to edit buffer
function fzf-action-command-history-append() {
    if [[ -z "$1" ]]; then
        echo "Error: No command specified" >&2
        return 1
    fi
    local command=$(fzf-action-command-history-extract-command "$1")
    if [[ -z "$command" ]]; then
        echo "Error: Could not extract command" >&2
        return 1
    fi
    LBUFFER="${LBUFFER}${command}"
    zle reset-prompt
}

# Main function: Command history action
function fzf-action-command-history() {
    local candidates=$(fzf-action-command-history-get-candidates)

    if [[ -z "$candidates" ]]; then
        echo "No command history available" >&2
        return 1
    fi

    local -a actions=(
        fzf-action-command-history-execute
        fzf-action-command-history-append
    )

    local -a action_descriptions=(
        "execute command (Default)"
        "append to edit buffer"
    )

    fzf-action-core "$candidates" "$(printf "%s\n" "${actions[@]}")" "$(printf "%s\n" "${action_descriptions[@]}")" 1
}

# Create ZLE widget for key binding
zle -N fzf-action-command-history
