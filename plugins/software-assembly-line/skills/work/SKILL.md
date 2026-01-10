---
name: work
description: Pick the next unblocked story from Linear and implement it using the Ralph Wiggum loop. Creates branch, implements until acceptance criteria met, runs tests, and creates PR.
---

# Work Skill

Pick the next unblocked story from Linear and implement it using the Ralph Wiggum loop.

## Usage

```
/sal:work [--project-id <LINEAR_PROJECT_ID>] [--story-id <STORY_ID>]
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

## What This Skill Does

### Step 1: Select Story

If `--story-id` provided:
- Fetch that specific story from Linear

If `--project-id` provided:
- Query Linear for unblocked stories (no pending blockers)
- Sort by priority, then by layer tag order
- Select the first (highest priority, earliest layer)

Display selected story:
```
Selected: STORY-456 [db:schema] Create subscriptions table migration
Priority: High | Estimate: 1 point | Blocked by: None
```

### Step 2: Create Branch

```bash
git checkout -b feat/STORY-456-create-subscriptions-table
```

Branch naming: `feat/<story-id>-<slugified-title>`

### Step 3: Understand Context

Read the story description and acceptance criteria. If story references:
- Other stories → Read their descriptions for context
- Existing code → Read relevant files
- PRD → Read the PRD document

### Step 4: Implement (Ralph Wiggum Loop)

Execute implementation in a persistent loop until all acceptance criteria are met:

```
┌─────────────────────────────────────────┐
│  Ralph Wiggum Loop                      │
│                                         │
│  1. Read acceptance criteria            │
│  2. Implement next criterion            │
│  3. Run tests                           │
│  4. If tests fail → fix and retry       │
│  5. If tests pass → check next criterion│
│  6. Repeat until all criteria met       │
│                                         │
│  Exit conditions:                       │
│  ✓ All acceptance criteria complete     │
│  ✗ Blocked by external dependency       │
│  ✗ Needs human decision                 │
│  ✗ Max iterations reached               │
└─────────────────────────────────────────┘
```

### Step 5: Verify Completion

Before creating PR, verify:
- [ ] All acceptance criteria from story are met
- [ ] Tests pass (`bun test`)
- [ ] Types check (`bun check`)
- [ ] Linting passes (`bun lint`)
- [ ] No `@ts-expect-error` or `as any` introduced

### Step 6: Create Pull Request

```bash
gh pr create \
  --title "[STORY-456] Create subscriptions table migration" \
  --body "..." \
  --draft
```

PR body includes:
- Link to Linear story
- Summary of changes
- Acceptance criteria checklist
- Test coverage summary

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

## Handling Edge Cases

### Story Has Blockers
```
Cannot work on STORY-456: blocked by STORY-455

Blockers:
- STORY-455: [db:model] Add Plan model (status: In Progress)

Options:
1. Wait for blocker to complete
2. Use --story-id to work on a different story
3. Work on the blocker first: /sal:work --story-id STORY-455
```

### Implementation Gets Stuck
If the loop exceeds max iterations or encounters an unresolvable issue:
```
Implementation blocked after 10 iterations.

Issue: Cannot resolve type error in Subscription model
Error: Property 'planId' is missing in type...

Recommendation:
- This may require human decision
- Story moved to "Needs Review" in Linear
- Branch preserved: feat/STORY-456-create-subscriptions-table

Resume with: /sal:work --continue
```

### Tests Keep Failing
```
Tests failing after 3 fix attempts.

Failing: packages/db/test/subscriptions.test.ts
Error: Expected 'active' but received 'pending'

Possible causes:
1. Test expectation is wrong
2. Implementation logic is wrong
3. Missing seed data

Recommendation:
- Review test assumptions
- Check if this is a spec ambiguity
- Consider adding to story comments for clarification
```

## Layer-Specific Behaviors

### db:schema Stories
- Generate migration with Drizzle Kit
- Verify up/down migrations work
- Check foreign key references

### db:model Stories
- Create Drizzle schema file
- Implement CRUD queries with Effect
- 100% test coverage required

### api Stories
- Create RPC endpoint with Effect.Service pattern
- Input/output schemas with Effect Schema
- Auth checks if required
- Integration tests

### web Stories
- Create React component with effect-atom
- NO useState/useEffect allowed
- Responsive design
- Component tests

### app Stories
- React Native with NativeWind
- Test on iOS and Android (if simulator available)
- Cross-platform compatibility

## Integration with Orchestrator

For automated orchestration, the skill outputs structured markers:

```
[SAL:WORK:START] {"storyId": "STORY-456", "branch": "feat/..."}
[SAL:WORK:PROGRESS] {"criterion": 1, "total": 5, "status": "complete"}
[SAL:WORK:PROGRESS] {"criterion": 2, "total": 5, "status": "in_progress"}
[SAL:WORK:COMPLETE] {"storyId": "STORY-456", "prUrl": "https://..."}
[SAL:WORK:BLOCKED] {"storyId": "STORY-456", "reason": "..."}
```

Orchestrator can parse these to track progress and trigger next steps.
