---
paths: "app/models/**/*.rb"
dependencies: []
---

# Data Patterns

---

## Scopes

**Always use lambda syntax:**

```ruby
scope :published, -> { where(listing_state: "published") }
scope :by_status, ->(status) { where(status: status) }
```

**Scope composition:**

```ruby
scope :salable, -> { published.where("release_date <= ?", Time.current) }
```

**Find scope examples:** `Grep "scope :" app/models/`

---

## Enums and Scopes

Rails enums auto-generate scopes. **Don't duplicate them.**

```ruby
enum :status, { draft: 'draft', ready: 'ready' }

# ❌ BAD - Duplicates auto-generated scope
scope :pending, -> { where(status: 'ready') }  # Use Task.ready

# ✅ GOOD - Combines enum values
scope :actionable, -> { where(status: %w[ready in_progress]) }

# ✅ GOOD - Adds logic beyond enum
scope :overdue, -> { where('due_at < ?', Time.current).where.not(status: 'done') }
```

**Convention**: Only create scopes combining enum values or adding filters.

---

## JSONB Metadata

Use `store_accessor` for structured JSONB access:

```ruby
class Product < ApplicationRecord
  store_accessor :metadata, :artist_name, :release_date

  # Access with: product.metadata_artist_name = "value"
end
```

---

## Validations

**Standard patterns:**

```ruby
validates :title, presence: true, length: { maximum: 255 }
validates :slug, uniqueness: { scope: :organization_id }
validates :price_cents, numericality: { greater_than_or_equal_to: 0 }
```

**Custom validations:**

```ruby
validate :has_items, on: :create

private

def has_items
  errors.add(:base, "Must have items") if items.empty?
end
```

---

## Callbacks

**Use sparingly - prefer commands for complex logic.**

```ruby
before_validation :set_defaults
after_create :create_associated_record
after_commit :update_search_index, on: [:create, :update]

private

def set_defaults
  self.status ||= "draft"
end
```
