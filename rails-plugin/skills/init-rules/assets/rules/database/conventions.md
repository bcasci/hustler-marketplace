---
paths: "db/**/*.{rb,sql}"
dependencies: []
---

# Database Patterns

---

## Migrations

Follow Rails conventions for schema changes, indexes, and constraints.

**Run migrations:**
```bash
bin/rails db:migrate
bin/rails db:rollback
```

---

## Advanced Database Objects

For complex queries, full-text search, or automatic data synchronization:

- **Views** - See `topics/sql-objects.md`
- **Triggers** - See `topics/sql-objects.md`
- **Full-text search** - Database-specific (e.g., SQLite FTS5, Postgres FTS)

---

## Discovery

**Migrations:**
```bash
Glob "db/migrate/**/*.rb"
```

**Schema:**
```bash
Read db/schema.rb
```

**Advanced SQL objects:**
```bash
Glob "db/{triggers,views,virtual_tables}/**/*.sql"
```
