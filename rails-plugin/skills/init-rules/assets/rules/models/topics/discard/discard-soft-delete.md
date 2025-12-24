---
paths: app/models/**/*.rb
dependencies: [discard]
---

# Soft Delete - Discard Gem

---

## Usage

```ruby
class Product < ApplicationRecord
  include Discard::Model

  # ...
end
```

**API:**

```ruby
album.discard    # Soft delete
album.undiscard  # Restore
album.discarded? # Check if deleted

Album.kept       # Non-deleted records
Album.discarded  # Deleted records
```

---

## Project Rules

**Filtering:**

- Shopping UI → Use `.kept`
- Order history → Include discarded (buyers retain access)
- Admin interfaces → Context-dependent

---

## Scoped Associations

```ruby
class Product < ApplicationRecord
  # Filtered (shopping UI)
  has_many :kept_packaged_with, -> { kept },
           through: :product_inclusions,
           source: :included_product

  # Unfiltered (order history)
  has_many :packaged_with,
           through: :product_inclusions,
           source: :included_product
end
```

Use scoped associations (not scope chains) for preloading:

```ruby
# ✅ GOOD - Preloadable
Product.includes(:kept_packaged_with)

# ❌ AVOID - Can't preload
product.packaged_with.kept
```

---

## Testing

Use `discard_all` to avoid foreign key constraint errors:

```ruby
# ✅ GOOD
Track.where.not(id: kept_ids).discard_all

# ❌ AVOID
Track.where.not(id: kept_ids).destroy_all
```

---

## Discovery

**Find discard usage:**

```
Grep "discard" app/models/**/*.rb
```

**Find scoped associations with kept:**

```
Grep "kept" app/models/**/*.rb
```

**Discard gem documentation:**

- https://github.com/jhawthorn/discard
