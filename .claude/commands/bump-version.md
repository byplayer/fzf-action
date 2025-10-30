# Bump Version Workflow

<!-- markdownlint-disable MD013 -->

Perform a version bump for the fzf-action ZSH plugin. The user will provide
arguments after this command in the format:
`/bump-version <major|minor|patch> [description]`

Extract the bump type (major, minor, or patch) and optional description from the
arguments following this slash command.

## Prerequisites Check

Before starting, verify these conditions:

1. **Current branch is main:**
   - Run `git rev-parse --abbrev-ref HEAD`
   - If not on main, stop and inform the user they must be on main branch

2. **Working tree is clean:**
   - Run `git status --porcelain`
   - If there are uncommitted changes, stop and ask user to commit or stash them

3. **Bump type is valid:**
   - Check that the first argument is one of: `major`, `minor`, or `patch`
   - If invalid, stop and inform the user of the correct options

If any prerequisite fails, stop and inform the user of the issue.

## Workflow Steps

### Step 1: Calculate New Version

Read the current version from the `VERSION` file and calculate the new version:

1. Read the current version: `cat VERSION`
2. Parse the version as MAJOR.MINOR.PATCH
3. Based on the bump type:
   - `major`: Increment MAJOR, reset MINOR and PATCH to 0 (e.g., 0.1.6 → 1.0.0)
   - `minor`: Increment MINOR, reset PATCH to 0 (e.g., 0.1.6 → 0.2.0)
   - `patch`: Increment PATCH (e.g., 0.1.6 → 0.1.7)
4. Store the new version number in a variable for use in subsequent steps

### Step 2: Create Release Branch

Create and switch to a new release branch using the calculated version:

```bash
git switch -c release/v{NEW_VERSION}
```

### Step 3: Update VERSION File

Edit the `VERSION` file to contain only the new version number:

```text
{NEW_VERSION}
```

### Step 4: Update README.md Badge

Edit `README.md` line 5 to update the version badge:

```markdown
[![Version](https://img.shields.io/badge/version-{NEW_VERSION}-blue.svg)](CHANGELOG.md)
```

### Step 5: Update CHANGELOG.md

Automatically generate changelog entries from git commits since the last version:

1. **Get commit history since last version:**

   ```bash
   git log --format="%h %s%n%b" v{CURRENT_VERSION}..HEAD --no-merges
   ```

2. **Analyze commits and categorize changes:**
   - Look for conventional commit prefixes or emoji in commit subjects:
     - `✨ feat:` or `feat:` → **Added** section
     - `🐛 fix:` or `fix:` → **Fixed** section
     - `♻️ refactor:`, `⚡ perf:`, `🎨 style:` → **Changed** section
     - `📝 docs:` → **Changed** section (documentation)
     - Other commits → Decide based on commit message content
   - Extract the meaningful description from each commit
   - Include details from commit bodies when relevant (bullet points from "How does it address the issue?" section)

3. **Generate changelog entry:**
   Add a new section at the top of CHANGELOG.md (after the header, before the previous version section):

   ```markdown
   ## [{NEW_VERSION}] - {TODAY_DATE}

   ### Added

   - {feature descriptions from commits}

   ### Changed

   - {change descriptions from commits}

   ### Fixed

   - {fix descriptions from commits}
   ```

**Important:**

- Use today's date in YYYY-MM-DD format
- Only include sections (Added/Changed/Fixed) that have actual content
- Remove empty sections if no commits of that type exist
- Summarize related commits into concise bullet points
- Focus on user-facing changes, not internal refactoring details
- Use the commit message bodies to provide additional context when available

### Step 6: Commit Changes

Create a commit with this format:

```text
🔖 bump: version {NEW_VERSION}

# Why is this change needed?
Prepare release v{NEW_VERSION}{: DESCRIPTION if provided}

# How does it address the issue?
- Updates VERSION file to {NEW_VERSION}
- Updates README.md version badge
- Documents changes in CHANGELOG.md
```

Execute:

```bash
git add VERSION README.md CHANGELOG.md
git commit -m "{message as formatted above}"
```

### Step 7: Push Branch and Create PR

Push the release branch:

```bash
git push -u origin release/v{NEW_VERSION}
```

Create a pull request with:

- Title: `Release v{NEW_VERSION}`
- Body should include:
  - Summary of what's in this release
  - Link to CHANGELOG section
  - Any breaking changes or migration notes

Use the GitHub CLI:

```bash
gh pr create --title "Release v{NEW_VERSION}" --body "{formatted body}"
```

## Post-PR Instructions

After successfully creating the PR, inform the user:

1. ✅ Pull request created: {provide PR URL}
2. 📝 Next steps:
   - Review the PR to ensure all changes are correct
   - After PR is merged, create and push a git tag:

     ```bash
     git tag -s v{NEW_VERSION} -m "Release v{NEW_VERSION}"
     git push origin v{NEW_VERSION}
     ```

   - Consider creating a GitHub release from the tag

## Important Notes

- Follow the project's convention of using emoji in commit messages
  (🔖 for version bumps)
- Ensure all version references are updated consistently
- The CHANGELOG.md follows Keep a Changelog format
- Version numbers follow Semantic Versioning (semver.org)
