---
paths: db/**/*.{rb,sql}
dependencies: []
---

# Database Views and Triggers

---

## When to Use

### Views

**Use for:**

- Complex queries slow as model scopes (multiple joins, aggregations)
- Denormalized read-optimized data structures
- Hiding complexity from application code

**Don't use for:**

- Simple filtering (use model scopes or indexes)
- Data that changes frequently (views don't cache, they query)

**Example use case:**

- Dashboard aggregation query across 5 tables
- Report that joins users + orders + products with calculations

---

### Triggers

**Use for:**

- Automatic data synchronization between tables
- Maintaining denormalized data
- Audit logging at database level

**Don't use for:**

- Business logic (use model callbacks or commands)
- Complex validation (use model validations)
- Cross-database operations (not all databases support)

**Example use case:**

- Keep search index in sync with source tables
- Update aggregate counts when child records change
- Maintain audit trail automatically

---

## File Structure

```
db/
├── migrate/           # Migrations create/drop objects
├── triggers/name/     # Trigger SQL files
└── views/name/        # View SQL files
```

Each folder contains versioned SQL:

- `v01.up.sql` - Create object
- `v01.down.sql` - Drop object

---

## Critical Rules

### DROP Order Matters

**CRITICAL:** Drop dependent objects before dropping base objects.

```
1. Drop triggers first (depend on tables/views)
2. Drop views second (depend on tables)
3. Drop tables last
```

---

### Naming Conventions

- **Format:** Lowercase with underscores
- **Versions:** `v01`, `v02`, `v03` (not v1, v2, v3)
- **Trigger suffixes:** `_ai` (after insert), `_au` (after update), `_ad` (after delete)

---

## Discovery

**SQL files:**

```bash
Glob "db/{triggers,views}/**/*.sql"
```

**Usage in migrations:**

```bash
Grep "Database::(View|Trigger)Helper" db/migrate/**/*.rb
```

**Helpers (if project has custom helpers):**

```bash
Read lib/database/*_helper.rb
```
