# fzf-action

<!-- markdownlint-disable MD013 -->

[![Version](https://img.shields.io/badge/version-0.1.3-blue.svg)](CHANGELOG.md)

A ZSH plugin that provides zaw-like action selection menus using fzf.

> See [CHANGELOG.md](CHANGELOG.md) for version history and updates.

## Features

- **Two-stage selection workflow**: Select item → Select action
- **fzf-based interface**: Fast, intuitive fuzzy finding
- **Git branch management**: Comprehensive branch operations with menu selection
- **Git file management**: File operations with color-coded status indicators
- **Extensible**: Easy to add new sources and actions

## Requirements

- ZSH
- [fzf](https://github.com/junegunn/fzf) (command-line fuzzy finder)

## Installation

1. Clone or copy this plugin to your ZSH plugins directory:

   ```bash
   # If you're using this as part of .zsh.d
   # The plugin should be in: ~/.zsh.d/plugins/fzf-action/
   ```

2. Load the plugin in your `.zshrc` or ZSH configuration:

   **Option A: Auto-loading (Recommended)**

   ```zsh
   # Simply source the plugin file - it will auto-load all components
   source ~/.zsh.d/plugins/fzf-action/fzf-action.plugin.zsh
   ```

   **Option B: Manual loading**

   ```zsh
   source ~/.zsh.d/plugins/fzf-action/fzf-action.zsh
   source ~/.zsh.d/plugins/fzf-action/git-branches.zsh
   source ~/.zsh.d/plugins/fzf-action/git-files.zsh
   ```

3. **Add key bindings** (Required):

   These functions are ZLE widgets and can only be used via key bindings. Add the following to your `.zshrc`:

   ```zsh
   bindkey '^g^b' fzf-action-git-branches-all  # All branches (local + remote)
   bindkey '^gb' fzf-action-git-branches       # Local branches only
   bindkey '^gf' fzf-action-git-files          # Git files
   ```

   You can use any key combination you prefer.

## Usage

> **Important**: These are ZLE widgets that integrate with the Zsh Line Editor. They must be invoked via key bindings and cannot be called directly from the command line.

### Git Branches (All)

Press the key binding (e.g., `Ctrl+g Ctrl+b`) to display **all local and remote branches** in your git repository.

### Git Branches (Local Only)

Press the key binding (e.g., `Ctrl+g b`) to display **local branches only** in your git repository.

**Workflow:**

1. **Select a branch**: Use arrow keys or type to filter branches
2. **Choose action**:
   - Press `ENTER`: Execute default action (switch to branch)
   - Press `TAB`: Open action menu to select from available operations

**Available Actions:**

- **switch** (Default) - Switch to the selected branch (uses `git switch`)
- **append to edit buffer** - Insert branch name into command line
- **merge** - Merge the selected branch into current branch
- **merge rebase** - Merge with rebase strategy
- **merge no ff** - Merge with --no-ff flag
- **merge to** - Merge the branch into another target branch
- **reset** - Reset current branch to selected branch
- **rebase** - Rebase current branch onto selected branch
- **rebase interactive from...** - Interactive rebase from selected branch
- **create new branch from...** - Create new branch from selected branch
- **diff** - Show diff between current and selected branch
- **diff statistics** - Show diff statistics
- **reset hard** - Hard reset to selected branch (with confirmation)
- **delete** - Delete the selected local branch
- **delete force** - Force delete the selected local branch

### Git Files

Press the key binding (e.g., `Ctrl+g f`) to display **all tracked and untracked files** in your git repository with color-coded status indicators.

**Workflow:**

1. **Select a file**: Use arrow keys or type to filter files
2. **Choose action**:
   - Press `ENTER`: Execute default action (edit file in $EDITOR)
   - Press `TAB`: Open action menu to select from available operations

**Available Actions:**

- **edit** (Default) - Edit file in your editor (uses `$EDITOR` or `vim`)
- **append to edit buffer** - Insert file path into command line
- **git add** - Stage the file
- **git add -p** - Interactive staging (stage specific hunks)
- **git reset** - Unstage the file
- **git restore** - Restore working tree changes
- **git checkout** - Checkout the file from HEAD
- **git diff** - Show diff for the file
- **git diff --stat** - Show diff statistics
- **git log** - Show commit history for the file
- **git log --oneline** - Show one-line commit history
- **cat** - Display file contents
- **less** - View file in pager
- **copy path to clipboard** - Copy file path to clipboard (macOS)
- **git rm** - Remove the file from git

### File Status Display

Files are displayed with color-coded status indicators:

- **[modified]** (yellow) - File has unstaged changes
- **[staged]** (green) - File is staged for commit
- **[staged|modified]** (cyan) - File is staged but has additional unstaged changes
- **[staged(add)]** (green) - New file staged for commit
- **[add|modified]** (cyan) - New file staged but with additional changes
- **[deleted]** (red) - File is deleted
- **[staged(del)]** (red) - File deletion is staged
- **[untracked]** (magenta) - File is not tracked by git
- **[conflict]** (bold red) - File has merge conflicts

### Branch Display

- Current branch is highlighted in **bold yellow** with an asterisk (\*)
- Local branches are marked with `(local)`
- Remote branches are shown as `<remote>/<branch>` and marked with `(remote)` (only in `fzf-action-git-branches-all`)
  - Example: `origin/main (remote)`, `upstream/develop (remote)`

## Examples

### Quick switch (all branches)

```zsh
# Press Ctrl+g Ctrl+b (or your configured key binding)
# Type to filter: "feat"
# Press ENTER to switch to the branch
```

### Quick switch (local branches only)

```zsh
# Press Ctrl+g b (or your configured key binding)
# Type to filter: "feat"
# Press ENTER to switch to the branch
```

### Select action

```zsh
# Press Ctrl+g Ctrl+b or Ctrl+g b (or your configured key binding)
# Select a branch
# Press TAB
# Choose "diff" from action menu
```

### Git files example

```zsh
# Press Ctrl+g f (or your configured key binding)
# Type to filter: "src/index"
# Press ENTER to edit the file
# or Press TAB and choose "git diff" to see changes
```

### Key binding example

```zsh
# Add to your .zshrc
bindkey '^g^b' fzf-action-git-branches-all  # Ctrl+g Ctrl+b - all branches
bindkey '^gb' fzf-action-git-branches       # Ctrl+g b - local branches only
bindkey '^gf' fzf-action-git-files          # Ctrl+g f - git files

# Now you can press:
# - Ctrl+g Ctrl+b to open all branches menu
# - Ctrl+g b to open local branches menu
# - Ctrl+g f to open git files menu
```

## Architecture

The plugin consists of these main components:

1. **fzf-action.zsh**: Core framework for creating fzf-based action menus
   - `fzf-action-core()`: Main function that handles the two-stage selection
   - Reusable for creating other menu sources

2. **git-branches.zsh**: Git branch management implementation
   - Candidate generation (local and remote branches)
   - Action handlers for each git operation
   - Branch name parsing and formatting

3. **git-files.zsh**: Git file management implementation
   - Tracked and untracked file listing with status
   - File operation handlers (edit, stage, diff, log, etc.)
   - Color-coded status indicators
   - File path sanitization for safe command execution

## Extending

You can create your own fzf-action sources by following this pattern:

```zsh
# 1. Generate candidates
function my-source-get-candidates() {
    # Return newline-separated list of items
    echo "item1"
    echo "item2"
}

# 2. Define action functions
function my-source-action1() {
    local selected="$1"
    # Do something with selected item
}

function my-source-action2() {
    local selected="$1"
    # Do something else
}

# 3. Create main function
function my-source-menu() {
    local candidates=$(my-source-get-candidates)

    local -a actions=(
        my-source-action1
        my-source-action2
    )

    local -a action_descriptions=(
        "First action (Default)"
        "Second action"
    )

    fzf-action-core "$candidates" \
        "$(printf "%s\n" "${actions[@]}")" \
        "$(printf "%s\n" "${action_descriptions[@]}")" \
        1  # Default action index
}

# 4. Register as ZLE widget (optional)
zle -N my-source-menu
```

## Comparison with zaw

| Feature          | fzf-action | zaw           |
| ---------------- | ---------- | ------------- |
| Search engine    | fzf        | filter-select |
| Action selection | TAB key    | TAB key       |
| Performance      | Fast (fzf) | Good          |
| Preview support  | Yes (fzf)  | Limited       |
| Extensibility    | Easy       | Moderate      |

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Credits

- Inspired by [zaw](https://github.com/zsh-users/zaw)
- Powered by [fzf](https://github.com/junegunn/fzf)
