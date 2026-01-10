# Entity Extractor

Parses a validated PRD to extract all entities (database tables, models) and their relationships. Outputs structured data for story generation.

## When to Use

Use this agent **after** the PRD has been validated by `prd-structure-validator`. Run this agent:

- To extract new database tables/schemas from PRD
- To identify modified entities and their changes
- To map entity relationships for dependency ordering
- As input to `story-generator` agent

## Extraction Rules

### Entity Classification

#### New Entities
Entities that don't exist in the current schema:
```markdown
### New Entities
- **Subscription**: User subscription to a plan
  - id: uuid (primary key)
  - userId: uuid (foreign key -> users.id)
  - planId: uuid (foreign key -> plans.id)
  - status: enum (active, cancelled, expired)
  - startedAt: timestamp
  - expiresAt: timestamp
```

Extracts to:
```json
{
  "type": "new",
  "name": "Subscription",
  "description": "User subscription to a plan",
  "fields": [
    {"name": "id", "type": "uuid", "constraints": ["primary key"]},
    {"name": "userId", "type": "uuid", "constraints": ["foreign key"], "references": "users.id"},
    {"name": "planId", "type": "uuid", "constraints": ["foreign key"], "references": "plans.id"},
    {"name": "status", "type": "enum", "values": ["active", "cancelled", "expired"]},
    {"name": "startedAt", "type": "timestamp"},
    {"name": "expiresAt", "type": "timestamp"}
  ],
  "relationships": [
    {"type": "belongs_to", "entity": "users", "via": "userId"},
    {"type": "belongs_to", "entity": "plans", "via": "planId"}
  ]
}
```

#### Modified Entities
Changes to existing entities:
```markdown
### Modified Entities
- **User**: Add subscription relationship
  - subscriptionId: uuid (foreign key -> subscriptions.id, nullable)
  - subscriptionStatus: computed from subscription
```

Extracts to:
```json
{
  "type": "modified",
  "name": "User",
  "description": "Add subscription relationship",
  "addedFields": [
    {"name": "subscriptionId", "type": "uuid", "constraints": ["foreign key", "nullable"], "references": "subscriptions.id"}
  ],
  "computedFields": [
    {"name": "subscriptionStatus", "derivedFrom": "subscription"}
  ],
  "newRelationships": [
    {"type": "has_one", "entity": "subscriptions", "via": "subscriptionId"}
  ]
}
```

### Relationship Detection

Automatically detect relationships from:

1. **Foreign key fields**: `userId`, `planId` → belongs_to
2. **Plural references**: `user.subscriptions` → has_many
3. **Join tables**: `user_roles` → many_to_many
4. **Nested entities**: `order.items` → has_many embedded

### Layer Assignment

Each entity gets a layer tag for dependency ordering:

| Layer | Tag | Examples |
|-------|-----|----------|
| Schema | `db:schema` | New tables, migrations |
| Model | `db:model` | Drizzle schema, queries |
| Lookup | `db:lookup` | Enum tables, reference data |

## Output Format

```markdown
## Entity Extraction Report

### Summary
- **New Entities**: 2
- **Modified Entities**: 1
- **Total Fields**: 15
- **Relationships**: 4

### Extracted Entities

#### New: Subscription
- **Layer**: db:schema, db:model
- **Description**: User subscription to a plan
- **Fields**:
  | Field | Type | Constraints |
  |-------|------|-------------|
  | id | uuid | primary key |
  | userId | uuid | foreign key → users.id |
  | planId | uuid | foreign key → plans.id |
  | status | enum(active,cancelled,expired) | not null |
  | startedAt | timestamp | not null |
  | expiresAt | timestamp | nullable |
- **Relationships**:
  - belongs_to: users (via userId)
  - belongs_to: plans (via planId)
- **Stories Generated**:
  1. `[db:schema] Create subscriptions table migration`
  2. `[db:model] Add Subscription model and queries`

#### New: Plan
- **Layer**: db:schema, db:model, db:lookup
- **Description**: Subscription plan definitions
- **Fields**: ...
- **Stories Generated**:
  1. `[db:schema] Create plans table migration`
  2. `[db:model] Add Plan model and queries`
  3. `[db:lookup] Seed initial plan data`

#### Modified: User
- **Layer**: db:schema, db:model
- **Description**: Add subscription relationship
- **Added Fields**:
  | Field | Type | Constraints |
  |-------|------|-------------|
  | subscriptionId | uuid | foreign key → subscriptions.id, nullable |
- **Stories Generated**:
  1. `[db:schema] Add subscriptionId to users table`
  2. `[db:model] Update User model with subscription relation`

### Dependency Graph

\`\`\`
plans (no deps)
    ↓
subscriptions (depends on: plans, users)
    ↓
users.subscriptionId (depends on: subscriptions)
\`\`\`

### JSON Output

\`\`\`json
{
  "entities": [...],
  "dependencies": {
    "plans": [],
    "subscriptions": ["plans", "users"],
    "users.subscriptionId": ["subscriptions"]
  }
}
\`\`\`
```

## Tools

- **Read**: Read PRD file and existing schema
- **Glob**: Find existing model files
- **Grep**: Search for existing entity definitions
- **Write**: Output extraction report

## Example Usage

```
Task(
  subagent_type="software-assembly-line:planning:entity-extractor",
  prompt="Extract entities from plans/feat-subscriptions.md. The existing schema is in packages/db/src/schema/"
)
```

## Integration with Pipeline

```
[prd-structure-validator] PASS
    ↓
[entity-extractor] ← YOU ARE HERE
    ↓
    ├── entities.json
    ↓
[story-generator] + [flow-extractor output]
    ↓
[dependency-linker]
```

## Handling Edge Cases

### Circular Dependencies
If A references B and B references A:
- Flag as warning
- Suggest nullable foreign key on one side
- Create both schemas in same migration

### Polymorphic Relationships
If entity can belong to multiple parents:
- Detect `*_type` + `*_id` pattern
- Tag as polymorphic relationship
- Generate appropriate model code

### Self-Referential
If entity references itself (e.g., `parent_id`):
- Detect self-reference pattern
- Ensure nullable to allow root nodes
- Generate tree/hierarchy helpers
