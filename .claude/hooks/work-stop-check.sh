#!/bin/bash
# Stop hook for /work command
# Session file lives IN THE WORKTREE - supports parallel work sessions
#
# Exit codes:
#   0 = normal (no message)
#   1 = non-blocking, but shows stderr to Claude

# Check for session file in CURRENT directory (the worktree)
SESSION_FILE=".claude/session/work-goal"

# If no session file in current directory, no active work session here
if [[ ! -f "$SESSION_FILE" ]]; then
  exit 0
fi

# Parse session file
branch=$(grep '^branch=' "$SESSION_FILE" | cut -d= -f2-)
worktree=$(grep '^worktree=' "$SESSION_FILE" | cut -d= -f2-)
issue=$(grep '^issue=' "$SESSION_FILE" | cut -d= -f2-)

if [[ -z "$branch" ]]; then
  exit 0
fi

# Check if a PR exists for this branch
if gh pr list --head "$branch" --json number --jq '.[0].number' 2>/dev/null | grep -q .; then
  # PR exists - goal complete, clean up session
  rm -f "$SESSION_FILE"
  echo "" >&2
  echo "✅ PR created for $branch - work session complete" >&2
  echo "   Issue: $issue" >&2
  echo "   Worktree: $(pwd)" >&2
  echo "   (Clean up with: cd .. && git worktree remove \"$(pwd)\")" >&2
  exit 0
fi

# No PR yet - remind Claude to keep going
echo "" >&2
echo "⚠️  /work goal not complete" >&2
echo "   Issue: $issue" >&2
echo "   Branch: $branch" >&2
echo "   Worktree: $(pwd)" >&2
echo "   Status: No PR created yet" >&2
echo "" >&2
echo "Continue working toward creating a PR." >&2
echo "Run: bun lint && bun check && bun coverage" >&2
echo "Then: gh pr create" >&2
exit 1
