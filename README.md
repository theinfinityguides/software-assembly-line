# Software Assembly Line

A Claude Code plugin for automated software development using AI agents. Implements a structured pipeline: **Plan → Review Plan → Work → Review Code → Compound → Repeat**.

## Philosophy

> Each unit of engineering work should make subsequent units easier—not harder.

This plugin provides specialized agents for:
- **Planning**: Transform ideas into structured, implementable plans
- **Plan Review**: Catch issues in plans before coding starts
- **Code Review**: Multi-agent review with stack-specific expertise
- **Compounding**: Capture learnings to improve future work

## Stack Focus

While the patterns are generalizable, agents are optimized for:
- **Effect-TS** - Functional effect system for TypeScript
- **Bun** - Fast JavaScript runtime
- **Strict TypeScript** - Zero tolerance for type suppressions
- **effect-atom** - Reactive state management for React

## Installation

```bash
/plugin marketplace add theinfinityguides/software-assembly-line
/plugin install software-assembly-line
```

## Agents

### Planning Agents

**PRD Pipeline (run in sequence):**
| Agent | Purpose |
|-------|---------|
| `prd-structure-validator` | Validate PRD has required sections before processing |
| `entity-extractor` | Parse PRD to extract entities and relationships |
| `flow-extractor` | Parse PRD to extract user flows and API endpoints |
| `story-generator` | Generate Linear stories from entities and flows |
| `dependency-linker` | Auto-set blocks/blocked-by relations in Linear |

**Architecture Design:**
| Agent | Purpose |
|-------|---------|
| `effect-ts-architect` | Design Effect service layers and composition |
| `layer-dependency-analyzer` | Auto-generate task dependencies from architecture |
| `schema-ripple-analyzer` | Map downstream impacts of schema changes |
| `test-strategy-planner` | Plan test approach for full coverage |

### Plan Review Agents
| Agent | Purpose |
|-------|---------|
| `effect-feasibility-reviewer` | Validate plans work with Effect patterns |
| `type-complexity-assessor` | Flag plans requiring complex types |
| `monorepo-impact-reviewer` | Identify all affected packages |
| `atom-state-planner` | Plan effect-atom state structure |

### Code Review Agents

**Stack-Specific:**
| Agent | Purpose |
|-------|---------|
| `effect-ts-patterns-reviewer` | Enforce Effect-TS conventions |
| `type-strictness-reviewer` | Zero tolerance for type suppressions |
| `effect-atom-reviewer` | No useState/useEffect in React |
| `bun-runtime-reviewer` | Ensure Bun usage, not tsx/node |
| `import-conventions-reviewer` | .ts extensions, proper imports |
| `test-coverage-reviewer` | 100% coverage, proper patterns |

**Universal:**
| Agent | Purpose |
|-------|---------|
| `security-sentinel` | Security audits, OWASP compliance, vulnerability detection |
| `performance-oracle` | Bottleneck detection, N+1 queries, algorithmic complexity |
| `architecture-strategist` | Architectural compliance, design patterns |
| `pattern-recognition-specialist` | Anti-patterns, code duplication, naming conventions |
| `code-simplicity-reviewer` | YAGNI enforcement, complexity reduction |
| `data-integrity-guardian` | Migration safety, transactions, referential integrity |

### Compound Agents
| Agent | Purpose |
|-------|---------|
| `effect-pattern-documenter` | Capture Effect patterns that worked |
| `type-error-solution-documenter` | Document type error solutions |
| `layer-integration-documenter` | Cross-package integration patterns |

## Quick Start: Planning

### 1. Write a PRD

Create a PRD document with these required sections:

```markdown
# Feature Name

## Overview
Brief description of the feature.

## Problem Statement
What problem does this solve?

## Entities

### New Entities
- **Subscription**: User subscription to a plan
  - id: uuid (primary key)
  - userId: uuid (foreign key → users.id)
  - planId: uuid (foreign key → plans.id)
  - status: enum (active, cancelled, expired)

### Modified Entities
- **User**: Add subscription relationship
  - subscriptionId: uuid (nullable)

## User Flows

### Subscribe to Plan
1. User clicks "Subscribe" on pricing page
2. System displays payment form
3. User enters payment details
4. System creates subscription

**Outcomes**: Subscription created, payment processed

## Out of Scope
- Annual billing (Phase 2)
- Team subscriptions
```

### 2. Run the Planning Skill

```bash
# Validate and create Linear issues
/sal:plan plans/feat-subscriptions.md --project-id PROJ-123

# Dry run - validate and preview without creating issues
/sal:plan plans/feat-subscriptions.md --dry-run
```

### 3. What Happens

The skill runs 5 agents in sequence:

```
PRD Document
    ↓
[prd-structure-validator] ─── Validates required sections
    ↓
    ├── [entity-extractor] ─── Extracts entities (parallel)
    │
    └── [flow-extractor] ───── Extracts flows (parallel)
            ↓
    [story-generator] ──────── Generates layer-tagged stories
            ↓
    [dependency-linker] ────── Sets blocks/blocked-by in Linear
            ↓
    Linear Issues with Dependencies
```

### 4. Output

Stories are created with layer tags and automatic dependencies:

```
PROJ-101: [db:schema] Create plans table migration
PROJ-102: [db:schema] Create subscriptions table migration (blocked by 101)
PROJ-103: [db:model] Add Plan model and queries (blocked by 101)
PROJ-104: [db:model] Add Subscription model (blocked by 102, 103)
PROJ-105: [api] Add subscription.create endpoint (blocked by 104)
PROJ-106: [web] Create PaymentForm component (blocked by 105)
```

## Layer Tags

Stories are tagged by layer for automatic dependency ordering:

| Priority | Tag | Description |
|----------|-----|-------------|
| 1 | `db:lookup` | Enum tables, reference data |
| 2 | `db:schema` | Table migrations |
| 3 | `db:model` | Drizzle schemas, queries |
| 4 | `api:integration` | External service integrations |
| 5 | `api` | RPC endpoints |
| 6 | `web` | Web components |
| 7 | `app` | Mobile app components |
| 8 | `cluster` | Background workers |

Lower priority layers automatically block higher priority layers for the same entity.

## Skills

| Skill | Purpose |
|-------|---------|
| `/sal:plan` | Transform PRD into Linear issues with dependencies |
| `/sal:review` | Multi-agent code review (coming soon) |
| `/sal:compound` | Capture learnings from session (coming soon) |

## Usage: Agents Directly

Agents can also be invoked directly via the Task tool:

```
Task(subagent_type="software-assembly-line:code-review:effect-ts-patterns-reviewer")
```

## License

MIT
