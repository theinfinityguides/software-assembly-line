# Story Generator

Generates Linear user stories from extracted entities and flows. Assigns layer tags for automatic dependency ordering.

## When to Use

Use this agent **after** both `entity-extractor` and `flow-extractor` have run:

- To generate Linear-ready user stories
- To assign layer tags for dependency ordering
- To create stories with proper acceptance criteria
- As input to `dependency-linker` agent

## Story Templates

### Database Schema Story
```markdown
## [db:schema] Create {table_name} table migration

**Description**:
Create database migration for the {table_name} table.

**Fields**:
{field_table}

**Acceptance Criteria**:
- [ ] Migration file created in packages/db/migrations/
- [ ] Migration runs successfully (up and down)
- [ ] Foreign keys reference existing tables
- [ ] Indexes created for foreign keys
- [ ] drizzle-kit generate produces valid SQL

**Layer**: db:schema
**Estimate**: 1 point
```

### Database Model Story
```markdown
## [db:model] Add {ModelName} model and queries

**Description**:
Create Drizzle schema and Effect-wrapped queries for {ModelName}.

**Requirements**:
- Drizzle schema in packages/db/src/schema/{model}.ts
- Query functions in packages/db/src/queries/{model}.ts
- All queries return Effect<T, DbError>
- Relations defined for foreign keys

**Acceptance Criteria**:
- [ ] Schema file created with all fields
- [ ] Relations exported for joins
- [ ] CRUD query functions implemented
- [ ] 100% test coverage for queries
- [ ] Types exported from packages/db/models

**Layer**: db:model
**Depends on**: [db:schema] Create {table_name} table migration
**Estimate**: 2 points
```

### API Endpoint Story
```markdown
## [api] Add {endpoint_name} RPC endpoint

**Description**:
Create {endpoint_name} RPC endpoint with Effect-TS service pattern.

**Endpoint**:
- **Name**: {endpoint_name}
- **Type**: {query|mutation}
- **Input**: {input_schema}
- **Output**: {output_schema}
- **Auth**: {auth_requirements}

**Requirements**:
- RPC handler in packages/api/src/rpc/{domain}/{endpoint}.ts
- Input/output schemas with Effect Schema
- Proper error types (not generic errors)
- Service layer if business logic needed

**Acceptance Criteria**:
- [ ] Endpoint responds correctly to valid input
- [ ] Returns typed error for invalid input
- [ ] Auth enforced if required
- [ ] 100% test coverage
- [ ] Added to router

**Layer**: api
**Depends on**: {db_model_dependencies}
**Estimate**: 2 points
```

### Web Component Story
```markdown
## [web] Create {ComponentName} component

**Description**:
Create {ComponentName} React component using effect-atom for state.

**Location**: packages/web/src/components/{path}/{ComponentName}.tsx

**Props**:
{props_table}

**State (Atoms)**:
{atoms_table}

**API Calls**:
{api_calls}

**Requirements**:
- NO useState or useEffect (use effect-atom)
- TypeScript strict mode
- Proper loading/error states

**Acceptance Criteria**:
- [ ] Component renders correctly
- [ ] State managed with atoms
- [ ] API calls use RPC client
- [ ] Loading states shown
- [ ] Error states handled
- [ ] Responsive design
- [ ] 100% test coverage

**Layer**: web
**Depends on**: {api_dependencies}
**Estimate**: 3 points
```

### App Component Story
```markdown
## [app] Create {ComponentName} component

**Description**:
Create {ComponentName} React Native component for mobile app.

**Location**: packages/app/src/components/{path}/{ComponentName}.tsx

**Requirements**:
- NativeWind for styling
- effect-atom for state
- Expo-compatible APIs only

**Acceptance Criteria**:
- [ ] Component renders on iOS and Android
- [ ] State managed with atoms
- [ ] Styling works on both platforms
- [ ] 100% test coverage

**Layer**: app
**Depends on**: {api_dependencies}
**Estimate**: 3 points
```

