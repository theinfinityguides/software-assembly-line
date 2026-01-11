---
name: compound
description: Review the session, capture learnings, and update project documentation
argument-hint: "[--story-id <ID>] [--session]"
---

# Compound Command

Review the current session, capture learnings, and update project documentation.

## Usage

```
/sal:compound [--story-id <STORY_ID>] [--session]
```

## Examples

```bash
# Compound learnings from current story
/sal:compound --story-id STORY-456

# Review entire session and extract learnings
/sal:compound --session

# Compound all recent completed stories
/sal:compound --all --since "3 days ago"
```

## Arguments

| Argument | Required | Description |
|----------|----------|-------------|
| `--story-id` | No | Specific story to compound from |
| `--session` | No | Review current Claude Code session |
| `--all` | No | Process all recent completed stories |

## Philosophy

> Each unit of engineering work should make subsequent units easier—not harder.

This command ensures that learnings from each implementation cycle feed back into the system.

## What This Command Does

### Step 1: Gather Context

Collect information from:
- Git commits and diffs
- PR description and review comments
- Linear story and comments
- Session transcript (if --session)
- Test files created/modified
- Error messages encountered and resolved

### Step 2: Identify Learnings

Run compound agents in parallel:
- `effect-pattern-documenter` - Capture Effect patterns
- `type-error-solution-documenter` - Document type error solutions
- `layer-integration-documenter` - Cross-package patterns

### Step 3: Categorize Findings

- **Effect Patterns**: Reusable Effect-TS patterns
- **Type Error Solutions**: Solutions to complex type errors
- **Integration Patterns**: Cross-package integration patterns

### Step 4: Update Documentation

Write learnings to:
```
docs/solutions/
├── effect-patterns/
├── type-errors/
└── integrations/
```

### Step 5: Update CLAUDE.md (if significant)

Suggest updates to project CLAUDE.md for fundamental patterns.

## Output

```markdown
## Compound Complete

### Story
STORY-456: [api] Add subscription status endpoint

### Learnings Captured

#### Effect Patterns (1 new)
- **cached-service-pattern.md** - Service with cached dependencies

#### Type Error Solutions (1 new)
- **service-requirement-error.md** - Missing layer in composition

### Documentation Updated
- [x] docs/solutions/effect-patterns/cached-service-pattern.md
- [x] docs/solutions/type-errors/service-requirement-error.md
- [x] Linear story STORY-456 updated with notes

### Stats
- Session duration: 45 minutes
- Files changed: 8
- Tests added: 12
- Learnings captured: 2
```

## Integration with Orchestrator

```
[SAL:COMPOUND:START] {"storyId": "STORY-456", "source": "story"}
[SAL:COMPOUND:LEARNING] {"type": "effect-pattern", "name": "cached-service"}
[SAL:COMPOUND:COMPLETE] {"patterns": 1, "errors": 1, "integrations": 0}
```
