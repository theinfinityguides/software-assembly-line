# Review Skill

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

## What This Skill Does

### Step 1: Identify Changes

If `--pr` provided:
```bash
gh pr diff 123
```

Otherwise, diff against main:
```bash
git diff main...HEAD
```

Collect:
- Changed files
- Added files
- Deleted files
- File types affected (ts, tsx, sql, etc.)

### Step 2: Select Reviewers

Auto-detect based on changed files:

| Files Changed | Agents Selected |
|---------------|-----------------|
| `*.ts` in any package | effect-ts-patterns, type-strictness |
| `packages/web/**` | effect-atom |
| `packages/db/migrations/**` | data-integrity |
| `packages/api/**` | security-sentinel, performance-oracle |
| Any code changes | code-simplicity, pattern-recognition |

Or use `--agents all` for comprehensive review.

### Step 3: Run Reviews in Parallel

Launch all selected agents simultaneously:

```
┌─────────────────────────────────────────────────────┐
│  Parallel Review                                    │
│                                                     │
│  ┌──────────────┐  ┌──────────────┐  ┌───────────┐ │
│  │ effect-ts    │  │ type-strict  │  │ security  │ │
│  │ patterns     │  │ ness         │  │ sentinel  │ │
│  └──────────────┘  └──────────────┘  └───────────┘ │
│         ↓                 ↓                ↓        │
│  ┌──────────────┐  ┌──────────────┐  ┌───────────┐ │
│  │ effect-atom  │  │ performance  │  │ data      │ │
│  │              │  │ oracle       │  │ integrity │ │
│  └──────────────┘  └──────────────┘  └───────────┘ │
│                                                     │
│  All agents run simultaneously via Task tool        │
└─────────────────────────────────────────────────────┘
```

### Step 4: Aggregate Results

Combine findings from all agents:

```markdown
## Review Results

### Critical (must fix before merge)
1. **[type-strictness]** `as any` used in packages/api/src/service.ts:42
2. **[security-sentinel]** SQL injection risk in packages/db/src/queries.ts:18

### Warnings (should fix)
3. **[effect-ts-patterns]** Using async/await instead of Effect.gen in handler.ts:55
4. **[performance-oracle]** N+1 query pattern in getUserPosts()

### Suggestions (nice to have)
5. **[code-simplicity]** Function `processData` could be simplified
6. **[pattern-recognition]** Similar code in files A and B, consider extracting
```

### Step 5: Fix Issues (if --fix)

If `--fix` flag provided:
1. Address Critical issues first
2. Then Warnings
3. Skip Suggestions (manual review)

For each fix:
```
Fixing: [type-strictness] `as any` in service.ts:42
- Reading file context
- Determining correct type
- Applying fix
- Verifying types still check

Fixed: Changed `data as any` to `data as UserResponse`
```

### Step 6: Re-verify

After fixes:
```bash
bun test
bun check
bun lint
```

If new issues introduced, iterate.

### Step 7: Update PR (if applicable)

If reviewing a PR with `--fix`:
- Commit fixes with message: `fix: address code review feedback`
- Push to PR branch
- Add review summary as PR comment

## Output

```markdown
## Code Review Complete

### Summary
- **Files Reviewed**: 12
- **Agents Run**: 8
- **Critical Issues**: 2 (fixed)
- **Warnings**: 4 (3 fixed, 1 requires manual review)
- **Suggestions**: 3

### Issues Fixed
1. ~~[type-strictness] `as any` in service.ts:42~~ → Fixed with proper type
2. ~~[security-sentinel] SQL injection in queries.ts:18~~ → Fixed with parameterized query
3. ~~[effect-ts-patterns] async/await in handler.ts:55~~ → Converted to Effect.gen
4. ~~[performance-oracle] N+1 query~~ → Added preload

### Requires Manual Review
5. **[code-simplicity]** packages/api/src/complex-handler.ts
   - Function has 3 levels of nesting
   - Consider extracting helper functions
   - Not auto-fixed: requires architectural decision

### Suggestions (not addressed)
6. Similar code pattern could be extracted
7. Consider adding JSDoc to exported function
8. Variable name could be more descriptive

### Verification
- [x] Tests pass
- [x] Types check
- [x] Lint clean

### Next Steps
- Manual review of item #5
- Consider suggestions for future iteration
- Ready for human review when addressed
```

## Agent-Specific Output

Each agent produces structured findings:

```json
{
  "agent": "type-strictness-reviewer",
  "findings": [
    {
      "severity": "critical",
      "file": "packages/api/src/service.ts",
      "line": 42,
      "message": "`as any` type assertion found",
      "code": "const data = response as any",
      "suggestion": "Use proper type: `response as UserResponse`",
      "autoFixable": true
    }
  ]
}
```

## Integration with Orchestrator

Structured markers for parsing:

```
[SAL:REVIEW:START] {"files": 12, "agents": ["effect-ts-patterns", "type-strictness"]}
[SAL:REVIEW:AGENT:COMPLETE] {"agent": "effect-ts-patterns", "findings": 2}
[SAL:REVIEW:AGENT:COMPLETE] {"agent": "type-strictness", "findings": 1}
[SAL:REVIEW:FIXING] {"issue": 1, "total": 3}
[SAL:REVIEW:COMPLETE] {"critical": 0, "warnings": 1, "fixed": 3}
```

## Handling Edge Cases

### No Issues Found
```
## Code Review Complete

All clear! No issues found by any reviewer.

Agents run: effect-ts-patterns, type-strictness, security-sentinel, ...
Files reviewed: 12

Ready for human review and merge.
```

### Unfixable Critical Issue
```
## Review Blocked

Critical issue cannot be auto-fixed:

[security-sentinel] Hardcoded API key detected
File: packages/api/src/config.ts:5
Code: const API_KEY = "sk-live-..."

This requires manual intervention:
1. Remove the secret from code
2. Add to environment variables
3. Update .env.example
4. Consider rotating the exposed key

Run `/sal:review` again after fixing manually.
```

### Conflicting Suggestions
```
## Review Note: Conflicting Suggestions

Two agents have conflicting recommendations:

[performance-oracle] Suggests: Inline this function for performance
[code-simplicity] Suggests: Extract this into a separate function

Recommendation: Prioritize code-simplicity unless this is a hot path.
Keeping as separate function for maintainability.
```
