# fzf-action

<!-- markdownlint-disable MD013 -->

[![Version](https://img.shields.io/badge/version-1.1.3-blue.svg)](CHANGELOG.md)

A ZSH plugin that provides zaw-like action selection menus using fzf.

> See [CHANGELOG.md](CHANGELOG.md) for version history and updates.

## Features

- **Two-stage selection workflow**: Select item → Select action
- **fzf-based interface**: Fast, intuitive fuzzy finding
- **Git branch management**: Comprehensive branch operations with menu selection
- **Git file management**: File operations with color-coded status indicators
- **Git status management**: Quick operations on changed/staged files
- **Command history**: Search and execute commands from shell history
- **Extensible**: Easy to add new sources and actions

## Available Widgets

### 🌿 Git Branches

**`fzf-action-git-branches-all`** - Browse and manage all git branches (local + remote)

- Switch branches instantly with Enter
- Merge, rebase, diff, and more with Tab menu
- Color-coded current branch indicator
- Perfect for: Quick branch switching, comparing branches, managing feature branches

**`fzf-action-git-branches`** - Browse and manage local git branches only

- Streamlined view of only local branches
- Same powerful actions as the all-branches widget
- Perfect for: Working within your local repository without remote clutter

### 📁 Git Files

**`fzf-action-git-files`** - Browse all tracked and untracked files in your repository

- View all files with git status indicators
- Edit, stage, diff, or view file history
- Color-coded status labels (modified, staged, untracked, etc.)
- Perfect for: Exploring the codebase, reviewing changes across the entire repository

### 🔍 Git Status

**`fzf-action-git-status`** (Add Mode) - Quick staging workflow for changed files

- Shows only modified/staged/untracked files
- Default action: Stage files instantly with Enter
- Quick access to add, reset, restore, and diff
- Perfect for: Rapid staging workflow, preparing commits, reviewing what changed

**`fzf-action-git-status-edit-mode`** (Edit Mode) - Review and edit changed files

- Shows only modified/staged/untracked files
- Default action: Open files in your editor with Enter
- Same operations as add mode, just editor-first
- Perfect for: Reviewing changes before staging, fixing issues found in git status

### ⏱️ Command History

**`fzf-action-command-history`** - Search and execute commands from shell history

- Browse your command history with fuzzy search
- Default action: Execute selected command immediately with Enter
- Append mode to edit commands before execution
- Configurable history limit (default: 1000 commands)
- Perfect for: Quickly reusing previous commands, finding that command you ran last week

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
   source ~/.zsh.d/plugins/fzf-action/git-status.zsh
   source ~/.zsh.d/plugins/fzf-action/command-history.zsh
   ```

3. **Add key bindings** (Required):

   These functions are ZLE widgets and can only be used via key bindings. Add the following to your `.zshrc`:

   ```zsh
   bindkey '^g^b' fzf-action-git-branches-all     # All branches (local + remote)
   bindkey '^gb' fzf-action-git-branches          # Local branches only
   bindkey '^gf' fzf-action-git-files             # Git files
   bindkey '^gs' fzf-action-git-status            # Git status (add mode)
   bindkey '^g^s' fzf-action-git-status-edit-mode # Git status (edit mode)
   bindkey '^r' fzf-action-command-history        # Command history
   ```

   You can use any key combination you prefer. The `^r` binding for command history replaces the default Ctrl-R reverse search.

## Configuration

### Command History Limit

The command history widget limits the number of history entries to improve performance. You can configure this limit:

```zsh
# Set custom history limit (default: 1000)
export FZF_ACTION_HISTORY_LIMIT=500
```

Set to a higher value if you want to search through more history, or lower if you have performance concerns.

### Command History fzf Options

The command history widget uses fzf's `--scheme=history` option by default, which provides scoring optimized for command history search. You can customize the fzf options used by the command history widget:

```zsh
# Default: --scheme=history
export FZF_ACTION_HISTORY_OPTIONS="--scheme=history"

# Add additional fzf options
export FZF_ACTION_HISTORY_OPTIONS="--scheme=history --exact"

# Use default fzf scoring instead of history-optimized scoring
export FZF_ACTION_HISTORY_OPTIONS="--scheme=default"

# Disable additional options (use only the core fzf-action options)
export FZF_ACTION_HISTORY_OPTIONS=""
```

The `--scheme=history` option tells fzf to use a scoring algorithm optimized for command history, which typically provides better results when searching through shell commands.

### Clipboard Command

The clipboard copy action uses the `FZF_ACTION_CLIP_COPY_CMD` environment variable. The plugin automatically detects and configures the appropriate clipboard command for your platform:

**Automatic Detection:**

- **macOS**: `pbcopy`
- **Linux**: Automatically detects and uses the first available:
  - `xclip -selection clipboard`
  - `xsel --clipboard --input`
  - `wl-copy` (Wayland)
  - `clip.exe` (WSL)
- **Windows** (Git Bash, MSYS2, Cygwin): `clip.exe`

**Manual Override:**

If you want to use a different command, set the variable in your `.zshrc` before loading the plugin:

```zsh
# Custom clipboard command
export FZF_ACTION_CLIP_COPY_CMD="custom-clipboard-command"
```

**Note**: On Linux, if no clipboard utility is found, you'll need to install one:

```bash
# Debian/Ubuntu
sudo apt install xclip

# Fedora/RHEL
sudo dnf install xclip

# Arch Linux
sudo pacman -S xclip
```

### Editor Configuration

The file edit action uses the `FZF_ACTION_EDITOR` environment variable with the following fallback chain:

1. `FZF_ACTION_EDITOR` - Plugin-specific editor (if set)
2. `EDITOR` - System default editor (if set)
3. `vim` - Final fallback

This allows you to use a different editor for fzf-action without changing your global `EDITOR` setting:

```zsh
# Use a specific editor for fzf-action
export FZF_ACTION_EDITOR="code"

# Or use your default editor
export EDITOR="emacs"
```

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
- **delete** - Delete the selected branch (local: `git branch -d`, remote: `git push --delete`)
- **delete force** - Force delete the selected branch (local: `git branch -D`, remote: `git push --delete`)

### Git Files

Press the key binding (e.g., `Ctrl+g f`) to display **all tracked and untracked files** in your git repository with color-coded status indicators.

**Workflow:**

1. **Select a file**: Use arrow keys or type to filter files
2. **Choose action**:
   - Press `ENTER`: Execute default action (edit file in $EDITOR)
   - Press `TAB`: Open action menu to select from available operations

**Available Actions:**

- **edit** (Default) - Edit file in your editor (uses `$FZF_ACTION_EDITOR`, `$EDITOR`, or `vim`)
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
- **copy path to clipboard** - Copy file path to clipboard
- **git rm** - Remove the file from git

### Git Status

Press the key binding (e.g., `Ctrl+g s` for add mode or `Ctrl+g Ctrl+s` for edit mode) to display **only changed, staged, and untracked files** from git status.

**Two Modes:**

- **Add Mode** (`fzf-action-git-status`): Default action is "git add" - optimized for staging workflow
- **Edit Mode** (`fzf-action-git-status-edit-mode`): Default action is "edit" - optimized for reviewing/editing workflow

**Workflow:**

1. **Select a file**: Use arrow keys or type to filter files
2. **Choose action**:
   - Press `ENTER`: Execute default action (git add or edit, depending on mode)
   - Press `TAB`: Open action menu to select from available operations

**Available Actions (Add Mode):**

- **git add** (Default) - Stage the file
- **git add -p** - Interactive staging (stage specific hunks)
- **git reset** - Unstage the file
- **git restore** - Restore working tree changes
- **edit** - Edit file in your editor
- **git diff** - Show diff for the file
- **append to edit buffer** - Insert file path into command line
- **git rm** - Remove the file from git

**Available Actions (Edit Mode):**

- **edit** (Default) - Edit file in your editor
- **git add** - Stage the file
- **git add -p** - Interactive staging (stage specific hunks)
- **git reset** - Unstage the file
- **git diff** - Show diff for the file
- **git restore** - Restore working tree changes
- **append to edit buffer** - Insert file path into command line
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

### Git status example

```zsh
# Press Ctrl+g s for add mode (or your configured key binding)
# Select a modified file
# Press ENTER to stage it (git add)
# or Press TAB and choose another action

# Or press Ctrl+g Ctrl+s for edit mode
# Select a file to review
# Press ENTER to edit it
```

### Command History

Press the key binding (e.g., `Ctrl+r`) to search through your shell command history.

**Workflow:**

1. **Select a command**: Use arrow keys or type to filter commands
2. **Choose action**:
   - Press `ENTER`: Execute the command immediately (default)
   - Press `TAB`: Open action menu to select from available operations

**Available Actions:**

- **execute command** (Default) - Run the selected command immediately
- **append to edit buffer** - Add the command to your current input for editing before execution

**Example:**

```zsh
# Press Ctrl+r (or your configured key binding)
# Type to search: "docker"
# Press ENTER to execute the command
# or Press TAB and choose "append to edit buffer" to edit it first
```

### Key binding example

```zsh
# Add to your .zshrc
bindkey '^g^b' fzf-action-git-branches-all     # Ctrl+g Ctrl+b - all branches
bindkey '^gb' fzf-action-git-branches          # Ctrl+g b - local branches only
bindkey '^gf' fzf-action-git-files             # Ctrl+g f - git files
bindkey '^gs' fzf-action-git-status            # Ctrl+g s - git status (add mode)
bindkey '^g^s' fzf-action-git-status-edit-mode # Ctrl+g Ctrl+s - git status (edit mode)
bindkey '^r' fzf-action-command-history        # Ctrl+r - command history

# Now you can press:
# - Ctrl+g Ctrl+b to open all branches menu
# - Ctrl+g b to open local branches menu
# - Ctrl+g f to open git files menu
# - Ctrl+g s to open git status menu (add mode)
# - Ctrl+g Ctrl+s to open git status menu (edit mode)
# - Ctrl+r to open command history search
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

4. **git-status.zsh**: Git status file management implementation
   - Show only changed/staged/untracked files from git status
   - Two modes: add-focused and edit-focused workflows
   - Quick staging and editing operations
   - Same color-coded status indicators as git-files

5. **command-history.zsh**: Command history management implementation
   - Browse and search shell command history
   - Execute or append commands to edit buffer
   - Configurable history limit for performance
   - Smart command extraction from formatted history output

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
