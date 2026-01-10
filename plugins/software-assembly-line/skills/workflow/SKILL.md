---
name: workflow
description: Generate a complete Effect Cluster workflow with activities, schemas, and tests. Supports standard, durable (checkpointed), and saga (compensating) workflow patterns.
---

# Workflow Skill

Generate a complete Effect Cluster workflow with activities, schemas, and tests.

## Usage

```
/sal:workflow <WorkflowName> [--activities <ACTIVITY_LIST>] [--durable] [--saga]
```

## Examples

```bash
# Generate workflow with interactive activity prompts
/sal:workflow OrderProcessing

# Generate with specified activities
/sal:workflow OrderProcessing --activities "validateOrder,chargePayment,sendConfirmation"

# Generate durable workflow (survives restarts)
/sal:workflow OrderProcessing --durable

# Generate saga pattern (with compensation)
/sal:workflow OrderProcessing --saga
```

## Arguments

| Argument | Required | Description |
|----------|----------|-------------|
| `WorkflowName` | Yes | PascalCase workflow name |
| `--activities` | No | Comma-separated activity names |
| `--durable` | No | Generate durable workflow with checkpoints |
| `--saga` | No | Generate saga pattern with compensation activities |

## What This Skill Generates

### 1. Workflow Definition (`packages/cluster`)

**Workflow** - `src/workflows/{WorkflowName}.ts`
```typescript
import { Workflow } from "@effect/cluster"
import { Effect, Schema } from "effect"
import * as Activities from "./activities/{workflowName}"
import { {WorkflowName}Input, {WorkflowName}Output } from "./schemas/{workflowName}"

export const {WorkflowName} = Workflow.make({
  name: "{WorkflowName}",
  input: {WorkflowName}Input,
  output: {WorkflowName}Output,
  execute: (input) => Effect.gen(function*() {
    // Step 1: Validate
    const validated = yield* Activities.validate(input)

    // Step 2: Process
    const result = yield* Activities.process(validated)

    // Step 3: Complete
    yield* Activities.complete(result)

    return { success: true, result }
  }),
})
```

**Durable Workflow** (if `--durable`)
```typescript
export const {WorkflowName} = Workflow.make({
  name: "{WorkflowName}",
  input: {WorkflowName}Input,
  output: {WorkflowName}Output,
  execute: (input) => Effect.gen(function*() {
    // Checkpoint after each step for durability
    const validated = yield* Workflow.checkpoint(
      "validate",
      Activities.validate(input)
    )

    const result = yield* Workflow.checkpoint(
      "process",
      Activities.process(validated)
    )

    yield* Workflow.checkpoint(
      "complete",
      Activities.complete(result)
    )

    return { success: true, result }
  }),
})
```

**Saga Workflow** (if `--saga`)
```typescript
export const {WorkflowName} = Workflow.make({
  name: "{WorkflowName}",
  input: {WorkflowName}Input,
  output: {WorkflowName}Output,
  execute: (input) => Effect.gen(function*() {
    // Saga with compensation on failure
    yield* Workflow.saga({
      steps: [
        {
          execute: () => Activities.reserveInventory(input),
          compensate: () => Activities.releaseInventory(input),
        },
        {
          execute: () => Activities.chargePayment(input),
          compensate: () => Activities.refundPayment(input),
        },
        {
          execute: () => Activities.shipOrder(input),
          compensate: () => Activities.cancelShipment(input),
        },
      ],
    })

    return { success: true }
  }),
})
```

### 2. Activities (`packages/cluster`)

**Activities** - `src/workflows/activities/{workflowName}.ts`
```typescript
import { Activity } from "@effect/cluster"
import { Effect } from "effect"

export const validate = Activity.make({
  name: "{workflowName}.validate",
  execute: (input: ValidateInput) => Effect.gen(function*() {
    // Validation logic
    return { valid: true, data: input }
  }),
})

export const process = Activity.make({
  name: "{workflowName}.process",
  execute: (input: ProcessInput) => Effect.gen(function*() {
    // Processing logic
    return { processed: true, result: input }
  }),
})

export const complete = Activity.make({
  name: "{workflowName}.complete",
  execute: (input: CompleteInput) => Effect.gen(function*() {
    // Completion logic (notifications, cleanup, etc.)
    return Effect.void
  }),
})
```

### 3. Schemas (`packages/cluster`)

