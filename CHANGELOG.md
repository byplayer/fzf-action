# Changelog

<!-- markdownlint-configure-file { "MD024": { "siblings_only": true } } -->
<!-- markdownlint-disable MD013 -->

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.1.6] - 2025-10-30

### Added

- Automated version bump slash command (`/bump-version`)
  - Accepts major/minor/patch arguments for semantic versioning
  - Automatically calculates next version from VERSION file
  - Updates VERSION, README.md badge, and CHANGELOG.md
  - Creates release branch and pull request with proper formatting
  - Follows conventional commits and semver standards

### Fixed

- Terminal history preservation during fzf selection
  - Removed `--no-clear` flags and explicit screen clearing
  - Terminal output and command history now visible after selections
  - Improves usability by maintaining terminal context

## [0.1.5] - 2025-10-29

### Added

- Remote branch deletion support in git-branches actions
  - Delete and delete-force actions now work with both local and remote branches
  - Automatically detects remote branches and uses `git push --delete` command
  - Proper sanitization for both remote and branch names

### Fixed

- User prompts and messages now visible in ZLE widgets
  - Redirected all user-facing prompts and messages to stderr using `>&2`
  - Fixed invisible prompts in `fzf-action-git-branches-create-from` (branch name input)
  - Fixed invisible warnings in `fzf-action-git-branches-reset-hard` (confirmation prompts)
  - Fixed invisible error messages in `fzf-action-git-files-copy-path`
  - Removed unreachable `zle reset-prompt` calls after return statements
- Single Ctrl+C press now exits fzf widgets
  - Added explicit interrupt handling (exit code 130/SIGINT detection)
  - Calls `zle send-break` to immediately abort ZLE widgets
  - No longer requires pressing Ctrl+C twice to exit

## [0.1.4] - 2025-10-29

### Added

- Editor configuration support via `FZF_ACTION_EDITOR` environment variable
  - Plugin-specific editor setting without changing global `EDITOR`
  - Fallback chain: `FZF_ACTION_EDITOR` → `EDITOR` → `vim`
  - Supports editors with command-line flags (e.g., `code --wait`)

## [0.1.3] - 2025-10-28

### Added

- New git file management source (`git-files.zsh`) with 15 file operations:
  - Edit file in editor (default action)
  - Append file path to edit buffer
  - Git operations: add, add -p (interactive staging), reset, restore, checkout, rm
  - Diff operations: diff, diff --stat
  - Log operations: log, log --oneline
  - View operations: cat, less
  - Copy file path to clipboard (macOS)
- Color-coded file status indicators: modified, staged, deleted, untracked, conflict
- Smart file path extraction and sanitization for safe command execution
- Support for both tracked and untracked files

## [0.1.2] - 2025-10-27

### Changed

- Added GitHub compare/diff links to CHANGELOG for easier version comparison
- Improved documentation with clickable version references

## [0.1.1] - 2025-10-27

### Fixed

- Fixed critical bug in `fzf-action-git-branches-extract-name()` that prevented all branch commands from working
- Branch name parsing now correctly removes leading spaces, asterisks, and trailing markers like " (local)" and " (remote)"
- Replaced failing zsh parameter expansion patterns with reliable sed regex patterns
- All git branch operations (switch, merge, rebase, diff, etc.) now work correctly

### Changed

- Improved code efficiency by using here-string (`<<<`) instead of `echo |` piping
- Enhanced inline comments to better explain the parsing logic

## [0.1.0] - 2024-10-27

### Added

- Initial release of fzf-action plugin
- Git branch management with fzf-based two-stage selection
- Support for 15 git branch operations:
  - Switch (checkout)
  - Append to edit buffer
  - Merge (standard, rebase, no-ff, merge-to)
  - Reset (standard, hard)
  - Rebase (standard, interactive)
  - Create new branch from selected
  - Diff (standard, statistics)
  - Delete (standard, force)
- Security hardening for branch name handling
- Comprehensive documentation

### Security

- Branch name sanitization to prevent command injection
- Input validation for new branch names
- Confirmation prompts for destructive operations

---

[0.1.5]: https://github.com/byplayer/fzf-action/compare/v0.1.4...v0.1.5
[0.1.4]: https://github.com/byplayer/fzf-action/compare/v0.1.3...v0.1.4
[0.1.3]: https://github.com/byplayer/fzf-action/compare/v0.1.2...v0.1.3
[0.1.2]: https://github.com/byplayer/fzf-action/compare/v0.1.1...v0.1.2
[0.1.1]: https://github.com/byplayer/fzf-action/compare/v0.1.0...v0.1.1
[0.1.0]: https://github.com/byplayer/fzf-action/releases/tag/v0.1.0
