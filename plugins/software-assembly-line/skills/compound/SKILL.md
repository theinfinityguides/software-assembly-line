---
name: compound
description: Review the current session, capture learnings, and update project documentation. Extracts Effect patterns, type error solutions, and integration patterns for future work.
---

# Compound Skill

Review the current session, capture learnings, and update project documentation.

## Usage

```
/sal:compound [--story-id <STORY_ID>] [--session] [--all]
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
| `--since` | No | Time range for --all (default: "1 day ago") |

## Philosophy

> Each unit of engineering work should make subsequent units easier—not harder.

This skill ensures that learnings from each implementation cycle feed back into the system, making future work more efficient.

## What This Skill Does

### Step 1: Gather Context

Collect information from:
- Git commits and diffs from the story/session
- PR description and review comments
- Linear story and comments
- Claude Code session transcript (if --session)
- Test files created/modified
- Error messages encountered and resolved

### Step 2: Identify Learnings

Run compound agents in parallel to extract different types of learnings:

```
┌─────────────────────────────────────────────────────┐
│  Parallel Compound Agents                           │
│                                                     │
│  ┌─────────────────┐  ┌─────────────────┐          │
│  │ effect-pattern  │  │ type-error      │          │
│  │ documenter      │  │ solution        │          │
│  │                 │  │ documenter      │          │
│  └─────────────────┘  └─────────────────┘          │
│          ↓                    ↓                     │
│  ┌─────────────────┐                               │
│  │ layer-integration│                               │
│  │ documenter       │                               │
│  └─────────────────┘                               │
└─────────────────────────────────────────────────────┘
```

### Step 3: Categorize Findings

#### Effect Patterns
Reusable Effect-TS patterns discovered:
```markdown
## Pattern: Service with Cached Dependencies

When a service needs to cache expensive computations:

\`\`\`typescript
export class CachedService extends Effect.Service<CachedService>()("CachedService", {
  effect: Effect.gen(function*() {
    const cache = yield* Cache.make({
      lookup: (key: string) => expensiveComputation(key),
      capacity: 100,
      timeToLive: Duration.minutes(5),
    })

    return {
      get: (key: string) => cache.get(key),
    }
  }),
}) {}
\`\`\`

**When to use**: API responses that are expensive to compute and change infrequently.
**Learned from**: STORY-456 subscription status caching
```

#### Type Error Solutions
Solutions to complex type errors:
```markdown
## Error: Effect service requirement not satisfied

**Error message**:
\`\`\`
Type 'Effect<A, E, R1>' is not assignable to type 'Effect<A, E, R2>'
  Type 'R1' is not assignable to type 'R2'
\`\`\`

**Root cause**: Missing layer in service composition.

**Solution**:
\`\`\`typescript
// Before (error)
const program = myEffect.pipe(Effect.provide(PartialLayer))

// After (fixed)
const program = myEffect.pipe(
  Effect.provide(Layer.merge(PartialLayer, MissingServiceLayer))
)
\`\`\`

**Learned from**: STORY-789 API integration
```

#### Integration Patterns
Cross-package integration patterns:
```markdown
## Pattern: DB → API → Web Data Flow

For features that span all layers:

1. **DB Layer** (packages/db)
   - Schema in `src/schema/entity.ts`
   - Queries in `src/queries/entity.ts`
   - Export types from `models/entity.ts`

2. **API Layer** (packages/api)
   - Import types from `@fm/db/models/entity`
   - RPC endpoints in `src/rpc/domain/entity.ts`
   - Never duplicate DB types

3. **Web Layer** (packages/web)
   - Atoms in `src/lib/atoms/entity.ts`
   - Components use `useAtomValue` for state
   - RPC calls via typed client

**Learned from**: STORY-456 subscription feature
```

### Step 4: Update Documentation

Write learnings to appropriate locations:

```
docs/solutions/
├── effect-patterns/
│   └── cached-service-pattern.md      ← New pattern
├── type-errors/
│   └── service-requirement-error.md   ← New solution
└── integrations/
    └── db-api-web-flow.md             ← New integration guide
```

