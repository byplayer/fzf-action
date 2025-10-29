#!/usr/bin/env zsh
# git-files.zsh - Git file management with fzf action

# Get all git tracked files with status
function fzf-action-git-files-get-candidates() {
    if ! git rev-parse --git-dir >/dev/null 2>&1; then
        echo "Error: Not a git repository" >&2
        return 1
    fi

    local git_base=$(git rev-parse --show-cdup)
    local -a files
    local -A file_status

    # Get file status from git status --porcelain
    while IFS= read -r line; do
        local git_status="${line:0:2}"
        local file_path="${line:3}"
        file_status[$file_path]="$git_status"
    done < <(git status --porcelain 2>/dev/null)

    # Get all tracked files
    while IFS= read -r file; do
        local display_path="$file"
        local status_label=""

        if [[ -n "${file_status[$file]}" ]]; then
            local current_status="${file_status[$file]}"
            case "$current_status" in
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
                *) status_label=$'\033[90m['"$current_status"$']\033[0m' ;;
            esac
            files+=("${display_path} ${status_label}")
        else
            files+=("${display_path}")
        fi
    done < <(git ls-files $git_base 2>/dev/null)

    # Add untracked files
    while IFS= read -r file; do
        if [[ -z "${file_status[$file]}" ]]; then
            file_status[$file]="??"
            files+=("${file} "$'\033[35m[untracked]\033[0m')
        fi
    done < <(git ls-files --others --exclude-standard $git_base 2>/dev/null)

    printf "%s\n" "${files[@]}"
}

# Extract clean file path from formatted output
function fzf-action-git-files-extract-path() {
    local formatted="$1"
    # Strip ANSI codes first
    local clean=$(fzf-action-strip-ansi "$formatted")
    # Remove status label and trailing whitespace using ZSH built-ins
    clean="${clean%% \[*\]}"  # Remove " [status]" from end
    echo "$clean"
}

# Sanitize file path for safe use in commands
function fzf-action-git-files-sanitize() {
    local file="$1"
    # Escape single quotes and wrap in single quotes
    printf '%s' "${file//\'/\'\\\'\'}"
}

# Action: Edit file (default)
function fzf-action-git-files-edit() {
    if [[ -z "$1" ]]; then
        echo "Error: No file specified" >&2
        return 1
    fi
    local git_base
    git_base=$(git rev-parse --show-cdup 2>/dev/null) || {
        echo "Error: Not in a git repository" >&2
        return 1
    }
    local file=$(fzf-action-git-files-extract-path "$1")
    if [[ -z "$file" ]]; then
        echo "Error: Could not extract file path" >&2
        return 1
    fi
    local safe_file=$(fzf-action-git-files-sanitize "$file")
    BUFFER="${EDITOR:-vim} '${git_base}${safe_file}'"
    zle accept-line
}

# Action: Append to edit buffer
function fzf-action-git-files-append() {
    if [[ -z "$1" ]]; then
        echo "Error: No file specified" >&2
        return 1
    fi
    local file=$(fzf-action-git-files-extract-path "$1")
    if [[ -z "$file" ]]; then
        echo "Error: Could not extract file path" >&2
        return 1
    fi
    LBUFFER="${LBUFFER}${file}"
    zle reset-prompt
}

# Action: Git add
function fzf-action-git-files-add() {
    if [[ -z "$1" ]]; then
        echo "Error: No file specified" >&2
        return 1
    fi
    local git_base
    git_base=$(git rev-parse --show-cdup 2>/dev/null) || {
        echo "Error: Not in a git repository" >&2
        return 1
    }
    local file=$(fzf-action-git-files-extract-path "$1")
    if [[ -z "$file" ]]; then
        echo "Error: Could not extract file path" >&2
        return 1
    fi
    local safe_file=$(fzf-action-git-files-sanitize "$file")
    BUFFER="git add '${git_base}${safe_file}'"
    zle accept-line
}

# Action: Git add -p (interactive staging)
function fzf-action-git-files-add-patch() {
    if [[ -z "$1" ]]; then
        echo "Error: No file specified" >&2
        return 1
    fi
    local git_base
    git_base=$(git rev-parse --show-cdup 2>/dev/null) || {
        echo "Error: Not in a git repository" >&2
        return 1
    }
    local file=$(fzf-action-git-files-extract-path "$1")
    if [[ -z "$file" ]]; then
        echo "Error: Could not extract file path" >&2
        return 1
    fi
    local safe_file=$(fzf-action-git-files-sanitize "$file")
    BUFFER="git add -p '${git_base}${safe_file}'"
    zle accept-line
}

