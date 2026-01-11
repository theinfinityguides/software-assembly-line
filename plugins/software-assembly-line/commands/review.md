---
name: review
description: Run multi-agent code review on the current branch or PR
argument-hint: "[--pr <NUMBER>] [--fix] [--agents <LIST>]"
---

# Review Command

Run multi-agent code review on the current branch or PR.

## Usage

```
/sal:review [--pr <PR_NUMBER>] [--fix] [--agents <AGENT_LIST>]
```

## Examples

```bash
# Review current branch against main
/sal:review

# Review a specific PR
/sal:review --pr 123

# Review and auto-fix issues
/sal:review --fix

# Run only specific reviewers
/sal:review --agents effect-ts-patterns,type-strictness

# Full review with all agents
/sal:review --agents all
```

## Arguments

| Argument | Required | Description |
|----------|----------|-------------|
| `--pr` | No | GitHub PR number to review |
| `--fix` | No | Automatically fix issues found |
| `--agents` | No | Comma-separated list of reviewers (default: auto-detect) |

## Available Review Agents

### Stack-Specific (Effect-TS/Bun)
| Agent | Checks |
|-------|--------|
| `effect-ts-patterns` | Effect.gen, Effect.Service, Match, Option usage |
| `type-strictness` | No @ts-expect-error, @ts-ignore, as any |
| `effect-atom` | No useState/useEffect in web package |
| `bun-runtime` | Bun usage, not tsx/node |
| `import-conventions` | .ts extensions, proper imports |
| `test-coverage` | 100% coverage, proper test patterns |

### Universal
| Agent | Checks |
|-------|--------|
| `security-sentinel` | OWASP, injection, secrets, auth |
| `performance-oracle` | N+1 queries, complexity, bottlenecks |
| `architecture-strategist` | Layer boundaries, patterns |
| `pattern-recognition` | Anti-patterns, duplication |
| `code-simplicity` | YAGNI, unnecessary complexity |
| `data-integrity` | Migrations, transactions, constraints |

## What This Command Does

### Step 1: Identify Changes

Collect changed files from PR or branch diff.

### Step 2: Select Reviewers

Auto-detect based on changed files or use specified agents.

### Step 3: Run Reviews in Parallel

Launch all selected agents simultaneously via Task tool.

### Step 4: Aggregate Results

Combine findings from all agents into:
- Critical (must fix before merge)
- Warnings (should fix)
- Suggestions (nice to have)

### Step 5: Fix Issues (if --fix)

Automatically remediate Critical and Warning issues.

### Step 6: Re-verify

Run tests, type checks, and linting after fixes.

## Output

```markdown
## Code Review Complete

### Summary
- **Files Reviewed**: 12
- **Agents Run**: 8
- **Critical Issues**: 2 (fixed)
- **Warnings**: 4 (3 fixed, 1 requires manual review)

### Issues Fixed
1. ~~[type-strictness] `as any` in service.ts:42~~ → Fixed with proper type
2. ~~[security-sentinel] SQL injection in queries.ts:18~~ → Fixed with parameterized query

### Requires Manual Review
3. **[code-simplicity]** packages/api/src/complex-handler.ts
   - Function has 3 levels of nesting
   - Consider extracting helper functions

### Verification
- [x] Tests pass
- [x] Types check
- [x] Lint clean
```

## Integration with Orchestrator

```
[SAL:REVIEW:START] {"files": 12, "agents": ["effect-ts-patterns", "type-strictness"]}
[SAL:REVIEW:AGENT:COMPLETE] {"agent": "effect-ts-patterns", "findings": 2}
[SAL:REVIEW:COMPLETE] {"critical": 0, "warnings": 1, "fixed": 3}
```
