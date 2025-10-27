# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.1.1] - 2025-10-27

### Fixed
- Fixed critical bug in `fzf-action-git-branches-extract-name()` that prevented all branch commands from working
- Branch name parsing now correctly removes leading spaces, asterisks, and trailing markers like " (local)" and " (remote)"
- Replaced failing zsh parameter expansion patterns with reliable sed regex patterns
- All git branch operations (switch, merge, rebase, diff, etc.) now work correctly

### Changed
- Improved code efficiency by using here-string (`<<<`) instead of `echo |` piping
- Enhanced inline comments to better explain the parsing logic

## [0.1.0] - 2024-01-XX

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
