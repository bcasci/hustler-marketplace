---
paths: config/database.yml, db/**/*.rb
dependencies: [sqlite]
---

# SQLite Multi-Database Setup

---

## Common Database Files

Typical SQLite multi-database setup:

- **`primary`** - Main application data (models, users, products)
- **`queue`** - Background job queue
- **`cable`** - WebSocket/real-time connections

---

## Configuration

### database.yml

```yaml
development:
  primary:
    <<: *default
    database: storage/development.sqlite3

  queue:
    <<: *default
    database: storage/development_queue.sqlite3
    migrations_paths: db/queue_migrate

  cable:
    <<: *default
    database: storage/development_cable.sqlite3
    migrations_paths: db/cable_migrate
```

---

## When to Use

**Use separate databases for:**

- Background job queues (isolate from main app)
- WebSocket/real-time connections (high connection volume)
- Cache storage (separate lifecycle)

**Don't use for:**

- Related application data (use same database with foreign keys)
- Performance optimization (SQLite is single-file optimized)

---

## Migration Paths

Each database has its own migration directory:

```
db/
├── migrate/              # Primary database
├── queue_migrate/        # Queue database
└── cable_migrate/        # Cable database
```

Run migrations:

```bash
bin/rails db:migrate                    # All databases
bin/rails db:migrate:primary           # Primary only
bin/rails db:migrate:queue             # Queue only
bin/rails db:migrate:cable             # Cable only
```

---

## Model Configuration

Specify non-primary database in model:

```ruby
class SolidQueue::Job < ApplicationRecord
  connects_to database: { writing: :queue, reading: :queue }
end
```

---

## Critical Rules

**Don't use foreign keys across databases:**
SQLite doesn't support cross-database foreign keys. Use application-level associations.

**Don't share connections:**
Each database file has independent connection pool.

---

## Discovery

**Database configuration:**

```bash
Read config/database.yml
```

**Models using non-primary:**

```bash
Grep "connects_to database:" app/models/**/*.rb
```