# Action: Git reset
function fzf-action-git-files-reset() {
    if [[ -z "$1" ]]; then
        echo "Error: No file specified" >&2
        return 1
    fi
    local git_base
    git_base=$(git rev-parse --show-cdup 2>/dev/null) || {
        echo "Error: Not in a git repository" >&2
        return 1
    }
    local file=$(fzf-action-git-files-extract-path "$1")
    if [[ -z "$file" ]]; then
        echo "Error: Could not extract file path" >&2
        return 1
    fi
    local safe_file=$(fzf-action-git-files-sanitize "$file")
    BUFFER="git reset '${git_base}${safe_file}'"
    zle accept-line
}

# Action: Git restore
function fzf-action-git-files-restore() {
    if [[ -z "$1" ]]; then
        echo "Error: No file specified" >&2
        return 1
    fi
    local git_base
    git_base=$(git rev-parse --show-cdup 2>/dev/null) || {
        echo "Error: Not in a git repository" >&2
        return 1
    }
    local file=$(fzf-action-git-files-extract-path "$1")
    if [[ -z "$file" ]]; then
        echo "Error: Could not extract file path" >&2
        return 1
    fi
    local safe_file=$(fzf-action-git-files-sanitize "$file")
    BUFFER="git restore '${git_base}${safe_file}'"
    zle accept-line
}

# Action: Git checkout
function fzf-action-git-files-checkout() {
    if [[ -z "$1" ]]; then
        echo "Error: No file specified" >&2
        return 1
    fi
    local git_base
    git_base=$(git rev-parse --show-cdup 2>/dev/null) || {
        echo "Error: Not in a git repository" >&2
        return 1
    }
    local file=$(fzf-action-git-files-extract-path "$1")
    if [[ -z "$file" ]]; then
        echo "Error: Could not extract file path" >&2
        return 1
    fi
    local safe_file=$(fzf-action-git-files-sanitize "$file")
    BUFFER="git checkout '${git_base}${safe_file}'"
    zle accept-line
}

# Action: Git rm
function fzf-action-git-files-rm() {
    if [[ -z "$1" ]]; then
        echo "Error: No file specified" >&2
        return 1
    fi
    local git_base
    git_base=$(git rev-parse --show-cdup 2>/dev/null) || {
        echo "Error: Not in a git repository" >&2
        return 1
    }
    local file=$(fzf-action-git-files-extract-path "$1")
    if [[ -z "$file" ]]; then
        echo "Error: Could not extract file path" >&2
        return 1
    fi
    local safe_file=$(fzf-action-git-files-sanitize "$file")
    BUFFER="git rm '${git_base}${safe_file}'"
    zle accept-line
}

# Action: Git diff
function fzf-action-git-files-diff() {
    if [[ -z "$1" ]]; then
        echo "Error: No file specified" >&2
        return 1
    fi
    local git_base
    git_base=$(git rev-parse --show-cdup 2>/dev/null) || {
        echo "Error: Not in a git repository" >&2
        return 1
    }
    local file=$(fzf-action-git-files-extract-path "$1")
    if [[ -z "$file" ]]; then
        echo "Error: Could not extract file path" >&2
        return 1
    fi
    local safe_file=$(fzf-action-git-files-sanitize "$file")
    BUFFER="git diff '${git_base}${safe_file}'"
    zle accept-line
}

# Action: Git diff --stat
function fzf-action-git-files-diff-stat() {
    if [[ -z "$1" ]]; then
        echo "Error: No file specified" >&2
        return 1
    fi
    local git_base
    git_base=$(git rev-parse --show-cdup 2>/dev/null) || {
        echo "Error: Not in a git repository" >&2
        return 1
    }
    local file=$(fzf-action-git-files-extract-path "$1")
    if [[ -z "$file" ]]; then
        echo "Error: Could not extract file path" >&2
        return 1
    fi
    local safe_file=$(fzf-action-git-files-sanitize "$file")
    BUFFER="git diff --stat '${git_base}${safe_file}'"
    zle accept-line
}

# Action: Git log
function fzf-action-git-files-log() {
    if [[ -z "$1" ]]; then
        echo "Error: No file specified" >&2
        return 1
    fi
    local git_base
    git_base=$(git rev-parse --show-cdup 2>/dev/null) || {
        echo "Error: Not in a git repository" >&2
        return 1
    }
    local file=$(fzf-action-git-files-extract-path "$1")
    if [[ -z "$file" ]]; then
        echo "Error: Could not extract file path" >&2
        return 1
    fi
    local safe_file=$(fzf-action-git-files-sanitize "$file")
    BUFFER="git log '${git_base}${safe_file}'"
    zle accept-line
}

