#!/usr/bin/env zsh
# git-branches.zsh - Git branch management with fzf action

# Get all git branches (local and remote)
function fzf-action-git-branches-get-candidates() {
    if ! git rev-parse --git-dir >/dev/null 2>&1; then
        echo "Error: Not a git repository" >&2
        return 1
    fi

    local -a branches

    # Get local branches
    while IFS= read -r line; do
        local is_current=""
        local branch_name=$(echo "$line" | sed 's/^..//')

        if [[ "$line" == \** ]]; then
            is_current="* "
            branch_name=$(echo "$branch_name" | sed 's/^* //')
        fi

        # Mark current branch with color (bold yellow for better visibility)
        if [[ -n "$is_current" ]]; then
            branches+=($'\033[1;33m'"${is_current}${branch_name}"$'\033[0m'" (local)")
        else
            branches+=("  ${branch_name} (local)")
        fi
    done < <(git branch 2>/dev/null)

    # Get remote branches
    while IFS= read -r line; do
        local branch_name=$(echo "$line" | sed 's/^..//')

        # Skip HEAD pointer
        if [[ "$branch_name" =~ "HEAD ->" ]]; then
            continue
        fi

        branches+=("  ${branch_name} (remote)")
    done < <(git branch -r 2>/dev/null)

    printf "%s\n" "${branches[@]}"
}

# Get local git branches only
function fzf-action-git-branches-get-local-candidates() {
    if ! git rev-parse --git-dir >/dev/null 2>&1; then
        echo "Error: Not a git repository" >&2
        return 1
    fi

    local -a branches

    # Get local branches only
    while IFS= read -r line; do
        local is_current=""
        local branch_name=$(echo "$line" | sed 's/^..//')

        if [[ "$line" == \** ]]; then
            is_current="* "
            branch_name=$(echo "$branch_name" | sed 's/^* //')
        fi

        # Mark current branch with color (bold yellow for better visibility)
        if [[ -n "$is_current" ]]; then
            branches+=($'\033[1;33m'"${is_current}${branch_name}"$'\033[0m'" (local)")
        else
            branches+=("  ${branch_name} (local)")
        fi
    done < <(git branch 2>/dev/null)

    printf "%s\n" "${branches[@]}"
}

# Extract clean branch name from formatted output
function fzf-action-git-branches-extract-name() {
    local formatted="$1"
    # Strip ANSI codes first
    local clean=$(fzf-action-strip-ansi "$formatted")
    # Remove leading spaces and asterisk
    clean="${clean##*( |\*)}"
    clean="${clean## }"
    # Remove trailing markers
    clean="${clean%% (local)}"
    clean="${clean%% (remote)}"
    echo "$clean"
}

# Action: Switch to branch (default)
function fzf-action-git-branches-checkout() {
    local branch=$(fzf-action-git-branches-extract-name "$1")

    # Check if it's a remote branch
    if [[ "$1" =~ "(remote)" ]]; then
        # Extract local branch name from remote branch (e.g., origin/main -> main)
        local local_branch=$(echo "$branch" | sed 's|^[^/]*/||')
        # Check if local branch already exists
        if git show-ref --verify --quiet "refs/heads/$local_branch"; then
            BUFFER="git switch '$local_branch'"
        else
            BUFFER="git switch -c '$local_branch' '$branch'"
        fi
    else
        BUFFER="git switch '$branch'"
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
    BUFFER="git merge '$branch'"
    zle accept-line
}

# Action: Merge with rebase
function fzf-action-git-branches-merge-rebase() {
    local branch=$(fzf-action-git-branches-extract-name "$1")
    BUFFER="git merge --rebase '$branch'"
    zle accept-line
}

# Action: Merge with no-ff
function fzf-action-git-branches-merge-noff() {
    local branch=$(fzf-action-git-branches-extract-name "$1")
    BUFFER="git merge --no-ff '$branch'"
    zle accept-line
}

