---
paths: "app/**/*.rb"
dependencies: []
---

# Defensive Programming & Safe Navigation

When to use `&.` (safe navigation) vs letting code fail fast.

---

## Quick Decision Tree

**Ask these questions BEFORE using safe navigation (`&.`):**

### 1. Can this object legitimately be nil in valid scenarios?

- ✅ YES → Use safe navigation
- ❌ NO → Don't use safe navigation

### 2. Is this a value object guaranteed to exist?

- ✅ YES → Don't use safe navigation (it's never nil)
- ❌ NO → Proceed to question 3

### 3. Would nil here indicate a bug in my code?

- ✅ YES → Don't use safe navigation (let it fail fast)
- ❌ NO → Use safe navigation

---

## Common Patterns

### ✅ APPROPRIATE: Optional Context

```ruby
# Context can be nil in console, tests, or public pages
def render_status
  return nil if current_user.nil?
  return nil unless current_user.active?
  # ...
end
```

**Why:** Context is legitimately nil in some scenarios.

### ✅ APPROPRIATE: User Input

```ruby
# params[:user_id] might not be present
@user = User.find_by(id: params[:user_id])
@profile = @user&.profile
```

**Why:** User input is unreliable; object might not exist.

### ❌ INAPPROPRIATE: Value Objects

```ruby
# ❌ BAD - status is a value object, never nil
return nil unless order&.status&.paid?

# ✅ GOOD - status is guaranteed to exist
return nil if order.nil?
return nil unless order.status.paid?
```

**Why:** Value objects are always present when parent exists.

### ❌ INAPPROPRIATE: Required Associations

```ruby
# ❌ BAD - user always has account (DB constraint)
account = @user&.account&.name

# ✅ GOOD - let it fail if association is broken
account = @user.account.name
```

**Why:** If association is missing, that's a bug. Safe navigation masks the problem.

### ❌ INAPPROPRIATE: After Existence Checks

```ruby
# ❌ BAD - already verified user exists
def process_user
  return unless user
  email = user&.email  # Unnecessary
end

# ✅ GOOD
def process_user
  return unless user
  email = user.email
end
```

**Why:** Safe navigation is redundant after explicit nil check.

---

## Safe Navigation Chains

**Warning:** Don't chain ordinary methods after safe navigation.

```ruby
# ❌ BAD - Can cause NoMethodError
tenant&.subscription.active?
# If tenant is nil, returns nil, then calls .active? on nil → Error!

# ✅ GOOD - Explicit nil check
return if tenant.nil?
tenant.subscription.active?

# ✅ ALSO GOOD - Only if subscription can be nil
tenant&.subscription&.active?
```

---

## Summary

**Default stance:** Don't use safe navigation. Ruby's `NoMethodError` is useful for catching bugs.

**Use safe navigation when:**

- Object is from unreliable external source (params, API, user input)
- Object being nil is a valid state (not a bug)
- You want to gracefully handle absence

**Don't use safe navigation when:**

- Object is a value object (never nil)
- Object is a required association (DB constraints)
- Nil indicates a bug (fail fast is better)
- You've already verified object exists

**Reminder:** Defensive code can hide bugs. Let errors surface during development, handle them gracefully only at system boundaries (user input, external APIs).
