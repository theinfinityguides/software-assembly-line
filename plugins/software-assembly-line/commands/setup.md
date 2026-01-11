---
name: setup
description: Install SAL hooks into the current project for PR quality gates
argument-hint: "[--force]"
---

# Setup Command

Install Software Assembly Line hooks into the current project. These hooks enforce quality gates before PR creation.

## Usage

```
/sal:setup [--force]
```

## What Gets Installed

### 1. Pre-PR Hook (`.claude/hooks/pre-pr-check.sh`)

Intercepts `gh pr create` and blocks until all checks pass:
- `bun lint` - Linting must pass
- `bun check` - Type checking must pass
- `bun coverage` - Tests must pass with 100% coverage

### 2. Work Session Hook (`.claude/hooks/work-stop-check.sh`)

When `/sal:work` is active, reminds Claude to keep working if stopped without creating a PR.

### 3. Settings Configuration (`.claude/settings.json`)

Registers the hooks with Claude Code.

### 4. Gitignore Update

Adds `.claude/session/` to `.gitignore` (session state shouldn't be committed).

## Instructions

Execute these steps in order:

### Step 1: Create hooks directory

```bash
mkdir -p .claude/hooks
```

### Step 2: Create pre-PR check hook

Create `.claude/hooks/pre-pr-check.sh` with this content:

```bash
#!/bin/bash
# Pre-PR hook: Intercepts `gh pr create` and runs checks first
# Exit codes:
#   0 = allow the command
#   2 = block the command (shows error to Claude)

data=$(cat)
command=$(echo "$data" | jq -r '.tool_input.command // ""')

# Only run checks for gh pr create commands
if [[ ! "$command" =~ "gh pr create" ]]; then
  exit 0
fi

echo "Running pre-PR checks..." >&2

cd "$CLAUDE_PROJECT_DIR"

# Run lint
if ! bun lint; then
  echo "" >&2
  echo "❌ Lint failed - fix issues before creating PR" >&2
  exit 2
fi

# Run type check
if ! bun check; then
  echo "" >&2
  echo "❌ Typecheck failed - fix issues before creating PR" >&2
  exit 2
fi

# Run tests with 100% coverage
if ! bun coverage; then
  echo "" >&2
  echo "❌ Coverage failed - 100% test coverage required before creating PR" >&2
  exit 2
fi

echo "" >&2
echo "✅ All pre-PR checks passed (lint, check, coverage)" >&2
exit 0
```

Make it executable:
```bash
chmod +x .claude/hooks/pre-pr-check.sh
```

### Step 3: Create work session hook

Create `.claude/hooks/work-stop-check.sh` with this content:

```bash
#!/bin/bash
# Stop hook for /work command
# Only runs if .claude/session/work-goal exists (created by /work)
# Exit codes:
#   0 = normal (no message)
#   1 = non-blocking, but shows stderr to Claude

SESSION_FILE="$CLAUDE_PROJECT_DIR/.claude/session/work-goal"

# If no session file, /work is not active - exit silently
if [[ ! -f "$SESSION_FILE" ]]; then
  exit 0
fi

# Parse session file (format: key=value lines)
branch=$(grep '^branch=' "$SESSION_FILE" | cut -d= -f2-)
worktree=$(grep '^worktree=' "$SESSION_FILE" | cut -d= -f2-)

if [[ -z "$branch" ]]; then
  exit 0
fi

# Check if a PR exists for this branch
if gh pr list --head "$branch" --json number --jq '.[0].number' 2>/dev/null | grep -q .; then
  # PR exists - goal complete, clean up session
  rm -f "$SESSION_FILE"
  echo "" >&2
  echo "✅ PR created for $branch - work session complete" >&2
  if [[ -n "$worktree" ]]; then
    echo "   Worktree: $worktree" >&2
    echo "   (Clean up with: git worktree remove \"$worktree\")" >&2
  fi
  exit 0
fi

# No PR yet - remind Claude to keep going
echo "" >&2
echo "⚠️  /work goal not complete" >&2
echo "   Branch: $branch" >&2
if [[ -n "$worktree" ]]; then
  echo "   Worktree: $worktree" >&2
fi
echo "   Status: No PR created yet" >&2
echo "" >&2
echo "Continue working toward creating a PR." >&2
echo "Run: bun lint && bun check && bun coverage" >&2
echo "Then: gh pr create" >&2
exit 1
```

Make it executable:
```bash
chmod +x .claude/hooks/work-stop-check.sh
```

### Step 4: Update settings.json

Read the existing `.claude/settings.json` (or create if it doesn't exist).

Add or merge these hook configurations:

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "command",
            "command": "\"$CLAUDE_PROJECT_DIR\"/.claude/hooks/pre-pr-check.sh"
          }
        ]
      }
    ],
    "Stop": [
      {
        "type": "command",
        "command": "\"$CLAUDE_PROJECT_DIR\"/.claude/hooks/work-stop-check.sh"
      }
    ]
  }
}
```

**Important**: If the file already has hooks, merge them - don't overwrite existing hooks.

### Step 5: Update .gitignore

Add this line to `.gitignore` if not already present:

```
# Claude session state (runtime only)
.claude/session/
```

### Step 6: Verify installation

```bash
ls -la .claude/hooks/
cat .claude/settings.json | jq '.hooks'
```

## Output

After successful setup:

```
✅ SAL hooks installed

Hooks installed:
- .claude/hooks/pre-pr-check.sh (pre-PR quality gate)
- .claude/hooks/work-stop-check.sh (work session tracker)

Settings updated:
- .claude/settings.json (hooks registered)

Gitignore updated:
- .claude/session/ excluded

Quality gates now active:
- `gh pr create` blocked until: bun lint && bun check && bun coverage
- `/sal:work` sessions tracked until PR created
```

## Arguments

| Argument | Description |
|----------|-------------|
| `--force` | Overwrite existing hooks without prompting |
