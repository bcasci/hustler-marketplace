---
paths: app/models/**/*.rb
dependencies: []
---

# Model Concerns

---

## When to Extract Concerns

**DO extract when:**

- Same methods duplicated across 3+ models
- Model file exceeds 200 lines
- Clear feature that can be named independently
- Behavior could be reused in future models

**DON'T extract when:**

- Only used in one model (keep it in the model)
- Behavior tightly coupled to specific model attributes
- Would require many configuration options (use inheritance)
- Adds more complexity than it removes

---

## Naming Conventions

**Adjectives** (capabilities):

- `Searchable`, `Discardable`, `Publishable`

**Nouns** (features):

- `EventEmission`, `TaggableExtension`

**Avoid:**

- `Helpers`, `Utils`, `Common` (too generic)

---

## Concern Structure

All concerns follow this order:

1. `extend ActiveSupport::Concern`
2. `class_methods` block
3. Instance methods
4. `included` block (callbacks, validations, associations)

---

## Discovery

**Before creating a new concern:**

1. Search for similar behavior: `Grep "YourBehavior" app/models/concerns/**/*.rb`
2. Check if existing concern can be extended
3. Verify 3+ models need this behavior

**Browse existing:** `Glob "app/models/concerns/**/*.rb"`
