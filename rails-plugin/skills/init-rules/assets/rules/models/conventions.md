---
paths: app/models/**/*.rb, app/business_logic/**/*.rb
dependencies: []
---

# Model Patterns

---

## What Belongs in Models

**Keep in models:**

- Data structure (associations, validations)
- State queries (`published?`, `refundable?`)
- Simple calculations (`total_price`, `days_until_release`)
- Scopes for filtering and querying
- Callbacks for simple data integrity (use sparingly)

**Extract to commands:**

- Operations involving multiple models
- External service calls
- Complex workflows with multiple steps
- Business rules spanning multiple objects

**Rule:** If logic is complex enough to test separately from the model, use a command.

---

## Validations

**BEFORE writing custom `validate`:**

Try built-in validators + conditions first.

### ❌ Custom Validation

```ruby
validate :only_one_root

private

def only_one_root
  if root? && self.class.exists?(root: true, organization: organization)
    errors.add(:root, "only one root allowed")
  end
end
```

### ✅ Built-in with Conditions

```ruby
validates :root, uniqueness: { scope: :organization }, if: :root?
```

**Decision tree:**

1. Can I express this with built-in validators? → Use them
2. Do I need conditional logic? → Add `if:` or `unless:`
3. Do I need complex business rules? → Consider custom validator class
4. Is validation only relevant in specific contexts? → Use `on: :context`

**Common built-ins:**

- `presence`, `uniqueness`, `inclusion`, `exclusion`
- `numericality`, `length`, `format`
- `comparison` (Rails 7+)

---

## Model Structure

Standard order:

1. Associations (belongs_to first, then has_many/has_one)
2. Validations
3. Scopes (always use lambdas)
4. Callbacks (use sparingly, prefer commands)
5. Public instance methods
6. Private methods

See `app/models/album.rb` for production example.

---

## Domain Terminology

### "Releases" vs "Albums"

- **Public-facing/Industry**: "Releases" (any body of work: album, single, EP)
- **Internal model**: `Album` (Rails model representing releases)

**Usage:**

- Public scopes/UI: Use "releases" (e.g., `Genre.with_salable_releases`)
- Model code: Use "Album" (e.g., `has_many :albums`)

```ruby
# Good - Public-facing scope
scope :with_salable_releases, -> { ... }

# Good - Internal association
has_many :albums, dependent: :destroy
```

---

## Model Inheritance (STI)

### Product Hierarchy

```ruby
class Product < ApplicationRecord
  # Base class for all products
end

class Album < Product
  has_many :tracks, foreign_key: :parent_id
end

class Track < Product
  belongs_to :album, foreign_key: :parent_id, optional: true
end

class MonetaryContribution < Product
end
```

**Method placement:**

- Shared behavior → Base class (Product)
- Subclass-specific → That subclass only
- Ask: "Would ALL types use this?" before adding to base

---

## Required 1:1 Associations

When every instance MUST have an associated record:

```ruby
class User < ApplicationRecord
  has_one :store, dependent: :destroy
  after_create :create_store_if_needed

  private
  def create_store_if_needed
    create_store unless store
  end
end
```

**When to use:**

- Association truly required for every instance
- Associated record has no required setup data
- Want to guarantee data integrity everywhere (console, seeds, tests)

---

## Organization Scoping

Products and tenant-specific data belong to organizations for data isolation.

```ruby
class Product < ApplicationRecord
  belongs_to :organization

  scope :for_organization, ->(org) { where(organization: org) }
end
```

**In controllers:** Use `current_organization.products` not `Product.where(organization: ...)`
