---
paths: "**/*.rb"
dependencies: []
---

# Ruby Naming Conventions

---

## Boolean Predicate Methods

### Pattern: Use Adjective Form

Name predicates as adjectives or past participles that describe state, not actions or imperatives.

```ruby
# GOOD - Adjective/state form
def purchasable?
def linkable?
def visible?
def downloadable?
def editable?

# BAD - Imperative/action form
def show_cart_button?
def should_link?
def can_edit?
```

### Pattern: Avoid `has_` Prefix

The `?` suffix already implies a boolean query.

```ruby
# GOOD
def bonus_content?
def children?
def errors?

# BAD
def has_bonus_content?
def has_children?
def has_errors?
```

### Pattern: Avoid `show_` Prefix

Predicates describe state, not UI rendering decisions.

```ruby
# GOOD
def bonus_badge?
def cart_button?
def preview?

# BAD
def show_bonus_badge?
def show_cart_button?
def show_preview?
```

### Pattern: Avoid `should_` and `can_` Prefixes

Direct adjectives are clearer than modal verbs.

```ruby
# GOOD
def linkable?
def accessible?
def executable?

# BAD
def should_link?
def can_access?
def can_execute?
```

---

## Constructor Parameters

Boolean parameters should match predicate naming.

```ruby
# GOOD
AlbumCard.new(
  album: album,
  bonus_badge: true,      # → bonus_badge?
  cart_button: false,     # → cart_button?
  linkable: true          # → linkable?
)

# BAD
AlbumCard.new(
  album: album,
  show_bonus_badge: true,
  show_cart_button: false,
  should_link: true
)
```

---

## Instance Variable Names

Follow the same patterns.

```ruby
# GOOD
@purchasable = variant.present?
@linkable = destination.present?
@visible = permissions.allow?(:view)

# BAD
@should_show = variant.present?
@can_link = destination.present?
@is_visible = permissions.allow?(:view)
```

---

## Method vs Parameter Naming

The method predicate and controlling parameter should share the root name:

| Parameter      | Predicate      | Logic                              |
| -------------- | -------------- | ---------------------------------- |
| `bonus_badge:` | `bonus_badge?` | `bonus_badge && bonus_content?`    |
| `cart_button:` | `cart_button?` | `cart_button && purchasable?`      |
| `linkable:`    | `linkable?`    | `linkable && destination.present?` |

---

## Common Transformations

| Avoid            | Prefer         | Reason                                   |
| ---------------- | -------------- | ---------------------------------------- |
| `has_content?`   | `content?`     | Redundant prefix                         |
| `has_items?`     | `items?`       | Redundant prefix                         |
| `show_banner?`   | `banner?`      | UI imperative                            |
| `show_button?`   | `button?`      | UI imperative                            |
| `should_render?` | `renderable?`  | Modal verb                               |
| `can_purchase?`  | `purchasable?` | Modal verb (unless checking permissions) |
| `is_active?`     | `active?`      | Redundant prefix                         |
| `is_valid?`      | `valid?`       | Redundant prefix                         |

---

## When `can_` IS Appropriate

Use `can_` when explicitly checking user permissions:

```ruby
# GOOD - User permission check (subject is explicit)
def can_edit?(user)
  user.admin? || user == owner
end

def can_delete?(user)
  policy(user).destroy?
end
```

---

## Rails/ActiveRecord Conventions

```ruby
class Order < ApplicationRecord
  # State checks - adjective form
  def completed?
    status == 'completed'
  end

  def refundable?
    completed? && created_at > 30.days.ago
  end

  # Collection checks - simple presence
  def items?
    order_items.any?
  end
end
```

---

## Summary

1. **Use adjectives**: `purchasable?`, `visible?`, `linkable?`
2. **Avoid prefixes**: No `has_`, `show_`, `should_`, `is_`, `can_` (except for explicit user permission checks)
3. **Match parameters to predicates**: `bonus_badge:` → `bonus_badge?`
4. **Think state, not action**: Predicates describe what something IS, not what to DO
