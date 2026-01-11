---
name: workflow
description: Generate a complete Effect Cluster workflow with activities and schemas
argument-hint: "<WorkflowName> [--activities <LIST>] [--durable] [--saga]"
---

# Workflow Command

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

## What This Command Generates

### 1. Workflow Definition (`packages/cluster`)

- **Workflow** - `src/workflows/{WorkflowName}.ts`
- **Activities** - `src/workflows/activities/{workflowName}.ts`
- **Schemas** - `src/workflows/schemas/{workflowName}.ts`
- **Worker Registration** - Update `src/workers/index.ts`
- **Tests** - `test/workflows/{workflowName}.test.ts`

### 2. Client Helper (`packages/api`)

- **Client** - `src/workflows/{workflowName}.client.ts`

## Workflow Patterns

### Standard
Simple sequential execution:
```typescript
export const OrderProcessing = Workflow.make({
  name: "OrderProcessing",
  execute: (input) => Effect.gen(function*() {
    const validated = yield* Activities.validate(input)
    const result = yield* Activities.process(validated)
    yield* Activities.complete(result)
    return { success: true, result }
  }),
})
```

### Durable (`--durable`)
Checkpointed execution that survives restarts:
```typescript
const validated = yield* Workflow.checkpoint(
  "validate",
  Activities.validate(input)
)
```

### Saga (`--saga`)
Compensating transactions pattern:
```typescript
yield* Workflow.saga({
  steps: [
    {
      execute: () => Activities.reserveInventory(input),
      compensate: () => Activities.releaseInventory(input),
    },
    // ...
  ],
})
```

## Output

```markdown
## Workflow Complete: OrderProcessing

### Files Created (6)

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
```

## Notes

- Follows Effect Cluster patterns from project CLAUDE.md
- Activities are idempotent by default
- Schemas use Effect Schema for runtime validation
- Tests use TestWorkflowRuntime for isolated testing
