---
name: work
description: Pick the next unblocked story from Linear and implement it using the Ralph Wiggum loop
argument-hint: "[--project-id <ID>] [--story-id <ID>] [--continue]"
---

# Work Command

Pick the next unblocked story from Linear and implement it using the Ralph Wiggum loop.

## ⚠️ MANDATORY REQUIREMENTS

Before proceeding with ANY work, you MUST:

1. **Set Linear status to "In Progress"** - Do this IMMEDIATELY after selecting the story
2. **Create a git WORKTREE** - NOT a branch. Use `git worktree add`, NOT `git checkout -b`
3. **Work ONLY in the worktree directory** - Never work in the main repo directory

**FAILURE TO FOLLOW THESE REQUIREMENTS IS UNACCEPTABLE.**

## Usage

```
/sal:work [project-name] [--issue <ISSUE_ID>] [--continue]
```

## Examples

```bash
# Start work - will prompt for project if not specified
/sal:work

# Work on issues in a specific project
/sal:work "My Project"

# Work on a specific issue
/sal:work --issue INF-123

# Continue working on current story (after interruption)
/sal:work --continue
```

## Arguments

| Argument | Required | Description |
|----------|----------|-------------|
| `project-name` | No | Linear project name (will prompt if not provided) |
| `--issue` | No | Specific issue ID to work on |
| `--continue` | No | Resume work on current story |

## What This Command Does

### Step 1: Select Issue & Set In Progress

**If `--issue` provided:**
- Use Linear MCP/CLI to fetch that specific issue

**If `--continue` provided:**
- Read the session file at `.claude/session/work-goal` to get the current branch/worktree
- Resume work in that worktree

**Otherwise (project name provided or prompt for it):**

1. **Get the project name:**
   - If provided as argument, use it
   - If NOT provided, **ASK THE USER**: "Which Linear project should I work from?"

2. **Query Linear for available issues:**
   ```bash
   # Use Linear MCP or CLI to list issues ready for work
   # Filter: status is "Todo" or "Backlog" or "Ready for Dev"
   # Filter: not blocked by other incomplete issues
   ```

3. **Present the available issues to the user:**
   - Show issue ID, title, priority, and any labels
   - Ask: "Which issue would you like to work on?"
   - Let the user select from the list

4. **Once an issue is selected, IMMEDIATELY update Linear status:**
   ```bash
   # Using Linear MCP or CLI - set status to "In Progress"
   linear issue update <ISSUE_ID> --status "In Progress"
   ```

   This signals to the team that work has started.

### Step 2: Create Worktree & Session

## ⚠️ CRITICAL: YOU MUST USE A WORKTREE

**DO NOT just create a branch with `git checkout -b`. You MUST create a worktree.**

This is NON-NEGOTIABLE. Every time. No exceptions.

**IMPORTANT**: All work must be done in a git worktree, not the main working directory.

```bash
# Get repo info
REPO_ROOT=$(git rev-parse --show-toplevel)
REPO_NAME=$(basename "$REPO_ROOT")
BRANCH="feat/STORY-456-create-subscriptions-table"
BRANCH_SLUG=$(echo "$BRANCH" | sed 's/[^a-zA-Z0-9]/-/g')
WORKTREE_PATH="${REPO_ROOT}/../${REPO_NAME}--${BRANCH_SLUG}"

# Create branch and worktree (as sibling to main repo)
git worktree add -b "$BRANCH" "$WORKTREE_PATH"

# Register work session BEFORE changing directory
mkdir -p "$REPO_ROOT/.claude/session"
cat > "$REPO_ROOT/.claude/session/work-goal" << EOF
branch=$BRANCH
worktree=$WORKTREE_PATH
EOF

# Change to worktree - ALL WORK HAPPENS HERE
cd "$WORKTREE_PATH"

# VERIFY you are in the worktree (not the main repo)
pwd  # Should show the worktree path, NOT the main repo
git worktree list  # Confirm worktree exists
```

**VERIFY BEFORE PROCEEDING**: Run `pwd` and confirm you are in the worktree directory (the sibling directory), NOT the main repo.

The worktree is created as a sibling directory:
```
~/dev/
├── my-repo/                                    # Main (stays on main branch)
└── my-repo--feat-STORY-456-create-subscrip...  # Worktree (your work here)
```

**Why worktrees?**
- Main directory stays clean on main/master
- Can work on multiple stories in parallel
- Isolated changes prevent accidental commits to wrong branch

### Step 3: Understand Context

Read the story description and acceptance criteria. If story references:
- Other stories → Read their descriptions for context
- Existing code → Read relevant files
- PRD → Read the PRD document

### Step 4: Implement (Ralph Wiggum Loop)

Execute implementation in a persistent loop until all acceptance criteria are met:

```
1. Read acceptance criteria
2. Implement next criterion
3. Write tests for the criterion (100% coverage required)
4. Run tests and coverage check
5. If tests fail or coverage < 100% → fix and retry
6. If tests pass with 100% coverage → check next criterion
7. Repeat until all criteria met

Exit conditions:
✓ All acceptance criteria complete with 100% test coverage
✗ Blocked by external dependency
✗ Needs human decision
✗ Max iterations reached
```

**Coverage standard**: 100% test coverage is required. Run `bun coverage` from the repo root to check.

### Step 5: Verify Completion

Before creating PR, run these commands from the repo root:

```bash
bun lint      # Linting passes
bun check     # Types check
bun coverage  # Tests pass with 100% coverage
```

Verify:
- [ ] All acceptance criteria from story are met
- [ ] `bun lint` passes
- [ ] `bun check` passes
- [ ] `bun coverage` passes with 100% coverage
- [ ] No `@ts-expect-error` or `as any` introduced

### Step 6: Create Pull Request

```bash
gh pr create --title "[STORY-456] Create subscriptions table migration" --body "..." --draft
```

### Step 7: Update Linear

- Move story to "In Review" state
- Add PR link to story
- Add comment with implementation notes

## Output

```markdown
## Work Complete

### Story
STORY-456: [db:schema] Create subscriptions table migration

### Worktree
../my-repo--feat-STORY-456-create-subscriptions-table

### Branch
feat/STORY-456-create-subscriptions-table

### Changes
- Created migration: packages/db/migrations/0042_create_subscriptions.sql
- Added schema: packages/db/src/schema/subscriptions.ts
- Added tests: packages/db/test/subscriptions.test.ts

### Verification
- [x] Tests pass (12 tests, 100% coverage)
- [x] Types check
- [x] Lint clean
- [x] All acceptance criteria met

### Pull Request
https://github.com/org/repo/pull/123

### Next Steps
Run `/sal:review` to trigger multi-agent code review.
```

## Integration with Orchestrator

Structured markers for parsing:

```
[SAL:WORK:START] {"storyId": "STORY-456", "branch": "feat/..."}
[SAL:WORK:PROGRESS] {"criterion": 1, "total": 5, "status": "complete"}
[SAL:WORK:COMPLETE] {"storyId": "STORY-456", "prUrl": "https://..."}
[SAL:WORK:BLOCKED] {"storyId": "STORY-456", "reason": "..."}
```
