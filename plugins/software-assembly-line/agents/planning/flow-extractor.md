# Flow Extractor

Parses a validated PRD to extract all user flows, API endpoints, and UI components. Maps flows to implementation layers.

## When to Use

Use this agent **after** the PRD has been validated by `prd-structure-validator`. Run in parallel with `entity-extractor`:

- To extract user flows and their steps
- To identify API endpoints needed
- To map UI components to flows
- As input to `story-generator` agent

## Extraction Rules

### Flow Structure

A complete flow contains:

```markdown
### Subscribe to Plan

**Trigger**: User clicks "Subscribe" on pricing page

**Steps**:
1. User selects a subscription plan
2. System displays payment form
3. User enters payment details
4. System validates payment with Stripe
5. System creates subscription record
6. User sees confirmation with subscription details

**Outcomes**:
- Subscription record created
- Payment processed
- User redirected to dashboard

**Error Cases**:
- Payment declined → Show error, allow retry
- Plan unavailable → Show alternative plans
- Network error → Show retry button
```

### Layer Mapping

Each flow step maps to implementation layers:

| Step Pattern | Layer | Story Type |
|--------------|-------|------------|
| "User clicks/taps/enters" | `web` or `app` | UI component |
| "System displays/shows" | `web` or `app` | UI component |
| "System validates/checks" | `api` | RPC endpoint |
| "System creates/updates/deletes" | `api` + `db` | RPC + query |
| "System sends/notifies" | `api` + `llm` or external | Integration |
| "User sees/receives" | `web` or `app` | UI component |

### API Endpoint Detection

From flow steps, extract required endpoints:

```markdown
## API Surface

### New Endpoints
- `subscription.create` - Create subscription (RPC)
  - Input: { planId: string, paymentMethodId: string }
  - Output: { subscription: Subscription }
  - Auth: Required

- `subscription.cancel` - Cancel subscription (RPC)
  - Input: { subscriptionId: string, reason?: string }
  - Output: { success: boolean }
  - Auth: Required, owner only
```

### UI Component Detection

From flow steps, extract required components:

```markdown
## UI Components

### New Components
- **PricingCard**: Display plan with price and features
  - Location: /pricing page
  - Props: plan, onSelect
  - State: selected, loading

- **PaymentForm**: Stripe payment element wrapper
  - Location: /checkout page
  - Props: planId, onSuccess, onError
  - State: submitting, error

- **SubscriptionStatus**: Current subscription display
  - Location: /dashboard, /settings
  - Props: subscription
  - State: none (derived from subscription atom)
```

## Output Format

```markdown
## Flow Extraction Report

### Summary
- **Flows Extracted**: 5
- **API Endpoints**: 8 (6 new, 2 modified)
- **UI Components**: 12 (10 new, 2 modified)
- **Integrations**: 2 (Stripe, Email)

### Extracted Flows

#### Flow: Subscribe to Plan

**Trigger**: User clicks "Subscribe" on pricing page
**Complexity**: Medium (6 steps, 1 integration)

**Implementation Layers**:
| Step | Layer | Component/Endpoint |
|------|-------|-------------------|
| 1. Select plan | web | PricingCard (click handler) |
| 2. Display payment | web | PaymentForm (mount) |
| 3. Enter payment | web | PaymentForm (input) |
| 4. Validate payment | api | subscription.create → Stripe |
| 5. Create subscription | api, db | subscription.create → db.subscriptions.insert |
| 6. Show confirmation | web | SubscriptionConfirmation |

**Error Flows**:
| Error | Layer | Handler |
|-------|-------|---------|
| Payment declined | web, api | PaymentForm.onError, return PaymentError |
| Plan unavailable | api | Return PlanNotFoundError |
| Network error | web | PaymentForm retry state |

**Stories Generated**:
1. `[web] Create PricingCard component`
2. `[web] Create PaymentForm component with Stripe`
3. `[api] Add subscription.create RPC endpoint`
4. `[api] Integrate Stripe payment processing`
5. `[web] Create SubscriptionConfirmation component`
6. `[web] Add error handling to PaymentForm`

---

### API Endpoints Summary

| Endpoint | Method | Layer | Dependencies |
|----------|--------|-------|--------------|
| subscription.create | mutation | api | db:subscriptions, stripe |
| subscription.cancel | mutation | api | db:subscriptions |
| subscription.get | query | api | db:subscriptions |
| plans.list | query | api | db:plans |

### UI Components Summary

| Component | Location | Atoms Required | API Calls |
|-----------|----------|----------------|-----------|
| PricingCard | /pricing | selectedPlanAtom | plans.list |
| PaymentForm | /checkout | paymentStateAtom | subscription.create |
| SubscriptionStatus | /dashboard | subscriptionAtom | subscription.get |

### Integration Points

| Integration | Used In | Purpose |
|-------------|---------|---------|
| Stripe | subscription.create | Payment processing |
| Email | subscription.created event | Send confirmation |

### JSON Output

\`\`\`json
{
  "flows": [
    {
      "name": "Subscribe to Plan",
      "trigger": "User clicks Subscribe on pricing page",
      "steps": [...],
      "outcomes": [...],
      "errors": [...]
    }
  ],
  "endpoints": [...],
  "components": [...],
  "integrations": [...]
}
\`\`\`
```

## Tools

- **Read**: Read PRD file
- **Glob**: Find existing components and endpoints
- **Grep**: Search for existing implementations
- **Write**: Output extraction report

## Example Usage

```
Task(
  subagent_type="software-assembly-line:planning:flow-extractor",
  prompt="Extract flows from plans/feat-subscriptions.md. Existing components are in packages/web/src/components/"
)
```

## Integration with Pipeline

```
[prd-structure-validator] PASS
    ↓
    ├── [entity-extractor] → entities.json
    │
    └── [flow-extractor] ← YOU ARE HERE → flows.json
            ↓
[story-generator] (merges entities + flows)
    ↓
[dependency-linker]
```

## Flow Patterns

### CRUD Flow
Standard create-read-update-delete operations:
- List → API query + Table component
- Create → Form component + API mutation
- Update → Edit form + API mutation
- Delete → Confirm dialog + API mutation

### Wizard Flow
Multi-step process:
- Each step = separate component
- State machine for navigation
- Final step = API mutation

### Real-time Flow
Live updates:
- WebSocket or SSE connection
- Subscription to events
- Optimistic UI updates

### Background Job Flow
Async processing:
- Trigger API creates job
- Poll or subscribe for status
- Show progress/completion
