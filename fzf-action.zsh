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
            --layout=reverse)

    local exit_code=$?
    if [[ $exit_code -ne 0 ]]; then
        # If interrupted (Ctrl+C), send break signal to ZLE
        if [[ $exit_code -eq 130 ]]; then
            zle && zle send-break
        fi
        return $exit_code
    fi

    # Parse fzf output (first line is key pressed, rest is selection)
    local -a lines=("${(@f)selected}")
    local key="${lines[1]}"
    local candidate="${lines[2]}"

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
                --layout=reverse \
                --height=~100%)

        local action_exit_code=$?
        if [[ $action_exit_code -ne 0 ]]; then
            # If interrupted (Ctrl+C), send break signal to ZLE
            if [[ $action_exit_code -eq 130 ]]; then
                zle && zle send-break
            fi
            return $action_exit_code
        fi

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

# Initialize clipboard copy command if not set
if [[ -z "$FZF_ACTION_CLIP_COPY_CMD" ]]; then
    case "$(uname -s)" in
        Darwin)
            # macOS
            FZF_ACTION_CLIP_COPY_CMD="pbcopy"
            ;;
        Linux)
            # Linux - check for available clipboard commands
            if command -v xclip >/dev/null 2>&1; then
                FZF_ACTION_CLIP_COPY_CMD="xclip -selection clipboard"
            elif command -v xsel >/dev/null 2>&1; then
                FZF_ACTION_CLIP_COPY_CMD="xsel --clipboard --input"
            elif command -v wl-copy >/dev/null 2>&1; then
                # Wayland
                FZF_ACTION_CLIP_COPY_CMD="wl-copy"
            elif [[ -n "$WSL_DISTRO_NAME" ]] || grep -qi microsoft /proc/version 2>/dev/null; then
                # WSL
                FZF_ACTION_CLIP_COPY_CMD="clip.exe"
            fi
            ;;
        CYGWIN*|MINGW*|MSYS*)
            # Windows (Git Bash, MSYS2, Cygwin)
            FZF_ACTION_CLIP_COPY_CMD="clip.exe"
            ;;
    esac
fi
