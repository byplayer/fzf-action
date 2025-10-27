# CLAUDE.md

<!-- markdownlint-disable MD013 -->

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Development Workflow

- **Git Operations**: Do NOT execute `git commit` or `git push` unless explicitly instructed by the user.
- **Markdown Formatting**: When updating markdown format documents, use the `markdown-formatting` skill to format them properly.

## Project Overview

fzf-action is a ZSH plugin that provides zaw-like action selection menus using fzf. It implements a two-stage selection workflow: first select an item (e.g., a git branch), then select an action to perform on it.

## Architecture

The plugin has a modular architecture with two key layers:

### Core Framework (fzf-action.zsh)

- **`fzf-action-core()`**: The main orchestrator that handles the two-stage selection workflow
  - Takes: candidates list, actions array, action descriptions, default action index
  - Stage 1: User selects an item via fzf (ENTER for default action, TAB to choose action)
  - Stage 2: If TAB pressed, shows action menu for user to select specific operation
  - Executes the selected action function with the selected candidate
- **`fzf-action-strip-ansi()`**: Helper to strip ANSI color codes from strings

### Implementation Layer (git-branches.zsh)

Each implementation follows this pattern:

1. **Candidate generators**: Functions that collect and format items (e.g., git branches with formatting)
2. **Action handlers**: Functions that perform operations on selected items (e.g., switch, merge, diff)
3. **Main function**: Ties everything together by calling `fzf-action-core()` with candidates and actions

**Important**: The git-branches implementation uses ZLE (Zsh Line Editor) to manipulate the command buffer. Action functions typically:

- Extract clean names from formatted display strings
- Set `BUFFER` variable with the git command
- Call `zle accept-line` to execute, or `zle reset-prompt` to cancel

## Testing

**Manual Testing Required**: This is a ZSH plugin that integrates with the shell's line editor (ZLE). There are no automated tests.

To test changes:

1. Source the modified files in an interactive ZSH session:

   ```zsh
   source fzf-action.zsh
   source git-branches.zsh
   ```

2. Run the functions interactively:
   - `fzf-action-git-branches-all` - Test with all branches
   - `fzf-action-git-branches` - Test with local branches only
3. Test both workflows:
   - ENTER key: Verify default action (switch) works
   - TAB key: Verify action menu appears and selected actions execute correctly
4. Test edge cases:
   - Remote branch checkout when local branch exists/doesn't exist
   - Branch name validation in create-from action
   - Non-git directory handling

## Code Conventions

### ZSH-Specific Patterns

- **Parameter expansion flags**: `${(@f)var}` splits on newlines into array
- **Array operations**: Use ZSH arrays with 1-based indexing
- **Pattern matching**: `${var##pattern}` removes longest match from start, `${var%% pattern}` from end
- **Avoid external commands**: Use ZSH built-ins over `echo | head/tail/sed` when possible

### Function Naming

All functions use the prefix `fzf-action-*` to avoid namespace collisions:

- `fzf-action-core()` - Core framework
- `fzf-action-git-branches-*` - Git branch specific functions
- Future sources should follow: `fzf-action-<source>-*`

### Error Handling

- Check prerequisites (fzf installed, git repository) at function entry
- Use `>&2` for error messages
- Return non-zero exit codes on errors
- For dangerous operations (reset --hard, force delete), show confirmation prompts

## Extending with New Sources

To add a new source (e.g., file picker, process list):

1. Create a new file: `<source-name>.zsh`
2. Implement the pattern:

   ```zsh
   # Generate candidates
   function fzf-action-<source>-get-candidates() { ... }

   # Define action handlers
   function fzf-action-<source>-<action>() {
       local item=$(extract-clean-name "$1")
       # Perform action
   }

   # Main entry point
   function fzf-action-<source>() {
       local candidates=$(fzf-action-<source>-get-candidates)
       local -a actions=(...)
       local -a action_descriptions=(...)
       fzf-action-core "$candidates" "$(printf "%s\n" "${actions[@]}")" \
                       "$(printf "%s\n" "${action_descriptions[@]}")" 1
   }

   # Register as ZLE widget
   zle -N fzf-action-<source>
   ```

3. Add to `fzf-action.plugin.zsh` for auto-loading

## Requirements

- ZSH (any modern version)
- fzf (for fuzzy finding)
- git (for git-branches source)
