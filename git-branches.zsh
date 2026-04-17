#!/usr/bin/env zsh
# git-branches.zsh - Git branch management with fzf action

# Get all git branches (local and remote)
function fzf-action-git-branches-get-candidates() {
    if ! git rev-parse --git-dir >/dev/null 2>&1; then
        echo "Error: Not a git repository" >&2
        return 1
    fi

    local -a branches
    local head_marker refname symref

    # Get local branches
    while IFS=$'\t' read -r head_marker refname; do
        if [[ "$head_marker" == "*" ]]; then
            branches+=($'\033[1;33m'"* ${refname}"$'\033[0m'" (local)")
        else
            branches+=("  ${refname} (local)")
        fi
    done < <(git for-each-ref --format='%(HEAD)%09%(refname:short)' refs/heads/ 2>/dev/null)

    # Get remote branches (skip symbolic refs like origin/HEAD)
    # Note: symref field is placed last because leading IFS whitespace (tab)
    # gets stripped by `read`, which would break detection of empty symref.
    while IFS=$'\t' read -r refname symref; do
        [[ -n "$symref" ]] && continue
        branches+=("  ${refname} (remote)")
    done < <(git for-each-ref --format='%(refname:short)%09%(symref)' refs/remotes/ 2>/dev/null)

    printf "%s\n" "${branches[@]}"
}

# Get local git branches only
function fzf-action-git-branches-get-local-candidates() {
    if ! git rev-parse --git-dir >/dev/null 2>&1; then
        echo "Error: Not a git repository" >&2
        return 1
    fi

    local -a branches
    local head_marker refname

    # Get local branches only
    while IFS=$'\t' read -r head_marker refname; do
        if [[ "$head_marker" == "*" ]]; then
            branches+=($'\033[1;33m'"* ${refname}"$'\033[0m'" (local)")
        else
            branches+=("  ${refname} (local)")
        fi
    done < <(git for-each-ref --format='%(HEAD)%09%(refname:short)' refs/heads/ 2>/dev/null)

    printf "%s\n" "${branches[@]}"
}

# Extract clean branch name from formatted output
function fzf-action-git-branches-extract-name() {
    local formatted="$1"
    # Strip ANSI codes first
    local clean=$(fzf-action-strip-ansi "$formatted")
    # Remove: leading spaces/asterisk and any following spaces, then trailing markers
    clean=$(sed -e 's/^[[:space:]]*\*[[:space:]]*//' -e 's/^[[:space:]]*//' -e 's/ (local)$//' -e 's/ (remote)$//' <<< "$clean")
    echo "$clean"
}

# Sanitize branch name for safe use in git commands
# This prevents command injection by ensuring branch names are safe
function fzf-action-git-branches-sanitize() {
    local branch="$1"
    # Git branch names should not contain: spaces, ~, ^, :, ?, *, [, \, .., @{, //
    # and should not start with ., end with .lock, or contain control characters
    # However, they may legitimately contain /, -, _
    # For safety, we escape single quotes and wrap in single quotes
    # This prevents any shell interpretation of special characters
    printf '%s' "${branch//\'/\'\\\'\'}"
}

# Action: Switch to branch (default)
function fzf-action-git-branches-checkout() {
    local branch=$(fzf-action-git-branches-extract-name "$1")
    local safe_branch=$(fzf-action-git-branches-sanitize "$branch")

    # Check if it's a remote branch
    if [[ "$1" =~ "(remote)" ]]; then
        # Extract local branch name from remote branch (e.g., origin/main -> main)
        local local_branch=$(echo "$branch" | sed 's|^[^/]*/||')
        local safe_local_branch=$(fzf-action-git-branches-sanitize "$local_branch")
        # Check if local branch already exists
        if git show-ref --verify --quiet "refs/heads/$local_branch"; then
            BUFFER="git switch '${safe_local_branch}'"
        else
            BUFFER="git switch -c '${safe_local_branch}' '${safe_branch}'"
        fi
    else
        BUFFER="git switch '${safe_branch}'"
    fi
    zle accept-line
}

# Action: Append to edit buffer
function fzf-action-git-branches-append() {
    local branch=$(fzf-action-git-branches-extract-name "$1")
    LBUFFER="${LBUFFER}${branch}"
    zle reset-prompt
}

# Action: Merge
function fzf-action-git-branches-merge() {
    local branch=$(fzf-action-git-branches-extract-name "$1")
    local safe_branch=$(fzf-action-git-branches-sanitize "$branch")
    BUFFER="git merge '${safe_branch}'"
    zle accept-line
}

# Action: Merge with rebase
function fzf-action-git-branches-merge-rebase() {
    local branch=$(fzf-action-git-branches-extract-name "$1")
    local safe_branch=$(fzf-action-git-branches-sanitize "$branch")
    BUFFER="git merge --rebase '${safe_branch}'"
    zle accept-line
}

