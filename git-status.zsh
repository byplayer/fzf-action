#!/usr/bin/env zsh
# git-status.zsh - Git status file management with fzf action

# Get git status files (only modified, staged, untracked files)
function fzf-action-git-status-get-candidates() {
    if ! git rev-parse --git-dir >/dev/null 2>&1; then
        echo "Error: Not a git repository" >&2
        return 1
    fi

    local -a files
    local file_list

    # Get file status from git status --porcelain
    file_list=$(git status --porcelain 2>/dev/null)

    if [[ -z "$file_list" ]]; then
        echo "No changes to display" >&2
        return 1
    fi

    while IFS= read -r line; do
        local git_status="${line:0:2}"
        local file_path="${line:3}"
        local status_label=""

        case "$git_status" in
            " M") status_label=$'\033[33m[modified]\033[0m' ;;
            "M ") status_label=$'\033[32m[staged]\033[0m' ;;
            "MM") status_label=$'\033[36m[staged|modified]\033[0m' ;;
            "A ") status_label=$'\033[32m[staged(add)]\033[0m' ;;
            "AM") status_label=$'\033[36m[add|modified]\033[0m' ;;
            " D") status_label=$'\033[31m[deleted]\033[0m' ;;
            "D ") status_label=$'\033[31m[staged(del)]\033[0m' ;;
            "??") status_label=$'\033[35m[untracked]\033[0m' ;;
            "UU") status_label=$'\033[31;1m[conflict]\033[0m' ;;
            "AA") status_label=$'\033[31;1m[conflict]\033[0m' ;;
            *) status_label=$'\033[90m['"$git_status"$']\033[0m' ;;
        esac

        files+=("${file_path} ${status_label}")
    done <<< "$file_list"

    printf "%s\n" "${files[@]}"
}

# Extract clean file path from formatted output
function fzf-action-git-status-extract-path() {
    local formatted="$1"
    # Strip ANSI codes first
    local clean=$(fzf-action-strip-ansi "$formatted")
    # Remove status label and trailing whitespace
    clean="${clean%% \[*\]}"
    echo "$clean"
}

# Sanitize file path for safe use in commands
function fzf-action-git-status-sanitize() {
    local file="$1"
    # Escape single quotes and wrap in single quotes
    printf '%s' "${file//\'/\'\\\'\'}"
}

# Action: Edit file (default)
function fzf-action-git-status-edit() {
    if [[ -z "$1" ]]; then
        echo "Error: No file specified" >&2
        return 1
    fi
    local git_base
    git_base=$(git rev-parse --show-cdup 2>/dev/null) || {
        echo "Error: Not in a git repository" >&2
        return 1
    }
    local file=$(fzf-action-git-status-extract-path "$1")
    if [[ -z "$file" ]]; then
        echo "Error: Could not extract file path" >&2
        return 1
    fi
    local safe_file=$(fzf-action-git-status-sanitize "$file")
    BUFFER="${FZF_ACTION_EDITOR:-${EDITOR:-vim}} '${git_base}${safe_file}'"
    zle accept-line
}

# Action: Append to edit buffer
function fzf-action-git-status-append() {
    if [[ -z "$1" ]]; then
        echo "Error: No file specified" >&2
        return 1
    fi
    local file=$(fzf-action-git-status-extract-path "$1")
    if [[ -z "$file" ]]; then
        echo "Error: Could not extract file path" >&2
        return 1
    fi
    LBUFFER="${LBUFFER}${file}"
    zle reset-prompt
}

# Action: Git add
function fzf-action-git-status-add() {
    if [[ -z "$1" ]]; then
        echo "Error: No file specified" >&2
        return 1
    fi
    local git_base
    git_base=$(git rev-parse --show-cdup 2>/dev/null) || {
        echo "Error: Not in a git repository" >&2
        return 1
    }
    local file=$(fzf-action-git-status-extract-path "$1")
    if [[ -z "$file" ]]; then
        echo "Error: Could not extract file path" >&2
        return 1
    fi
    local safe_file=$(fzf-action-git-status-sanitize "$file")
    BUFFER="git add '${git_base}${safe_file}'"
    zle accept-line
}

# Action: Git add -p (interactive staging)
function fzf-action-git-status-add-patch() {
    if [[ -z "$1" ]]; then
        echo "Error: No file specified" >&2
        return 1
    fi
    local git_base
    git_base=$(git rev-parse --show-cdup 2>/dev/null) || {
        echo "Error: Not in a git repository" >&2
        return 1
    }
    local file=$(fzf-action-git-status-extract-path "$1")
    if [[ -z "$file" ]]; then
        echo "Error: Could not extract file path" >&2
        return 1
    fi
    local safe_file=$(fzf-action-git-status-sanitize "$file")
    BUFFER="git add -p '${git_base}${safe_file}'"
    zle accept-line
}