### Step 5: Update CLAUDE.md (if significant)

If a learning is fundamental enough, suggest adding to CLAUDE.md:

```markdown
## Suggested CLAUDE.md Update

Add to "Effect-TS Patterns" section:

\`\`\`markdown
### Cached Services

When caching expensive computations in services:
- Use Effect's Cache with explicit TTL
- Consider cache invalidation strategy
- See docs/solutions/effect-patterns/cached-service-pattern.md
\`\`\`

Apply this update? [y/n]
```

### Step 6: Update Linear Story

Add compound summary to the completed story:

```markdown
## Implementation Notes (Auto-generated)

### Patterns Used
- Effect.Service for dependency injection
- Cache.make for response caching

### Learnings Captured
- New pattern documented: cached-service-pattern.md
- Type error solution added: service-requirement-error.md

### Future Improvements
- Consider adding cache metrics
- Could extract caching into reusable layer
```

## Output

```markdown
## Compound Complete

### Story
STORY-456: [api] Add subscription status endpoint

### Learnings Captured

#### Effect Patterns (1 new)
- **cached-service-pattern.md** - Service with cached dependencies
  Location: docs/solutions/effect-patterns/

#### Type Error Solutions (1 new)
- **service-requirement-error.md** - Missing layer in composition
  Location: docs/solutions/type-errors/

#### Integration Patterns (0 new)
- No new integration patterns identified

### Documentation Updated
- [x] docs/solutions/effect-patterns/cached-service-pattern.md
- [x] docs/solutions/type-errors/service-requirement-error.md
- [x] Linear story STORY-456 updated with notes

### CLAUDE.md Suggestions
1. Add cached service pattern to Effect-TS section
   - Run with --apply to add automatically

### Stats
- Session duration: 45 minutes
- Files changed: 8
- Tests added: 12
- Learnings captured: 2
```

## Learning Categories

### Effect Patterns
- Service composition patterns
- Error handling approaches
- Stream processing patterns
- Resource management
- Layer organization

### Type Error Solutions
- Generic constraint issues
- Service requirement mismatches
- Schema inference problems
- Union type narrowing
- Branded type usage

### Integration Patterns
- Cross-package data flow
- Shared type strategies
- Event propagation
- State synchronization
- Testing strategies

## Integration with Orchestrator

Structured markers for parsing:

```
[SAL:COMPOUND:START] {"storyId": "STORY-456", "source": "story"}
[SAL:COMPOUND:LEARNING] {"type": "effect-pattern", "name": "cached-service"}
[SAL:COMPOUND:LEARNING] {"type": "type-error", "name": "service-requirement"}
[SAL:COMPOUND:DOCS:UPDATED] {"file": "docs/solutions/effect-patterns/cached-service-pattern.md"}
[SAL:COMPOUND:COMPLETE] {"patterns": 1, "errors": 1, "integrations": 0}
```

## Handling Edge Cases

### No Learnings Found
```
## Compound Complete

No significant new learnings identified from STORY-456.

This may indicate:
- The implementation followed existing patterns (good!)
- The story was straightforward
- Learnings were already documented

Existing patterns used:
- Effect.Service (documented)
- Basic CRUD operations (documented)

No documentation updates needed.
```

### Duplicate Pattern
```
## Compound Note

Pattern "cached-service" is similar to existing:
- docs/solutions/effect-patterns/memoized-computation.md

Options:
1. Merge into existing document
2. Create as variation with link
3. Skip (already covered)

Recommendation: Merge - adding TTL-based caching section to existing doc.
```

### Session Too Short
```
## Compound Skipped

Session too short for meaningful compound analysis.
- Duration: 5 minutes
- Changes: 2 files (typo fixes)

Run /sal:compound after completing a full story implementation.
```

## Best Practices

1. **Compound after each story** - Don't let learnings accumulate
2. **Review suggestions** - Auto-generated docs may need human polish
3. **Keep patterns atomic** - One pattern per document
4. **Include context** - Link to the story that generated the learning
5. **Update CLAUDE.md sparingly** - Only fundamental patterns belong there