# Action: Merge with no-ff
function fzf-action-git-branches-merge-noff() {
    local branch=$(fzf-action-git-branches-extract-name "$1")
    local safe_branch=$(fzf-action-git-branches-sanitize "$branch")
    BUFFER="git merge --no-ff '${safe_branch}'"
    zle accept-line
}

# Action: Merge to another branch
function fzf-action-git-branches-merge-to() {
    local branch=$(fzf-action-git-branches-extract-name "$1")
    local safe_branch=$(fzf-action-git-branches-sanitize "$branch")
    local target_branch
    target_branch=$(git branch | sed 's/^..//' | fzf --header="Select target branch to merge into")

    if [[ -n "$target_branch" ]]; then
        local safe_target=$(fzf-action-git-branches-sanitize "$target_branch")
        BUFFER="git switch '${safe_target}' && git merge '${safe_branch}'"
        zle accept-line
    fi
}

# Action: Reset to branch
function fzf-action-git-branches-reset() {
    local branch=$(fzf-action-git-branches-extract-name "$1")
    local safe_branch=$(fzf-action-git-branches-sanitize "$branch")
    BUFFER="git reset '${safe_branch}'"
    zle accept-line
}

# Action: Rebase
function fzf-action-git-branches-rebase() {
    local branch=$(fzf-action-git-branches-extract-name "$1")
    local safe_branch=$(fzf-action-git-branches-sanitize "$branch")
    BUFFER="git rebase '${safe_branch}'"
    zle accept-line
}

# Action: Rebase interactive from branch
function fzf-action-git-branches-rebase-interactive() {
    local branch=$(fzf-action-git-branches-extract-name "$1")
    local safe_branch=$(fzf-action-git-branches-sanitize "$branch")
    BUFFER="git rebase -i '${safe_branch}'"
    zle accept-line
}

# Action: Create new branch from selected
function fzf-action-git-branches-create-from() {
    local branch=$(fzf-action-git-branches-extract-name "$1")
    local safe_branch=$(fzf-action-git-branches-sanitize "$branch")
    echo -n "Enter new branch name: " >&2
    read new_branch

    if [[ -z "$new_branch" ]]; then
        return 0
    fi

    # Validate branch name (alphanumeric, slash, dash, underscore only)
    if [[ ! "$new_branch" =~ ^[a-zA-Z0-9/_-]+$ ]]; then
        echo "Error: Invalid branch name (use only letters, numbers, /, -, _)" >&2
        return 1
    fi

    # Check if branch already exists
    if git show-ref --verify --quiet "refs/heads/$new_branch"; then
        echo "Error: Branch '$new_branch' already exists" >&2
        return 1
    fi

    local safe_new_branch=$(fzf-action-git-branches-sanitize "$new_branch")
    BUFFER="git switch -c '${safe_new_branch}' '${safe_branch}'"
    zle accept-line
}

# Action: Show diff
function fzf-action-git-branches-diff() {
    local branch=$(fzf-action-git-branches-extract-name "$1")
    local safe_branch=$(fzf-action-git-branches-sanitize "$branch")
    BUFFER="git diff '${safe_branch}'"
    zle accept-line
}

# Action: Show diff statistics
function fzf-action-git-branches-diff-stat() {
    local branch=$(fzf-action-git-branches-extract-name "$1")
    local safe_branch=$(fzf-action-git-branches-sanitize "$branch")
    BUFFER="git diff --stat '${safe_branch}'"
    zle accept-line
}

# Action: Reset hard to branch
function fzf-action-git-branches-reset-hard() {
    local branch=$(fzf-action-git-branches-extract-name "$1")
    local safe_branch=$(fzf-action-git-branches-sanitize "$branch")
    echo "WARNING: This will reset hard to branch: $branch" >&2
    echo -n "Are you sure? (y/N): " >&2
    read confirm

    if [[ "$confirm" == "y" || "$confirm" == "Y" ]]; then
        BUFFER="git reset --hard '${safe_branch}'"
        zle accept-line
    else
        echo "Cancelled" >&2
        zle reset-prompt
    fi
}

# Action: Add worktree from branch
function fzf-action-git-branches-worktree-add() {
    local branch=$(fzf-action-git-branches-extract-name "$1")
    local safe_branch=$(fzf-action-git-branches-sanitize "$branch")
    # Strip remote prefix (e.g., origin/feature/login -> feature/login)
    local local_branch="$branch"
    if [[ "$1" =~ "(remote)" ]]; then
        local_branch="${branch#*/}"
    fi
    local safe_local_branch=$(fzf-action-git-branches-sanitize "$local_branch")

    if command -v git-wtadd >/dev/null 2>&1; then
        BUFFER="git-wtadd '${safe_local_branch}' '${safe_branch}'"
    else
        # Escape branch name for directory: replace / with -
        local escaped="${local_branch//\//-}"
        local safe_escaped=$(fzf-action-git-branches-sanitize "$escaped")
        BUFFER="git worktree add '.worktree/${safe_escaped}' '${safe_branch}'"
    fi
    zle accept-line
}

