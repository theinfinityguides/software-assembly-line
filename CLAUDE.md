# InfinityGuides Software Assembly Line

A Claude Code plugin providing AI agents for automated software development pipelines.

## Philosophy

> Each unit of engineering work should make subsequent units easier—not harder.

This plugin implements the **compound engineering** approach:
- **80% planning/review, 20% execution**
- Knowledge compounds over time through documentation
- Agents learn from failures and improve

## Target Stack

Agents are optimized for:
- **Effect-TS** - Functional effect system
- **Bun** - JavaScript runtime
- **TypeScript** - With zero tolerance for type suppressions
- **effect-atom** - React state management
- **Drizzle ORM** - Database layer

## Agent Categories

### Planning Agents (`agents/planning/`)

| Agent | Purpose |
|-------|---------|
| `effect-ts-architect` | Design Effect service layers and composition |
| `layer-dependency-analyzer` | Auto-generate task dependencies from stories |
| `schema-ripple-analyzer` | Map downstream impacts of schema changes |
| `test-strategy-planner` | Plan test approach for 100% coverage |

### Plan Review Agents (`agents/plan-review/`)

| Agent | Purpose |
|-------|---------|
| `effect-feasibility-reviewer` | Validate plans work with Effect patterns |
| `type-complexity-assessor` | Flag plans requiring complex types |
| `monorepo-impact-reviewer` | Identify all affected packages |
| `atom-state-planner` | Plan effect-atom state structure |

### Code Review Agents (`agents/code-review/`)

| Agent | Purpose |
|-------|---------|
| `effect-ts-patterns-reviewer` | Enforce Effect-TS conventions |
| `type-strictness-reviewer` | Zero tolerance for type suppressions |
| `effect-atom-reviewer` | No useState/useEffect in React |
| `bun-runtime-reviewer` | Ensure Bun usage, not tsx/node |
| `import-conventions-reviewer` | .ts extensions, proper imports |
| `test-coverage-reviewer` | 100% coverage, proper patterns |

### Compound Agents (`agents/compound/`)

| Agent | Purpose |
|-------|---------|
| `effect-pattern-documenter` | Capture Effect patterns that worked |
| `type-error-solution-documenter` | Document type error solutions |
| `layer-integration-documenter` | Cross-package integration patterns |

## Core Rules Enforced

### Effect-TS Rules

```typescript
// ✅ REQUIRED
Effect.gen(function*() { ... })     // Not async/await
Effect.Service<T>()("Name", {...})  // Not Context.Tag
Match.value(x).pipe(...)            // Not switch
Option<T>                           // Not T | null
Effect.fail(new TypedError())       // Not throw
```

### Type Strictness Rules

```typescript
// ❌ ABSOLUTELY FORBIDDEN
// @ts-expect-error
// @ts-ignore
as any
as unknown as T
function foo(x: any)
```

### React State Rules (Web Package)

```typescript
// ❌ FORBIDDEN in @fm/web
useState, useEffect, useReducer

// ✅ REQUIRED
Atom.make(), useAtomValue(), useAtomSet()
```

### Runtime Rules

```bash
# ❌ FORBIDDEN
tsx, node, ts-node, npm, yarn, pnpm

# ✅ REQUIRED
bun, bun run, bun install
```

## Workflow Integration

### Plan → Review Plan → Work → Compound

```
1. PLAN
   └── effect-ts-architect designs services
   └── layer-dependency-analyzer orders tasks
   └── schema-ripple-analyzer maps impacts
   └── test-strategy-planner plans coverage

2. REVIEW PLAN
   └── effect-feasibility-reviewer validates
   └── type-complexity-assessor checks types
   └── monorepo-impact-reviewer checks packages
   └── atom-state-planner plans UI state

3. WORK (Ralph Wiggum Loop)
   └── Implementation happens here

4. CODE REVIEW
   └── effect-ts-patterns-reviewer
   └── type-strictness-reviewer
   └── effect-atom-reviewer
   └── bun-runtime-reviewer
   └── import-conventions-reviewer
   └── test-coverage-reviewer

5. COMPOUND
   └── effect-pattern-documenter
   └── type-error-solution-documenter
   └── layer-integration-documenter
```

## Documentation Output

Agents create documentation in:

```
docs/solutions/
├── effect-patterns/      # Reusable Effect patterns
├── type-errors/          # Type error solutions
└── integrations/         # Cross-package patterns
```

## Usage

### Via Task Tool

```typescript
Task(
  subagent_type="infinityguides-sal:code-review:effect-ts-patterns-reviewer",
  prompt="Review the changes in packages/api/src/services/"
)
```

### Parallel Review

```typescript
// Run all code reviewers in parallel
Task(subagent_type="infinityguides-sal:code-review:effect-ts-patterns-reviewer", ...)
Task(subagent_type="infinityguides-sal:code-review:type-strictness-reviewer", ...)
Task(subagent_type="infinityguides-sal:code-review:effect-atom-reviewer", ...)
// ... all in same message
```

## Adding New Agents

1. Create markdown file in appropriate `agents/` subdirectory
2. Follow existing agent structure:
   - `# Title`
   - `## When to Use`
   - `## Instructions`
   - `### Rules/Patterns`
   - `### Output Format`
   - `## Tools`

3. Add to README.md agent table
4. Test with sample code

## License

MIT
