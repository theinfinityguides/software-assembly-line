---
name: scaffold
description: Generate a complete CRUD scaffold for an entity across all layers
argument-hint: "<EntityName> [--fields <SPEC>] [--belongs-to <PARENT>]"
---

# Scaffold Command

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
/sal:scaffold Subscription --fields "planId:uuid:required,status:enum(active,cancelled,expired)"

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

## What This Command Generates

### 1. Database Schema (`packages/db`)

- **Migration** - `migrations/XXXX_create_{entity}.sql`
- **Schema** - `src/schema/{entity}.ts`
- **Relations** - `src/schema/{entity}.relations.ts`
- **Queries** - `src/queries/{entity}.ts`
- **Types** - `models/{entity}.ts`
- **Tests** - `test/{entity}.test.ts`

### 2. API Layer (`packages/api`)

- **RPC Endpoints** - `src/rpc/{entity}/{entity}.rpc.ts`
- **Schemas** - `src/rpc/{entity}/{entity}.schemas.ts`
- **Router Registration** - Update `src/rpc/router.ts`
- **Tests** - `test/{entity}.test.ts`

### 3. Web Admin (`packages/web`)

- **List Page** - `src/routes/admin/{entities}/index.tsx`
- **Detail Page** - `src/routes/admin/{entities}/$id.tsx`
- **Create Page** - `src/routes/admin/{entities}/new.tsx`
- **Edit Page** - `src/routes/admin/{entities}/$id/edit.tsx`
- **Atoms** - `src/lib/atoms/{entity}.ts`

## Generation Order

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
- [x] test/subscription.test.ts

**Web (packages/web)**
- [x] src/lib/atoms/subscription.ts
- [x] src/routes/admin/subscriptions/...

### Verification
- [x] Migration runs successfully
- [x] Types check
- [x] Tests pass (24 new tests)
```

## Notes

- Follows patterns from project CLAUDE.md
- Uses Effect.Service for services
- Uses effect-atom for web state (no useState)
- 100% test coverage on generated code
- Types imported from `@fm/db/models`, never duplicated