### Integration Story
```markdown
## [api:integration] Integrate {service_name}

**Description**:
Add {service_name} integration to the API layer.

**Integration**:
- **Service**: {service_name}
- **Purpose**: {purpose}
- **API/SDK**: {api_or_sdk}

**Requirements**:
- Service class in packages/api/src/services/{ServiceName}.ts
- Effect.Service pattern
- Environment variables for credentials
- Error types for integration failures

**Acceptance Criteria**:
- [ ] Service connects to {service_name}
- [ ] Credentials loaded from environment
- [ ] Errors properly typed and handled
- [ ] Retry logic for transient failures
- [ ] 100% test coverage with mocks

**Layer**: api:integration
**Estimate**: 3 points
```

## Layer Ordering Rules

Stories are ordered by layer priority:

```
Priority 1: db:lookup    (enum tables, reference data)
Priority 2: db:schema    (table migrations)
Priority 3: db:model     (Drizzle schemas, queries)
Priority 4: api:integration (external services)
Priority 5: api          (RPC endpoints)
Priority 6: web          (web components)
Priority 7: app          (mobile components)
Priority 8: cluster      (background workers)
```

## Output Format

```markdown
## Story Generation Report

### Summary
- **Total Stories**: 15
- **By Layer**:
  - db:schema: 2
  - db:model: 2
  - api:integration: 1
  - api: 4
  - web: 5
  - app: 1

### Generated Stories

---

#### Story 1: [db:schema] Create subscriptions table migration

**Description**:
Create database migration for the subscriptions table.

**Fields**:
| Field | Type | Constraints |
|-------|------|-------------|
| id | uuid | primary key |
| userId | uuid | foreign key → users.id |
| planId | uuid | foreign key → plans.id |
| status | enum | not null |
| startedAt | timestamp | not null |
| expiresAt | timestamp | nullable |

**Acceptance Criteria**:
- [ ] Migration file created in packages/db/migrations/
- [ ] Migration runs successfully
- [ ] Foreign keys validated
- [ ] Indexes on userId, planId

**Layer**: db:schema
**Estimate**: 1 point
**Blocks**: Story 2, Story 3

---

#### Story 2: [db:model] Add Subscription model and queries
...

---

### Dependency Summary

\`\`\`
Story 1 (db:schema subscriptions)
    ↓ blocks
Story 2 (db:model Subscription)
    ↓ blocks
Story 5 (api subscription.create)
    ↓ blocks
Story 9 (web PaymentForm)
\`\`\`

### Linear Import Ready

\`\`\`json
{
  "stories": [
    {
      "title": "[db:schema] Create subscriptions table migration",
      "description": "...",
      "labels": ["db:schema", "auto-generated"],
      "estimate": 1,
      "blocks": ["story-2-id", "story-3-id"]
    }
  ]
}
\`\`\`
```

## Tools

- **Read**: Read entity and flow extraction outputs
- **Write**: Output story generation report
- **Bash**: Optionally create stories in Linear via CLI

## Example Usage

```
Task(
  subagent_type="software-assembly-line:planning:story-generator",
  prompt="Generate stories from the entity and flow extractions in plans/feat-subscriptions/. Create Linear issues in project PROJ-123"
)
```

## Integration with Pipeline

```
[entity-extractor] → entities.json
                          ↘
                    [story-generator] ← YOU ARE HERE
                          ↗         ↓
[flow-extractor] → flows.json    stories.json
                                    ↓
                            [dependency-linker]
                                    ↓
                              Linear Issues
```

## Story Sizing Guidelines

| Layer | Typical Size | Notes |
|-------|--------------|-------|
| db:schema | 1 point | Simple migration |
| db:model | 2 points | Schema + queries + tests |
| api:integration | 3 points | External service complexity |
| api | 2 points | Endpoint + tests |
| web | 3 points | Component + atoms + tests |
| app | 3 points | Cross-platform considerations |
| cluster | 3-5 points | Background job complexity |

## Handling Special Cases

### Shared Components
If component used by both web and app:
- Create in shared package
- Generate single story tagged `[shared]`
- Both web and app stories depend on it

### Existing Code Modification
If story modifies existing code:
- Tag with `[modify]` prefix
- Reference existing file in description
- Smaller estimate (usually 1-2 points)

### Spike/Research Stories
If implementation unclear:
- Create `[spike]` story first
- Spike blocks implementation stories
- Estimate spike at 2 points max
