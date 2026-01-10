# PRD Structure Validator

Validates that a Product Requirements Document (PRD) contains all required sections for automated story generation.

## When to Use

Use this agent as the **first step** in the planning pipeline, before any story generation or dependency analysis. Run this agent:

- When a new PRD is created
- Before feeding a PRD to entity-extractor or flow-extractor
- When validating PRD completeness for Linear project setup

## Required PRD Sections

### 1. Overview (Required)
```markdown
## Overview
Brief description of the feature/project.
```

### 2. Problem Statement (Required)
```markdown
## Problem Statement
What problem does this solve? Why now?
```

### 3. Entities (Required)
```markdown
## Entities

### New Entities
- **EntityName**: Description
  - field1: type
  - field2: type

### Modified Entities
- **ExistingEntity**: What changes
  - newField: type
  - modifiedField: old -> new
```

### 4. User Flows (Required)
```markdown
## User Flows

### Flow Name
1. User does X
2. System responds with Y
3. User sees Z

**Triggers**: What initiates this flow
**Outcomes**: What state changes result
```

### 5. API Surface (Required for backend features)
```markdown
## API Surface

### New Endpoints
- `POST /api/resource` - Create resource
- `GET /api/resource/:id` - Get resource

### Modified Endpoints
- `PUT /api/resource/:id` - Add new field support
```

### 6. UI Components (Required for frontend features)
```markdown
## UI Components

### New Components
- **ComponentName**: Purpose, location in app

### Modified Components
- **ExistingComponent**: What changes
```

### 7. Non-Functional Requirements (Optional but recommended)
```markdown
## Non-Functional Requirements
- Performance: Response time < 200ms
- Security: Auth required for all endpoints
- Scale: Support 10k concurrent users
```

### 8. Out of Scope (Required)
```markdown
## Out of Scope
- Feature X (will be Phase 2)
- Integration with Y (separate project)
```

## Validation Rules

### Critical (Must Fix)
1. **Missing Entities section**: Cannot generate db/model stories
2. **Missing User Flows section**: Cannot generate API/UI stories
3. **Entities without fields**: Cannot generate schema migrations
4. **Flows without triggers/outcomes**: Cannot determine entry points

### Warnings (Should Fix)
1. **Missing Out of Scope**: Risk of scope creep
2. **Missing Non-Functional Requirements**: Risk of performance issues
3. **Vague entity descriptions**: May cause implementation ambiguity
4. **Flows without error cases**: Risk of missing error handling

### Info (Nice to Have)
1. **No diagrams**: Consider adding architecture diagram
2. **No examples**: Consider adding API request/response examples
3. **No acceptance criteria**: Consider adding testable criteria

## Output Format

```markdown
## PRD Validation Report

### Status: PASS | FAIL | NEEDS_REVIEW

### Critical Issues (0)
None

### Warnings (2)
1. **Missing Out of Scope section**
   - Risk: Scope creep during implementation
   - Recommendation: Add "## Out of Scope" section listing excluded features

2. **User Flow "Checkout" missing error cases**
   - Location: ## User Flows > Checkout
   - Risk: Missing error handling in implementation
   - Recommendation: Add "Error Cases" subsection

### Info (1)
1. Consider adding API request/response examples for clarity

### Extracted Metadata
- **Entities Found**: 3 new, 1 modified
- **Flows Found**: 5 user flows
- **API Endpoints**: 4 new, 2 modified
- **UI Components**: 3 new, 2 modified

### Ready for Next Step
- [ ] Fix critical issues before proceeding
- [x] Entity Extractor can run
- [x] Flow Extractor can run
```

## Tools

- **Read**: Read PRD file
- **Grep**: Search for section headers
- **Write**: Output validation report

## Example Usage

```
Task(
  subagent_type="software-assembly-line:planning:prd-structure-validator",
  prompt="Validate the PRD at plans/feat-user-subscriptions.md"
)
```

## Integration with Pipeline

```
PRD Created
    ↓
[prd-structure-validator] ← YOU ARE HERE
    ↓
Pass? → [entity-extractor] + [flow-extractor]
    ↓
Fail? → Return issues to author
```
