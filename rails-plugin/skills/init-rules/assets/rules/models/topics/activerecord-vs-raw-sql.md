---
paths: "app/models/**/*.rb"
dependencies: []
---

# ActiveRecord vs Raw SQL

When to use ORM query builder vs raw SQL.

---

## Decision Ladder

Start simple, escalate only when forced:

1. **ActiveRecord finders** → `.find`, `.find_by`, `.where`, associations
2. **ActiveRecord query builder** → `.joins`, `.select`, `.group`, calculated fields
3. **Query builder + .to_sql** → Database-native output (CSV), custom execution
4. **Raw SQL** → Database capabilities beyond ActiveRecord (window functions, CTEs)

**Rule**: Start at step 1. Only move up when current step cannot solve the problem.

---

## Only Use Raw SQL For

Database-specific features beyond ActiveRecord's abstraction:

- Window functions (ROW_NUMBER, RANK, PARTITION BY)
- Common Table Expressions (CTEs)
- Recursive queries
- Database-specific JSON/array operators

**Alternative**: Multiple ActiveRecord queries or post-processing in Ruby.

---

## The .to_sql Pattern

Build queries with ActiveRecord, extract SQL for native execution:

```ruby
# Build query with ActiveRecord
query = Order
  .joins(:customer, :line_items)
  .select("orders.id AS 'Order ID'")
  .select("customers.name AS 'Customer'")
  .select("COUNT(line_items.id) AS item_count")
  .group("orders.id")

# Extract SQL
sql = query.to_sql

# Execute via connection (respects transaction context)
results = ActiveRecord::Base.connection.execute(sql)
```

**When to use:**
- Database-native output formats (CSV export from database)
- Combining AR query building with database-native execution
- Need raw result hashes instead of ActiveRecord objects

---

## Database Functions in ActiveRecord

Use database-specific functions in `.select()` calls:

**PostgreSQL:**
```ruby
.select("to_char(created_at, 'YYYY-MM-DD') AS date")
.select("array_agg(tags.name) AS tag_list")
.select("jsonb_build_object('id', id, 'name', name) AS json_data")
```

**MySQL:**
```ruby
.select("DATE_FORMAT(created_at, '%Y-%m-%d') AS date")
.select("GROUP_CONCAT(tags.name) AS tag_list")
.select("JSON_OBJECT('id', id, 'name', name) AS json_data")
```

**SQLite:**
```ruby
.select("strftime('%Y-%m-%d', created_at) AS date")
.select("GROUP_CONCAT(tags.name, ', ') AS tag_list")
.select("first_name || ' ' || last_name AS full_name")
```

---

## Anti-Pattern: Manual SQL Heredoc

❌ **Wrong - Raw SQL when ActiveRecord works:**

```ruby
def export_orders
  <<~SQL.squish
    SELECT orders.id, customers.name
    FROM orders
    INNER JOIN customers ON customers.id = orders.customer_id
    WHERE orders.created_at > '2024-01-01'
  SQL
end
```

✅ **Right - ActiveRecord query builder:**

```ruby
def export_orders
  Order
    .joins(:customer)
    .select("orders.id", "customers.name")
    .where("orders.created_at > ?", Date.parse('2024-01-01'))
end
```

---

## When Raw SQL IS Appropriate

Only for database capabilities beyond ActiveRecord:

```ruby
# Window functions (not available in ActiveRecord)
sql = <<~SQL.squish
  SELECT
    users.id,
    ROW_NUMBER() OVER (
      PARTITION BY department_id
      ORDER BY salary DESC
    ) AS department_rank
  FROM users
SQL

results = ActiveRecord::Base.connection.execute(sql)
```

---

## Testing Implications

### ActiveRecord Queries

```ruby
# Test setup uses associations
let(:customer) { customers(:active) }
let(:order) { customer.orders.create!(total: 100) }

it "includes order in export" do
  results = export_orders.to_a
  assert_includes results.map(&:id), order.id
end
```

### Raw SQL

```ruby
# Test setup must match exact SQL structure
before do
  ActiveRecord::Base.connection.execute(
    "INSERT INTO orders (customer_id, total) VALUES (#{customer.id}, 100)"
  )
end

it "includes order in export" do
  results = ActiveRecord::Base.connection.execute(export_orders)
  assert results.any? { |r| r["customer_id"] == customer.id }
end
```

---

## Decision Tree

```
Need database-specific features (window functions, CTEs)?
├─ YES → Raw SQL (document why AR can't do this)
└─ NO → Continue

Simple find/where/association query?
├─ YES → ActiveRecord finders
└─ NO → Continue

Need formatting or calculated fields?
├─ YES → ActiveRecord .select with database functions
└─ NO → Continue

Need database-native output (CSV from DB)?
├─ YES → Query builder + .to_sql + connection.execute
└─ NO → ActiveRecord query builder (.to_a, .pluck)
```

---

## Migration: Raw SQL → ActiveRecord

**Before:**

```ruby
sql = <<~SQL.squish
  SELECT orders.id, customers.name, COUNT(line_items.id) AS item_count
  FROM orders
  INNER JOIN customers ON customers.id = orders.customer_id
  INNER JOIN line_items ON line_items.order_id = orders.id
  WHERE orders.created_at > '2024-01-01'
  GROUP BY orders.id, customers.name
SQL

ActiveRecord::Base.connection.execute(sql)
```

**After:**

```ruby
query = Order
  .joins(:customer, :line_items)
  .select("orders.id", "customers.name", "COUNT(line_items.id) AS item_count")
  .where("orders.created_at > ?", Date.parse('2024-01-01'))
  .group("orders.id", "customers.name")

# For raw results:
ActiveRecord::Base.connection.execute(query.to_sql)

# For ActiveRecord objects:
query.to_a
```

---

## Summary

**Default:** ActiveRecord query builder
**Edge case:** Raw SQL for database features beyond AR abstraction
**Golden rule:** If writing SQL in heredoc, ask "Could ActiveRecord do this?"
