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

# Run tests
if ! bun run test; then
  echo "" >&2
  echo "❌ Tests failed - fix issues before creating PR" >&2
  exit 2
fi

echo "" >&2
echo "✅ All pre-PR checks passed" >&2
exit 0