# Action: Git log --oneline
function fzf-action-git-files-log-oneline() {
    if [[ -z "$1" ]]; then
        echo "Error: No file specified" >&2
        return 1
    fi
    local git_base
    git_base=$(git rev-parse --show-cdup 2>/dev/null) || {
        echo "Error: Not in a git repository" >&2
        return 1
    }
    local file=$(fzf-action-git-files-extract-path "$1")
    if [[ -z "$file" ]]; then
        echo "Error: Could not extract file path" >&2
        return 1
    fi
    local safe_file=$(fzf-action-git-files-sanitize "$file")
    BUFFER="git log --oneline '${git_base}${safe_file}'"
    zle accept-line
}

# Action: Cat file
function fzf-action-git-files-cat() {
    if [[ -z "$1" ]]; then
        echo "Error: No file specified" >&2
        return 1
    fi
    local git_base
    git_base=$(git rev-parse --show-cdup 2>/dev/null) || {
        echo "Error: Not in a git repository" >&2
        return 1
    }
    local file=$(fzf-action-git-files-extract-path "$1")
    if [[ -z "$file" ]]; then
        echo "Error: Could not extract file path" >&2
        return 1
    fi
    local safe_file=$(fzf-action-git-files-sanitize "$file")
    BUFFER="cat '${git_base}${safe_file}'"
    zle accept-line
}

# Action: Less file
function fzf-action-git-files-less() {
    if [[ -z "$1" ]]; then
        echo "Error: No file specified" >&2
        return 1
    fi
    local git_base
    git_base=$(git rev-parse --show-cdup 2>/dev/null) || {
        echo "Error: Not in a git repository" >&2
        return 1
    }
    local file=$(fzf-action-git-files-extract-path "$1")
    if [[ -z "$file" ]]; then
        echo "Error: Could not extract file path" >&2
        return 1
    fi
    local safe_file=$(fzf-action-git-files-sanitize "$file")
    BUFFER="less '${git_base}${safe_file}'"
    zle accept-line
}

# Action: Copy path to clipboard
function fzf-action-git-files-copy-path() {
    if [[ -z "$1" ]]; then
        echo "Error: No file specified" >&2
        return 1
    fi
    local git_base
    git_base=$(git rev-parse --show-cdup 2>/dev/null) || {
        echo "Error: Not in a git repository" >&2
        return 1
    }
    local file=$(fzf-action-git-files-extract-path "$1")
    if [[ -z "$file" ]]; then
        echo "Error: Could not extract file path" >&2
        return 1
    fi
    local full_path="${git_base}${file}"

    if [[ -n "$FZF_ACTION_CLIP_COPY_CMD" ]]; then
        BUFFER="echo -n '${full_path}' | ${FZF_ACTION_CLIP_COPY_CMD}"
        zle accept-line
    else
        echo "Error: FZF_ACTION_CLIP_COPY_CMD is not set" >&2
        zle reset-prompt
        return 1
    fi
}

# Main function: Git files action
function fzf-action-git-files() {
    local candidates=$(fzf-action-git-files-get-candidates)

    if [[ -z "$candidates" ]]; then
        return 1
    fi

    local -a actions=(
        fzf-action-git-files-edit
        fzf-action-git-files-append
        fzf-action-git-files-add
        fzf-action-git-files-add-patch
        fzf-action-git-files-reset
        fzf-action-git-files-restore
        fzf-action-git-files-checkout
        fzf-action-git-files-diff
        fzf-action-git-files-diff-stat
        fzf-action-git-files-log
        fzf-action-git-files-log-oneline
        fzf-action-git-files-cat
        fzf-action-git-files-less
        fzf-action-git-files-copy-path
        fzf-action-git-files-rm
    )

    local -a action_descriptions=(
        "edit (Default)"
        "append to edit buffer"
        "git add"
        "git add -p"
        "git reset"
        "git restore"
        "git checkout"
        "git diff"
        "git diff --stat"
        "git log"
        "git log --oneline"
        "cat"
        "less"
        "copy path to clipboard"
        "git rm"
    )

    fzf-action-core "$candidates" "$(printf "%s\n" "${actions[@]}")" "$(printf "%s\n" "${action_descriptions[@]}")" 1
}

# Create ZLE widget for key binding
zle -N fzf-action-git-files
