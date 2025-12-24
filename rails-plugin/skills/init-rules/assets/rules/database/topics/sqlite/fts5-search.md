---
paths: db/**/*.{rb,sql}
dependencies: [sqlite3]
---

# SQLite FTS5 Full-Text Search

---

## When to Use FTS5

**Use for:**
- Full-text search across multiple models
- Fuzzy matching and ranking
- Search result relevance scoring

**Don't use for:**
- Exact matches (use regular indexes)
- Single-column searches (use LIKE with index)

---

## File Structure

```
db/
├── migrate/YYYYMMDDHHMMSS_create_search_index.rb
└── virtual_tables/
    └── search_index/
        ├── v01.up.sql
        └── v01.down.sql
```

---

## Virtual Table Pattern

### Migration

```ruby
class CreateSearchIndex < ActiveRecord::Migration[8.0]
  def up
    Database::VirtualTableHelper.create(:search_index, version: 1)
  end

  def down
    Database::VirtualTableHelper.drop(:search_index, version: 1)
  end
end
```

### SQL File (v01.up.sql)

```sql
CREATE VIRTUAL TABLE search_index USING fts5(
  resource_type,
  name,
  description,
  artist_name,
  content='products',
  content_rowid='id',
  tokenize='porter unicode61'
);
```

### SQL File (v01.down.sql)

```sql
DROP TABLE IF EXISTS search_index;
```

---

## Triggers for Auto-Sync

FTS5 tables need triggers to stay in sync with source tables.

### Pattern

```ruby
# Migration
class CreateSearchTriggers < ActiveRecord::Migration[8.0]
  def up
    Database::TriggerHelper.create(:search_index_sync_ai, version: 1)
    Database::TriggerHelper.create(:search_index_sync_au, version: 1)
    Database::TriggerHelper.create(:search_index_sync_ad, version: 1)
  end

  def down
    Database::TriggerHelper.drop(:search_index_sync_ad, version: 1)
    Database::TriggerHelper.drop(:search_index_sync_au, version: 1)
    Database::TriggerHelper.drop(:search_index_sync_ai, version: 1)
  end
end
```

### Trigger SQL (After Insert)

```sql
-- db/triggers/search_index_sync_ai/v01.up.sql
CREATE TRIGGER search_index_sync_ai
AFTER INSERT ON products
BEGIN
  INSERT INTO search_index(rowid, resource_type, name, description, artist_name)
  VALUES (new.id, new.type, new.name, new.description, new.metadata_artist_name);
END;
```

---

## Rebuild Index

After schema changes or data corruption:

```bash
bin/rake app:search:rebuild
```

---

## Naming Conventions

**Virtual table versions:** `v01`, `v02`, `v03` (not v1, v2, v3)

**Trigger suffixes:**
- `_ai` - After Insert
- `_au` - After Update
- `_ad` - After Delete

---

## Critical Rules

### Drop Order

When dropping FTS5 tables, drop triggers FIRST:

```ruby
def down
  # 1. Drop triggers (depend on virtual table)
  Database::TriggerHelper.drop(:search_index_sync_ad, version: 1)
  Database::TriggerHelper.drop(:search_index_sync_au, version: 1)
  Database::TriggerHelper.drop(:search_index_sync_ai, version: 1)

  # 2. Drop virtual table
  Database::VirtualTableHelper.drop(:search_index, version: 1)
end
```

---

## Discovery

**Helpers API:**
```bash
Read lib/database/virtual_table_helper.rb
Read lib/database/trigger_helper.rb
```

**Existing patterns:**
```bash
Grep "VirtualTableHelper" db/migrate/**/*.rb
Glob "db/virtual_tables/**/*.sql"
Glob "db/triggers/**/*.sql"
```