# Action: Merge to another branch
function fzf-action-git-branches-merge-to() {
    local branch=$(fzf-action-git-branches-extract-name "$1")
    local target_branch
    target_branch=$(git branch | sed 's/^..//' | fzf --header="Select target branch to merge into")

    if [[ -n "$target_branch" ]]; then
        BUFFER="git switch '$target_branch' && git merge '$branch'"
        zle accept-line
    fi
}

# Action: Reset to branch
function fzf-action-git-branches-reset() {
    local branch=$(fzf-action-git-branches-extract-name "$1")
    BUFFER="git reset '$branch'"
    zle accept-line
}

# Action: Rebase
function fzf-action-git-branches-rebase() {
    local branch=$(fzf-action-git-branches-extract-name "$1")
    BUFFER="git rebase '$branch'"
    zle accept-line
}

# Action: Rebase interactive from branch
function fzf-action-git-branches-rebase-interactive() {
    local branch=$(fzf-action-git-branches-extract-name "$1")
    BUFFER="git rebase -i '$branch'"
    zle accept-line
}

# Action: Create new branch from selected
function fzf-action-git-branches-create-from() {
    local branch=$(fzf-action-git-branches-extract-name "$1")
    echo -n "Enter new branch name: "
    read new_branch

    if [[ -z "$new_branch" ]]; then
        return 0
    fi

    # Validate branch name (alphanumeric, slash, dash, underscore only)
    if [[ ! "$new_branch" =~ ^[a-zA-Z0-9/_-]+$ ]]; then
        echo "Error: Invalid branch name (use only letters, numbers, /, -, _)" >&2
        zle reset-prompt
        return 1
    fi

    # Check if branch already exists
    if git show-ref --verify --quiet "refs/heads/$new_branch"; then
        echo "Error: Branch '$new_branch' already exists" >&2
        zle reset-prompt
        return 1
    fi

    BUFFER="git switch -c '$new_branch' '$branch'"
    zle accept-line
}

# Action: Show diff
function fzf-action-git-branches-diff() {
    local branch=$(fzf-action-git-branches-extract-name "$1")
    BUFFER="git diff '$branch'"
    zle accept-line
}

# Action: Show diff statistics
function fzf-action-git-branches-diff-stat() {
    local branch=$(fzf-action-git-branches-extract-name "$1")
    BUFFER="git diff --stat '$branch'"
    zle accept-line
}

# Action: Reset hard to branch
function fzf-action-git-branches-reset-hard() {
    local branch=$(fzf-action-git-branches-extract-name "$1")
    echo "WARNING: This will reset hard to branch: $branch"
    echo -n "Are you sure? (y/N): "
    read confirm

    if [[ "$confirm" == "y" || "$confirm" == "Y" ]]; then
        BUFFER="git reset --hard '$branch'"
        zle accept-line
    else
        echo "Cancelled"
        zle reset-prompt
    fi
}

# Action: Delete branch
function fzf-action-git-branches-delete() {
    local branch=$(fzf-action-git-branches-extract-name "$1")

    # Check if it's a remote branch
    if [[ "$1" =~ "(remote)" ]]; then
        echo "Cannot delete remote branches with this action"
        echo "Use 'git push origin --delete $branch' manually"
        zle reset-prompt
        return 1
    fi

    BUFFER="git branch -d '$branch'"
    zle accept-line
}

# Action: Force delete branch
function fzf-action-git-branches-delete-force() {
    local branch=$(fzf-action-git-branches-extract-name "$1")

    # Check if it's a remote branch
    if [[ "$1" =~ "(remote)" ]]; then
        echo "Cannot delete remote branches with this action"
        echo "Use 'git push origin --delete $branch' manually"
        zle reset-prompt
        return 1
    fi

    BUFFER="git branch -D '$branch'"
    zle accept-line
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
        "reset hard"
        "delete"
        "delete force"
    )

    fzf-action-core "$candidates" "$(printf "%s\n" "${actions[@]}")" "$(printf "%s\n" "${action_descriptions[@]}")" 1
}

# Create ZLE widget for key binding
zle -N fzf-action-git-branches