# Action: Git reset
function fzf-action-git-status-reset() {
    if [[ -z "$1" ]]; then
        echo "Error: No file specified" >&2
        return 1
    fi
    local git_base
    git_base=$(git rev-parse --show-cdup 2>/dev/null) || {
        echo "Error: Not in a git repository" >&2
        return 1
    }
    local file=$(fzf-action-git-status-extract-path "$1")
    if [[ -z "$file" ]]; then
        echo "Error: Could not extract file path" >&2
        return 1
    fi
    local safe_file=$(fzf-action-git-status-sanitize "$file")
    BUFFER="git reset '${git_base}${safe_file}'"
    zle accept-line
}

# Action: Git restore
function fzf-action-git-status-restore() {
    if [[ -z "$1" ]]; then
        echo "Error: No file specified" >&2
        return 1
    fi
    local git_base
    git_base=$(git rev-parse --show-cdup 2>/dev/null) || {
        echo "Error: Not in a git repository" >&2
        return 1
    }
    local file=$(fzf-action-git-status-extract-path "$1")
    if [[ -z "$file" ]]; then
        echo "Error: Could not extract file path" >&2
        return 1
    fi
    local safe_file=$(fzf-action-git-status-sanitize "$file")
    BUFFER="git restore '${git_base}${safe_file}'"
    zle accept-line
}

# Action: Git diff
function fzf-action-git-status-diff() {
    if [[ -z "$1" ]]; then
        echo "Error: No file specified" >&2
        return 1
    fi
    local git_base
    git_base=$(git rev-parse --show-cdup 2>/dev/null) || {
        echo "Error: Not in a git repository" >&2
        return 1
    }
    local file=$(fzf-action-git-status-extract-path "$1")
    if [[ -z "$file" ]]; then
        echo "Error: Could not extract file path" >&2
        return 1
    fi
    local safe_file=$(fzf-action-git-status-sanitize "$file")
    BUFFER="git diff '${git_base}${safe_file}'"
    zle accept-line
}

# Action: Git rm
function fzf-action-git-status-rm() {
    if [[ -z "$1" ]]; then
        echo "Error: No file specified" >&2
        return 1
    fi
    local git_base
    git_base=$(git rev-parse --show-cdup 2>/dev/null) || {
        echo "Error: Not in a git repository" >&2
        return 1
    }
    local file=$(fzf-action-git-status-extract-path "$1")
    if [[ -z "$file" ]]; then
        echo "Error: Could not extract file path" >&2
        return 1
    fi
    local safe_file=$(fzf-action-git-status-sanitize "$file")
    BUFFER="git rm '${git_base}${safe_file}'"
    zle accept-line
}

# Main function: Git status action with edit as default
function fzf-action-git-status-edit-mode() {
    local candidates=$(fzf-action-git-status-get-candidates)

    if [[ -z "$candidates" ]]; then
        return 1
    fi

    local -a actions=(
        fzf-action-git-status-edit
        fzf-action-git-status-add
        fzf-action-git-status-add-patch
        fzf-action-git-status-reset
        fzf-action-git-status-diff
        fzf-action-git-status-restore
        fzf-action-git-status-append
        fzf-action-git-status-rm
    )

    local -a action_descriptions=(
        "edit (Default)"
        "git add"
        "git add -p"
        "git reset"
        "git diff"
        "git restore"
        "append to edit buffer"
        "git rm"
    )

    fzf-action-core "$candidates" "$(printf "%s\n" "${actions[@]}")" "$(printf "%s\n" "${action_descriptions[@]}")" 1
}

# Main function: Git status action with add as default
function fzf-action-git-status() {
    local candidates=$(fzf-action-git-status-get-candidates)

    if [[ -z "$candidates" ]]; then
        return 1
    fi

    local -a actions=(
        fzf-action-git-status-add
        fzf-action-git-status-add-patch
        fzf-action-git-status-reset
        fzf-action-git-status-restore
        fzf-action-git-status-edit
        fzf-action-git-status-diff
        fzf-action-git-status-append
        fzf-action-git-status-rm
    )

    local -a action_descriptions=(
        "git add (Default)"
        "git add -p"
        "git reset"
        "git restore"
        "edit"
        "git diff"
        "append to edit buffer"
        "git rm"
    )

    fzf-action-core "$candidates" "$(printf "%s\n" "${actions[@]}")" "$(printf "%s\n" "${action_descriptions[@]}")" 1
}

# Create ZLE widgets for key binding
zle -N fzf-action-git-status
zle -N fzf-action-git-status-edit-mode
