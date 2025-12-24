---
paths: app/models/**/*.rb
dependencies: []
---

# Association Patterns

---

## Join Model Naming

Name join models by INTENTION, not formula.

**Good names describe the relationship's meaning:**
- `ProductInclusion` (act of including products)
- `Membership` (users in organizations)
- `OrderItem` (items in order - carries quantity, price)
- `Enrollment`, `Subscription`, `Assignment`

**Bad names are formulaic:**
- `ProductProduct`, `UserOrganization`, `TaskUser`

```ruby
# GOOD - Named by intention
class Product < ApplicationRecord
  has_many :product_inclusions
  has_many :included_products, through: :product_inclusions
end

# BAD - Generic table name
class Product < ApplicationRecord
  has_and_belongs_to_many :products  # Unclear what this represents
end
```

---

## YAGNI Principle for Associations

Start simple - add only what's needed NOW.

```ruby
class Product < ApplicationRecord
  has_many :product_inclusions
  has_many :included_products, through: :product_inclusions

  # DON'T add reverse lookups unless UI/business logic requires them:
  # has_many :including_product_inclusions, foreign_key: :included_product_id
  # has_many :products_that_include_me, through: :including_product_inclusions
end
```

Add reverse associations only when actual code needs them.

---

## Scoped Associations

When you consistently need filtered associations, define scoped associations instead of chaining scopes.

```ruby
# GOOD - Scoped association
class Product < ApplicationRecord
  has_many :packaged_with, through: :product_inclusions, source: :included_product
  has_many :kept_packaged_with, -> { kept }, through: :product_inclusions, source: :included_product
end

# Usage
product.kept_packaged_with  # Shopping UI (filtered)
order_item.product.packaged_with  # Order history (all)
```

```ruby
# AVOID - Chaining scopes on associations
product.packaged_with.kept  # Works, but can't eager load
```

**When to use scoped associations:**
- Filtering soft-deleted records (`.kept`, `.discarded`)
- Status-based filtering (`.published`, `.active`)
- Any filter consistently applied across codebase

**Key advantage:** `Product.includes(:kept_packaged_with)` works (can't eager load scope chains)

---

## Discovery

**Join model examples:** `Grep "has_many.*through" app/models/**/*.rb`

**Scoped associations:** `Grep "has_many.*-> {" app/models/**/*.rb`
