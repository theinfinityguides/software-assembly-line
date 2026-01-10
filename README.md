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

## Usage

Agents are invoked via the Task tool:

```
Task(subagent_type="software-assembly-line:code-review:effect-ts-patterns-reviewer")
```

Or through workflows (coming soon):
- `/sal:plan` - Create implementation plan
- `/sal:review` - Multi-agent code review
- `/sal:compound` - Capture learnings

## License

MIT
