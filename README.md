# fzf-menu

A ZSH plugin that provides zaw-like action selection menus using fzf.

## Features

- **Two-stage selection workflow**: Select item → Select action
- **fzf-based interface**: Fast, intuitive fuzzy finding
- **Git branch management**: Comprehensive branch operations with menu selection
- **Extensible**: Easy to add new sources and actions

## Requirements

- ZSH
- [fzf](https://github.com/junegunn/fzf) (command-line fuzzy finder)

## Installation

1. Clone or copy this plugin to your ZSH plugins directory:

   ```bash
   # If you're using this as part of .zsh.d
   # The plugin should be in: ~/.zsh.d/plugins/fzf-menu/
   ```

2. Load the plugin in your `.zshrc` or ZSH configuration:

   **Option A: Auto-loading (Recommended)**

   ```zsh
   # Simply source the plugin file - it will auto-load all components
   source ~/.zsh.d/plugins/fzf-menu/fzf-menu.plugin.zsh
   ```

   **Option B: Manual loading**

   ```zsh
   source ~/.zsh.d/plugins/fzf-menu/fzf-menu.zsh
   source ~/.zsh.d/plugins/fzf-menu/git-branches.zsh
   ```

3. (Optional) Add key binding for quick access:

   ```zsh
   bindkey '^gr' fzf-menu-git-branches-all  # All branches (local + remote)
   bindkey '^gb' fzf-menu-git-branches       # Local branches only
   ```

## Usage

### Git Branches (All)

Run the command:

```zsh
fzf-menu-git-branches-all
```

This displays **all local and remote branches** in your git repository.

### Git Branches (Local Only)

Run the command:

```zsh
fzf-menu-git-branches
```

This displays **local branches only** in your git repository.

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

### Branch Display

- Current branch is highlighted in **bold yellow** with an asterisk (\*)
- Local branches are marked with `(local)`
- Remote branches are shown as `<remote>/<branch>` and marked with `(remote)` (only in `fzf-menu-git-branches-all`)
  - Example: `origin/main (remote)`, `upstream/develop (remote)`

## Examples

### Quick switch (all branches)

```zsh
# Run the command
fzf-menu-git-branches-all

# Type to filter: "feat"
# Press ENTER to switch to the branch
```

### Quick switch (local branches only)

```zsh
# Run the command
fzf-menu-git-branches

# Type to filter: "feat"
# Press ENTER to switch to the branch
```

### Select action

```zsh
# Run the command (works with both functions)
fzf-menu-git-branches-all
# or
fzf-menu-git-branches

# Select a branch
# Press TAB
# Choose "diff" from action menu
```

### Key binding example

```zsh
# Add to your .zshrc
bindkey '^g^b' fzf-menu-git-branches-all  # Ctrl+g Ctrl+b - all branches
bindkey '^gb' fzf-menu-git-branches       # Ctrl+g b - local branches only

# Now you can press:
# - Ctrl+g Ctrl+b to open all branches menu
# - Ctrl+g b to open local branches menu
```

## Architecture

The plugin consists of two main components:

1. **fzf-menu.zsh**: Core framework for creating fzf-based action menus
   - `fzf-menu-core()`: Main function that handles the two-stage selection
   - Reusable for creating other menu sources

2. **git-branches.zsh**: Git branch management implementation
   - Candidate generation (local and remote branches)
   - Action handlers for each git operation
   - Branch name parsing and formatting

## Extending

You can create your own fzf-menu sources by following this pattern:

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

    fzf-menu-core "$candidates" \
        "$(printf "%s\n" "${actions[@]}")" \
        "$(printf "%s\n" "${action_descriptions[@]}")" \
        1  # Default action index
}

# 4. Register as ZLE widget (optional)
zle -N my-source-menu
```

## Comparison with zaw

| Feature          | fzf-menu   | zaw           |
| ---------------- | ---------- | ------------- |
| Search engine    | fzf        | filter-select |
| Action selection | TAB key    | TAB key       |
| Performance      | Fast (fzf) | Good          |
| Preview support  | Yes (fzf)  | Limited       |
| Extensibility    | Easy       | Moderate      |

## License

MIT

## Credits

- Inspired by [zaw](https://github.com/zsh-users/zaw)
- Powered by [fzf](https://github.com/junegunn/fzf)
