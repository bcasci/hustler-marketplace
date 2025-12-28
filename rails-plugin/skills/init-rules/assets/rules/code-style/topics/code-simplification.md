---
paths: app/**/*.rb
dependencies: []
---

# Code Simplification Patterns

Mechanical checks for common simplification patterns during code review.

---

## Quick Checklist

- [ ] Can complex conditionals be replaced with simple fallbacks?
- [ ] Are we rescuing errors that should fail loudly?
- [ ] Can guard clause blocks be one-liners?
- [ ] Are we being unnecessarily defensive?
- [ ] Can string concatenation with nil checks use array compact join?

---

## Pattern 1: Simple Fallbacks Over Complex Conditionals

### ❌ Complex

```ruby
tenant = if subdomain.blank? || subdomain == "www"
           Tenant.root
         else
           Tenant.active.find_by(subdomain:)
         end
```

### ✅ Simple

```ruby
tenant = Tenant.active.find_by(subdomain:) || Tenant.root
```

**When to apply:**

- Primary path is a lookup that might return nil
- Fallback is simple (not dependent on why primary failed)
- All conditions lead to same fallback

**When NOT to apply:**

- Different conditions need different fallbacks
- Need to distinguish WHY primary failed

---

## Pattern 2: Let It Fail Loudly

### ❌ Silent Rescue

```ruby
begin
  ensure_database_connection!(tenant)
rescue StandardError => e
  Rails.logger.error "Failed: #{e.message}"
  return :default  # Silent fallback hides problems
end
```

### ✅ Fail Loudly

```ruby
ensure_database_connection!(tenant)
# Let it raise - that's a real problem
```

**Valid reasons to rescue:**

- External API calls (network issues expected)
- User input parsing (invalid data expected)
- Graceful degradation (feature rollback)

**Invalid reasons:**

- "Just in case something goes wrong"
- "To avoid breaking the app"
- "For safety"

**Rule:** If you can't name the specific exception and why it's safe to ignore, don't rescue.

---

## Pattern 3: One-liner Guard Clauses

### ❌ Guard Block

```ruby
unless tenant.root?
  ensure_connection!(tenant)
end
```

### ✅ One-liner Guard

```ruby
ensure_connection!(tenant) unless tenant.root?
```

**When to apply:**

- Guard wraps single logical operation
- Guard condition is simple
- Makes intent clearer as one line

**When NOT to apply:**

- Guard wraps multiple operations
- Guard condition is complex
- Need comment to explain WHY

---

## Pattern 4: Question Defensive Code

### ❌ Defensive

```ruby
return :default unless tenant  # "What if tenant is nil?"

# But business rule: tenant MUST exist (we have fallback)
tenant = find_by(subdomain:) || Tenant.root
raise unless tenant
```

### ✅ Trust Business Rules

```ruby
tenant = find_by(subdomain:) || Tenant.root
raise "No tenant and no root configured" unless tenant  # Only config errors

# No defensive returns - nil tenant IS a bug
```

**Questions to ask:**

1. Can this actually be nil given our business logic?
2. If it IS nil, is that a bug we should catch, not hide?
3. Are we returning a "safe" default that masks problems?

**When defensive code is GOOD:**

- Public API boundaries
- User-provided data
- Legacy code during refactoring

**When defensive code is BAD:**

- Internal code with strong invariants
- After we've already validated something
- When failure should be loud

---

## Pattern 5: Array Compact Join

### ❌ Explicit Nil Checks

```ruby
def display_name
  return "" if first_name.nil? && last_name.nil?

  "#{first_name} #{last_name}"
end
```

### ✅ Array Compact Join

```ruby
def display_name
  [first_name, last_name].compact_blank.join(" ")
end
```

**When to apply:**

- Concatenating multiple optional values with separator
- Need to handle: all nil, some nil, none nil, empty strings
- Want automatic handling without explicit conditionals

**Use `compact_blank` (Rails 6.1+), NOT `compact`:**

- `compact` only removes `nil`, leaving empty strings
- `compact_blank` removes both `nil` AND empty strings

```ruby
# Why compact_blank matters:
["", "Doe"].compact.join(" ")       # => " Doe" (leading space!)
["", "Doe"].compact_blank.join(" ") # => "Doe" (correct!)

["John", ""].compact.join(" ")       # => "John " (trailing space!)
["John", ""].compact_blank.join(" ") # => "John" (correct!)
```

**Examples:**

```ruby
# Full name with middle initial
[first_name, middle_initial, last_name].compact_blank.join(" ")

# Address line
[street, city, state, zip].compact_blank.join(", ")

# Email-style username
[first_name, last_name].compact_blank.join(".").downcase
```

---

## Application Priority

**High Impact:**

1. Let it fail loudly (Pattern 2) - Catches bugs early
2. Simple fallbacks (Pattern 1) - Reduces cognitive load
3. Question defensive code (Pattern 4) - Prevents masking bugs

**Lower Impact:** 4. One-liner guards (Pattern 3) - Cosmetic but cleaner 5. Array compact join (Pattern 5) - Nice-to-have for string building