# Action: Delete branch
function fzf-action-git-branches-delete() {
    local branch=$(fzf-action-git-branches-extract-name "$1")
    local safe_branch=$(fzf-action-git-branches-sanitize "$branch")

    # Check if it's a remote branch
    if [[ "$1" =~ "(remote)" ]]; then
        # Extract remote name and branch name from "remote/branch"
        local remote="${branch%%/*}"
        local branch_name="${branch#*/}"
        local safe_remote=$(fzf-action-git-branches-sanitize "$remote")
        local safe_branch_name=$(fzf-action-git-branches-sanitize "$branch_name")
        BUFFER="git push --delete '${safe_remote}' '${safe_branch_name}'"
        zle accept-line
    else
        BUFFER="git branch -d '${safe_branch}'"
        zle accept-line
    fi
}

# Action: Force delete branch
function fzf-action-git-branches-delete-force() {
    local branch=$(fzf-action-git-branches-extract-name "$1")
    local safe_branch=$(fzf-action-git-branches-sanitize "$branch")

    # Check if it's a remote branch
    if [[ "$1" =~ "(remote)" ]]; then
        # Extract remote name and branch name from "remote/branch"
        local remote="${branch%%/*}"
        local branch_name="${branch#*/}"
        local safe_remote=$(fzf-action-git-branches-sanitize "$remote")
        local safe_branch_name=$(fzf-action-git-branches-sanitize "$branch_name")
        BUFFER="git push --delete '${safe_remote}' '${safe_branch_name}'"
        zle accept-line
    else
        BUFFER="git branch -D '${safe_branch}'"
        zle accept-line
    fi
}

# Main function: Git branches action
function fzf-action-git-branches-all() {
    local candidates=$(fzf-action-git-branches-get-candidates)

    if [[ -z "$candidates" ]]; then
        return 1
    fi

    local -a actions=(
        fzf-action-git-branches-checkout
        fzf-action-git-branches-append
        fzf-action-git-branches-merge
        fzf-action-git-branches-merge-rebase
        fzf-action-git-branches-merge-noff
        fzf-action-git-branches-merge-to
        fzf-action-git-branches-reset
        fzf-action-git-branches-rebase
        fzf-action-git-branches-rebase-interactive
        fzf-action-git-branches-create-from
        fzf-action-git-branches-diff
        fzf-action-git-branches-diff-stat
        fzf-action-git-branches-worktree-add
        fzf-action-git-branches-reset-hard
        fzf-action-git-branches-delete
        fzf-action-git-branches-delete-force
    )

    local -a action_descriptions=(
        "switch (Default)"
        "append to edit buffer"
        "merge"
        "merge rebase"
        "merge no ff"
        "merge to"
        "reset"
        "rebase"
        "rebase interactive from..."
        "create new branch from..."
        "diff"
        "diff statistics"
        "worktree add"
        "reset hard"
        "delete"
        "delete force"
    )

    fzf-action-core "$candidates" "$(printf "%s\n" "${actions[@]}")" "$(printf "%s\n" "${action_descriptions[@]}")" 1
}

# Create ZLE widget for key binding
zle -N fzf-action-git-branches-all

# Main function: Git branches action (local branches only)
function fzf-action-git-branches() {
    local candidates=$(fzf-action-git-branches-get-local-candidates)

    if [[ -z "$candidates" ]]; then
        return 1
    fi

    local -a actions=(
        fzf-action-git-branches-checkout
        fzf-action-git-branches-append
        fzf-action-git-branches-merge
        fzf-action-git-branches-merge-rebase
        fzf-action-git-branches-merge-noff
        fzf-action-git-branches-merge-to
        fzf-action-git-branches-reset
        fzf-action-git-branches-rebase
        fzf-action-git-branches-rebase-interactive
        fzf-action-git-branches-create-from
        fzf-action-git-branches-diff
        fzf-action-git-branches-diff-stat
        fzf-action-git-branches-worktree-add
        fzf-action-git-branches-reset-hard
        fzf-action-git-branches-delete
        fzf-action-git-branches-delete-force
    )

    local -a action_descriptions=(
        "switch (Default)"
        "append to edit buffer"
        "merge"
        "merge rebase"
        "merge no ff"
        "merge to"
        "reset"
        "rebase"
        "rebase interactive from..."
        "create new branch from..."
        "diff"
        "diff statistics"
        "worktree add"
        "reset hard"
        "delete"
        "delete force"
    )

    fzf-action-core "$candidates" "$(printf "%s\n" "${actions[@]}")" "$(printf "%s\n" "${action_descriptions[@]}")" 1
}

# Create ZLE widget for key binding
zle -N fzf-action-git-branches