**Schemas** - `src/workflows/schemas/{workflowName}.ts`
```typescript
import { Schema } from "effect"

// Workflow input/output
export const {WorkflowName}Input = Schema.Struct({
  // Define input fields
  id: Schema.String,
  // ...
})

export const {WorkflowName}Output = Schema.Struct({
  success: Schema.Boolean,
  result: Schema.optional(Schema.Unknown),
  error: Schema.optional(Schema.String),
})

// Activity schemas
export const ValidateInput = Schema.Struct({ ... })
export const ValidateOutput = Schema.Struct({ ... })

export const ProcessInput = Schema.Struct({ ... })
export const ProcessOutput = Schema.Struct({ ... })

// Type exports
export type {WorkflowName}Input = Schema.Schema.Type<typeof {WorkflowName}Input>
export type {WorkflowName}Output = Schema.Schema.Type<typeof {WorkflowName}Output>
```

### 4. Registration (`packages/cluster`)

**Worker Registration** - Update `src/workers/index.ts`
```typescript
import { {WorkflowName} } from "../workflows/{WorkflowName}"
import * as {WorkflowName}Activities from "../workflows/activities/{workflowName}"

export const workflows = [
  // ... existing
  {WorkflowName},
]

export const activities = [
  // ... existing
  ...Object.values({WorkflowName}Activities),
]
```

### 5. Client Helper (`packages/api` or trigger location)

**Client** - `src/workflows/{workflowName}.client.ts`
```typescript
import { WorkflowClient } from "@effect/cluster"
import { {WorkflowName}Input, {WorkflowName}Output } from "@fm/cluster/workflows/schemas/{workflowName}"

export const start{WorkflowName} = (input: {WorkflowName}Input) =>
  Effect.gen(function*() {
    const client = yield* WorkflowClient
    const handle = yield* client.start({WorkflowName}, input)
    return handle
  })

export const await{WorkflowName} = (handle: WorkflowHandle) =>
  Effect.gen(function*() {
    const result = yield* handle.result
    return result
  })
```

### 6. Tests (`packages/cluster`)

**Tests** - `test/workflows/{workflowName}.test.ts`
```typescript
import { it } from "@effect/vitest"
import { Effect } from "effect"
import { {WorkflowName} } from "../../src/workflows/{WorkflowName}"
import { TestWorkflowRuntime } from "../utils/test-runtime"

describe("{WorkflowName}", () => {
  it.effect("completes successfully with valid input", () =>
    Effect.gen(function*() {
      const runtime = yield* TestWorkflowRuntime
      const result = yield* runtime.run({WorkflowName}, {
        id: "test-1",
        // ... input
      })

      expect(result.success).toBe(true)
    })
  )

  it.effect("handles errors gracefully", () =>
    Effect.gen(function*() {
      // Error case testing
    })
  )
})
```

## Generation Order

```
1. schemas     → Input/output type definitions
2. activities  → Individual activity implementations
3. workflow    → Main workflow orchestration
4. worker      → Worker registration
5. client      → API client helper
6. tests       → Workflow and activity tests
```

## Output

```markdown
## Workflow Complete: OrderProcessing

### Files Created (8)

**Cluster (packages/cluster)**
- [x] src/workflows/schemas/orderProcessing.ts
- [x] src/workflows/activities/orderProcessing.ts
- [x] src/workflows/OrderProcessing.ts
- [x] src/workers/index.ts (updated)
- [x] test/workflows/orderProcessing.test.ts

**API (packages/api)**
- [x] src/workflows/orderProcessing.client.ts

### Activities Generated
1. `validateOrder` - Validates order data
2. `chargePayment` - Processes payment
3. `sendConfirmation` - Sends confirmation email

### Workflow Type
- [x] Standard workflow
- [ ] Durable (use --durable)
- [ ] Saga pattern (use --saga)

### Verification
- [x] Types check
- [x] Tests pass (6 new tests)

### Next Steps
1. Implement activity logic
2. Add error handling for each activity
3. Configure retry policies
4. Test with cluster runtime
```

## Workflow Patterns

### Standard
Simple sequential execution. Good for:
- Quick operations
- Non-critical flows
- Development/testing

### Durable (`--durable`)
Checkpointed execution that survives restarts. Good for:
- Long-running workflows
- Critical business processes
- Operations that can't be repeated

### Saga (`--saga`)
Compensating transactions pattern. Good for:
- Distributed transactions
- Operations that need rollback
- Multi-service coordination

## Integration Notes

- Follows Effect Cluster patterns from project CLAUDE.md
- Activities are idempotent by default
- Schemas use Effect Schema for runtime validation
- Tests use TestWorkflowRuntime for isolated testing
- Client helpers make triggering workflows easy from API layer
