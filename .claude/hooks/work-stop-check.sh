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
