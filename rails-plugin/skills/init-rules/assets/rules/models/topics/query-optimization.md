---
paths: "app/models/**/*.rb"
dependencies: []
---

# Query Optimization Patterns

## ActiveRecord vs ActiveModel

### Identifying Model Types

**ActiveRecord** (backed by database table):

```ruby
class Album < ApplicationRecord
  # Has database table 'albums'
  # Can use: scopes, indexes, eager loading, counter caches
  # N+1 queries are a real concern
  # Optimize with SQL: joins, includes, select subqueries
end
```

**ActiveModel** (NO database table):

```ruby
class Genre
  include ActiveModel::Model
  # NO database table for genres
  # Wraps data from gems (acts-as-taggable-on), APIs, or config files
  # In-memory operations only
  # .all must build objects from source data (unavoidable)
  # Cannot: add indexes, eager load, or optimize "queries" (no queries exist)
end
```

**How to identify:**

```bash
# Check inheritance
grep "< ApplicationRecord" app/models/genre.rb     # ActiveRecord
grep "include ActiveModel::Model" app/models/genre.rb  # ActiveModel

# Check for table
grep "create_table :genres" db/schema.rb  # If not found → no table
```

## Query Optimization Guidelines

### ActiveRecord Models - Optimize SQL Queries

**Prevent N+1 queries with eager loading:**

```ruby
# BAD - N+1 query (1 query + N queries for organizations)
albums = Album.all
albums.each { |a| puts a.organization.name }  # Query per album

# GOOD - Eager load (2 queries total)
albums = Album.includes(:organization)
albums.each { |a| puts a.organization.name }  # No additional queries
```

**Prefer select subqueries over joins for filtering:**

```ruby
# PREFER - Subquery (cleaner, composable)
Album.where(id: published_album_ids)
Album.where(organization_id: Organization.active.select(:id))
ActsAsTaggableOn::Tagging.where(taggable_id: Album.salable.select(:id))

# AVOID - Complex joins (harder to read and maintain)
Album.joins(:organization).where(organizations: { status: 'active' })
```

**When to use joins:**
- Ordering by associated table: `.joins(:artist).order('artists.name')`
- Filtering with complex associated conditions that can't use subquery
- Counting with GROUP BY from associated table

**Use pluck for extracting simple data:**

```ruby
# Get just IDs (single query, minimal memory)
genre_ids = Genre.published.pluck(:id)

# Get multiple columns
albums.pluck(:id, :title)  # Returns [[1, "Title 1"], [2, "Title 2"]]

# Use in subqueries
Album.where(genre_id: Genre.rock.pluck(:id))
```

### ActiveModel Models - Accept In-Memory Operations

**Genre example (wraps acts-as-taggable-on tags):**

```ruby
def self.with_salable_releases
  # Step 1: Optimize the UNDERLYING query (GOOD)
  salable_genre_names = ActsAsTaggableOn::Tagging
    .where(taggable_type: 'Product', taggable_id: Album.salable.select(:id))
    .joins(:tag)
    .pluck('tags.name')
    .uniq

  # Step 2: In-memory filtering (EXPECTED - genres don't have a table)
  all.each_with_object([]) do |genre, filtered|
    has_salable = salable_genre_names.include?(genre.name)
    genre.subgenres.select! { |sg| salable_genre_names.include?(sg.name) }
    has_salable ||= genre.subgenres.any?
    filtered << genre if has_salable
  end
end
```

**Why this is correct:**
- ✅ SQL query is optimized (uses subquery, single pluck, proper join)
- ✅ `Genre.all` must build from config/tags (unavoidable - no table)
- ✅ In-memory filtering is appropriate for small taxonomy (~50 genres)
- ❌ You CANNOT "add an index" to genres (no table exists)
- ❌ You CANNOT "eager load" genres (not an ActiveRecord association)
- ❌ You CANNOT "avoid loading all genres" (they must be built from source)

## Table Ownership

**App-owned tables** (can modify schema):

```ruby
# Found in db/schema.rb with standard Rails structure
create_table "albums" do |t|
  t.string "title"
  # ...
end

# ✅ Can add: indexes, columns, counter caches
# ✅ Can optimize: query structure, eager loading
```

**Gem-owned tables** (cannot modify schema):

```ruby
# acts-as-taggable-on owns tags/taggings
# Found in db/schema.rb with gem comments
create_table "tags" do |t|  # Managed by acts-as-taggable-on
  t.string "name"
end

# ❌ Cannot add: indexes, columns (would be overwritten by gem migrations)
# ✅ Can optimize: application-level queries, caching
```

## Quick Reference

| Model Type                         | Has Table? | Can Index? | Can Eager Load? | N+1 Concerns? | Optimization Strategy                                 |
| ---------------------------------- | ---------- | ---------- | --------------- | ------------- | ----------------------------------------------------- |
| **ActiveRecord** (app-owned)       | ✅ Yes     | ✅ Yes     | ✅ Yes          | ✅ Yes        | SQL: indexes, includes, subqueries                    |
| **ActiveRecord** (gem-owned table) | ✅ Yes     | ❌ No      | ✅ Yes          | ✅ Yes        | Query-level only, can't modify schema                 |
| **ActiveModel**                    | ❌ No      | ❌ No      | ❌ No           | ❌ No         | Optimize underlying data source, accept in-memory ops |

## SQL vs Ruby Optimization Patterns

### `.distinct` vs `.uniq`

```ruby
# SQL-level deduplication (PREFER for database queries)
Album.joins(:tags).distinct.pluck(:id)
# → SELECT DISTINCT albums.id FROM albums INNER JOIN tags...
# Database removes duplicates before sending to Ruby

# Ruby-level deduplication (AVOID for AR queries)
Album.joins(:tags).pluck(:id).uniq
# → SELECT albums.id FROM albums INNER JOIN tags...
# Database sends ALL rows, Ruby filters duplicates in memory
```

**Rule**: Use `.distinct` for ActiveRecord queries. Only use `.uniq` when working with arrays already in memory.

### Subquery Patterns

```ruby
# PREFER - Subquery (clean, composable, efficient)
Album.where(organization_id: Organization.active.select(:id))
# → WHERE organization_id IN (SELECT id FROM organizations WHERE active = true)

# AVOID - Complex join (harder to read, not more efficient)
Album.joins(:organization).where(organizations: { active: true })
# → INNER JOIN organizations ON ... WHERE organizations.active = true
```

**When joins ARE better:**
- Ordering by associated table: `.joins(:artist).order('artists.name')`
- Selecting columns from both tables
- Complex WHERE clauses spanning multiple tables

## Decision Checklist

Before accepting "optimize this query" feedback, verify:

1. **Is the model ActiveRecord or ActiveModel?**
   - ActiveModel: In-memory operations are expected (Genre.all)
   - ActiveRecord: SQL optimization applies

2. **Does a database table exist?**
   - Check `db/schema.rb` for the table
   - No table = no SQL optimization possible

3. **What does the query actually do?**
   - `select(:id)` subqueries are Rails best practice
   - `.distinct` before `.pluck` is always better than `.uniq` after

4. **Is this a real bottleneck?**
   - Measure, don't guess
   - Small datasets (<1000 records) rarely need optimization
   - Focus on queries in hot paths (index actions, search)
