---
name: plan
description: Transform a PRD into Linear issues with automatic layer-based dependencies
argument-hint: "<prd-path> [--project-id <ID>] [--dry-run]"
---

# Plan Command

Transform a PRD into Linear issues with automatic layer-based dependencies.

## Usage

```
/sal:plan <prd-path> [--project-id <LINEAR_PROJECT_ID>] [--dry-run]
```

## Examples

```bash
# Process PRD and create Linear issues
/sal:plan plans/feat-subscriptions.md --project-id PROJ-123

# Validate PRD and generate stories without creating issues
/sal:plan plans/feat-subscriptions.md --dry-run

# Process PRD in current directory
/sal:plan ./PRD.md
```

## Arguments

| Argument | Required | Description |
|----------|----------|-------------|
| `prd-path` | Yes | Path to the PRD markdown file |
| `--project-id` | No | Linear project ID for issue creation |
| `--dry-run` | No | Generate stories but don't create Linear issues |

## What This Command Does

This command orchestrates the PRD-to-Linear pipeline by running planning agents in sequence:

### Step 1: Validate PRD Structure

Runs `prd-structure-validator` to ensure the PRD has required sections:
- Overview
- Problem Statement
- Entities (new and modified)
- User Flows
- API Surface (if backend)
- UI Components (if frontend)
- Out of Scope

If validation fails, returns actionable feedback on what's missing.

### Step 2: Extract Entities and Flows (Parallel)

Runs in parallel:
- `entity-extractor` - Extracts database entities, fields, relationships
- `flow-extractor` - Extracts user flows, API endpoints, UI components

Both agents assign layer tags to extracted items.

### Step 3: Generate Stories

Runs `story-generator` to create Linear-ready stories from extracted data:
- Each story has a layer tag (e.g., `[db:schema]`, `[api]`, `[web]`)
- Stories include acceptance criteria
- Stories are sized (1-5 points)

### Step 4: Link Dependencies

Runs `dependency-linker` to set up blocks/blocked-by relationships:
- Automatic linking based on layer priority
- Cross-entity reference detection
- Cycle detection and warnings

### Step 5: Create Linear Issues (unless --dry-run)

If `--project-id` is provided:
- Creates issues in Linear via CLI
- Sets blocks/blocked-by relations
- Assigns to project milestone if specified

## Layer Priority

Stories are ordered by layer (lower blocks higher):

| Priority | Tag | Description |
|----------|-----|-------------|
| 1 | `db:lookup` | Enum tables, seed data |
| 2 | `db:schema` | Database migrations |
| 3 | `db:model` | Drizzle schemas, queries |
| 4 | `api:integration` | External service integrations |
| 5 | `api` | RPC endpoints |
| 6 | `web` | Web components |
| 7 | `app` | Mobile app components |
| 8 | `cluster` | Background workers |

## Output

### Dry Run Output

```markdown
## Planning Report

### PRD Validation: PASS

### Entities Extracted: 3
- Subscription (new)
- Plan (new)
- User (modified)

### Flows Extracted: 4
- Subscribe to Plan
- Cancel Subscription
- View Subscription Status
- Upgrade/Downgrade Plan

### Stories Generated: 15
- db:schema: 2
- db:model: 2
- api:integration: 1
- api: 4
- web: 5
- app: 1

### Dependency Graph
[ASCII diagram]

### Critical Path: 7 stories (12 points)

### Ready for Linear Creation
Run without --dry-run to create issues.
```

### Full Run Output

```markdown
## Planning Complete

### Linear Issues Created: 15
- PROJ-101: [db:schema] Create plans table migration
- PROJ-102: [db:schema] Create subscriptions table migration
...

### Dependencies Linked: 23 relationships

### Next Steps
1. Review issues in Linear
2. Assign issues to team members
3. Start work on unblocked issues
```

## Tips

1. **Start with a good PRD template** - Use the structure from `prd-structure-validator`
2. **Be specific about entities** - Include field names and types
3. **Document error cases in flows** - Helps generate error handling stories
4. **Use --dry-run first** - Validate before creating Linear issues
5. **Review the dependency graph** - Ensure critical path makes sense
