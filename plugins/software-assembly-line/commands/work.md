---
name: work
description: Pick the next unblocked story from Linear and implement it using the Ralph Wiggum loop
argument-hint: "[--project-id <ID>] [--story-id <ID>] [--continue]"
---

# Work Command

Pick the next unblocked story from Linear and implement it using the Ralph Wiggum loop.

## Usage

```
/sal:work [--project-id <LINEAR_PROJECT_ID>] [--story-id <STORY_ID>] [--continue]
```

## Examples

```bash
# Pick next unblocked story from project and implement
/sal:work --project-id PROJ-123

# Work on a specific story
/sal:work --story-id STORY-456

# Continue working on current story (after interruption)
/sal:work --continue
```

## Arguments

| Argument | Required | Description |
|----------|----------|-------------|
| `--project-id` | No* | Linear project to pull stories from |
| `--story-id` | No* | Specific story to work on |
| `--continue` | No | Resume work on current story |

*One of `--project-id` or `--story-id` required unless `--continue`.

## What This Command Does

### Step 1: Select Story

If `--story-id` provided:
- Fetch that specific story from Linear

If `--project-id` provided:
- Query Linear for unblocked stories (no pending blockers)
- Sort by priority, then by layer tag order
- Select the first (highest priority, earliest layer)

### Step 2: Create Branch & Session

```bash
git checkout -b feat/STORY-456-create-subscriptions-table

# Register work session (enables stop hook to track progress)
mkdir -p .claude/session
echo "feat/STORY-456-create-subscriptions-table" > .claude/session/work-goal
```

**IMPORTANT**: Always create the session file. The stop hook uses this to:
- Remind you to keep working if you stop without a PR
- Clean up automatically once PR is created

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
