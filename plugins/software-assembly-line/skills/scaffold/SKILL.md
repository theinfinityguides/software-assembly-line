# Scaffold Skill

Generate a complete CRUD scaffold for an entity across all layers: database, API, and admin UI.

## Usage

```
/sal:scaffold <EntityName> [--fields <FIELD_SPEC>] [--belongs-to <PARENT>] [--skip <LAYERS>]
```

## Examples

```bash
# Generate full scaffold with interactive field prompts
/sal:scaffold Subscription

# Generate with field specification
/sal:scaffold Subscription --fields "planId:uuid:required,status:enum(active,cancelled,expired),expiresAt:timestamp"

# Generate with relationship
/sal:scaffold Subscription --belongs-to User --belongs-to Plan

# Skip certain layers
/sal:scaffold Subscription --skip web,app
```

## Arguments

| Argument | Required | Description |
|----------|----------|-------------|
| `EntityName` | Yes | PascalCase entity name (e.g., `Subscription`) |
| `--fields` | No | Field specification (interactive if omitted) |
| `--belongs-to` | No | Parent entity for foreign key relationship |
| `--skip` | No | Layers to skip: `db`, `api`, `web`, `app` |

## Field Specification Format

```
fieldName:type[:modifiers]

Types: uuid, string, text, int, float, boolean, timestamp, date, json, enum(val1,val2,...)
Modifiers: required, unique, index, default=value
```

Examples:
```
name:string:required
email:string:required:unique
status:enum(active,inactive):required:default=active
metadata:json
createdAt:timestamp:required:default=now
```

## What This Skill Generates

### 1. Database Schema (`packages/db`)

**Migration** - `migrations/XXXX_create_{entity}.sql`
```sql
CREATE TABLE {entities} (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  -- fields from spec
  created_at TIMESTAMP NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMP NOT NULL DEFAULT NOW()
);
```

**Schema** - `src/schema/{entity}.ts`
```typescript
import { pgTable, uuid, timestamp, ... } from "drizzle-orm/pg-core"

export const {entities} = pgTable("{entities}", {
  id: uuid("id").primaryKey().defaultRandom(),
  // fields
  createdAt: timestamp("created_at").notNull().defaultNow(),
  updatedAt: timestamp("updated_at").notNull().defaultNow(),
})
```

**Relations** - `src/schema/{entity}.relations.ts`
```typescript
import { relations } from "drizzle-orm"

export const {entities}Relations = relations({entities}, ({ one, many }) => ({
  // relationships
}))
```

**Queries** - `src/queries/{entity}.ts`
```typescript
export const {entity}Queries = {
  findById: (id: string) => Effect.gen(function*() { ... }),
  findAll: (options?: FindOptions) => Effect.gen(function*() { ... }),
  create: (data: Create{Entity}) => Effect.gen(function*() { ... }),
  update: (id: string, data: Update{Entity}) => Effect.gen(function*() { ... }),
  delete: (id: string) => Effect.gen(function*() { ... }),
}
```

**Types** - `models/{entity}.ts`
```typescript
export type {Entity} = typeof {entities}.$inferSelect
export type Create{Entity} = typeof {entities}.$inferInsert
export type Update{Entity} = Partial<Create{Entity}>
```

**Tests** - `test/{entity}.test.ts`

### 2. API Layer (`packages/api`)

**RPC Endpoints** - `src/rpc/{entity}/{entity}.rpc.ts`
```typescript
export const {entity}Rpc = {
  list: (input: List{Entity}Input) => Effect.gen(function*() { ... }),
  get: (input: { id: string }) => Effect.gen(function*() { ... }),
  create: (input: Create{Entity}Input) => Effect.gen(function*() { ... }),
  update: (input: Update{Entity}Input) => Effect.gen(function*() { ... }),
  delete: (input: { id: string }) => Effect.gen(function*() { ... }),
}
```

**Schemas** - `src/rpc/{entity}/{entity}.schemas.ts`
```typescript
import { Schema } from "effect"

export const {Entity}Schema = Schema.Struct({ ... })
export const Create{Entity}Input = Schema.Struct({ ... })
export const Update{Entity}Input = Schema.Struct({ ... })
export const List{Entity}Input = Schema.Struct({
  limit: Schema.optional(Schema.Number),
  offset: Schema.optional(Schema.Number),
  // filters
})
```

**Router Registration** - Update `src/rpc/router.ts`

**Tests** - `test/{entity}.test.ts`

### 3. Web Admin (`packages/web`)

**List Page** - `src/routes/admin/{entities}/index.tsx`
- Table with pagination
- Search/filter
- Actions: view, edit, delete

**Detail Page** - `src/routes/admin/{entities}/$id.tsx`
- Display all fields
- Edit button
- Delete with confirmation

**Create Page** - `src/routes/admin/{entities}/new.tsx`
- Form with validation
- Submit creates entity
- Redirect to list

**Edit Page** - `src/routes/admin/{entities}/$id/edit.tsx`
- Pre-filled form
- Submit updates entity
- Redirect to detail

**Atoms** - `src/lib/atoms/{entity}.ts`
```typescript
export const {entities}ListAtom = Atom.family((params: ListParams) => ...)
export const {entity}Atom = Atom.family((id: string) => ...)
export const {entity}MutationAtom = Atom.make({ ... })
```

## Generation Order

The skill generates files in dependency order:

```
1. db:schema    → Migration file
2. db:model     → Schema, relations, queries, types
3. db:test      → Database tests
4. api:schema   → RPC schemas
5. api:rpc      → RPC endpoints
6. api:router   → Router registration
7. api:test     → API tests
8. web:atoms    → State atoms
9. web:pages    → Admin CRUD pages
```

## Output

```markdown
## Scaffold Complete: Subscription

### Files Created (12)

**Database (packages/db)**
- [x] migrations/0043_create_subscriptions.sql
- [x] src/schema/subscription.ts
- [x] src/schema/subscription.relations.ts
- [x] src/queries/subscription.ts
- [x] models/subscription.ts
- [x] test/subscription.test.ts

**API (packages/api)**
- [x] src/rpc/subscription/subscription.schemas.ts
- [x] src/rpc/subscription/subscription.rpc.ts
- [x] src/rpc/router.ts (updated)
- [x] test/subscription.test.ts

**Web (packages/web)**
- [x] src/lib/atoms/subscription.ts
- [x] src/routes/admin/subscriptions/index.tsx
- [x] src/routes/admin/subscriptions/$id.tsx
- [x] src/routes/admin/subscriptions/new.tsx
- [x] src/routes/admin/subscriptions/$id/edit.tsx

### Verification
- [x] Migration runs successfully
- [x] Types check
- [x] Tests pass (24 new tests)

### Next Steps
1. Review generated code
2. Add business logic to RPC endpoints
3. Customize admin UI as needed
4. Run: `bun --filter @fm/db exec drizzle-kit generate`
```

## Customization Points

The scaffold generates working CRUD, but you'll typically customize:

1. **Queries**: Add complex filters, joins, aggregations
2. **RPC**: Add authorization, business validation
3. **Admin UI**: Add custom columns, actions, styling
4. **Relationships**: Add cascade deletes, eager loading

## Integration Notes

- Follows patterns from project CLAUDE.md
- Uses Effect.Service for services
- Uses effect-atom for web state (no useState)
- 100% test coverage on generated code
- Types imported from `@fm/db/models`, never duplicated
