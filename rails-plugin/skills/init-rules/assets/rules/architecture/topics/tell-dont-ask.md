---
paths: "app/**/*.rb"
dependencies: []
---

# Tell, Don't Ask

OOP principle: Tell objects what to do, don't ask about their state and decide for them.

---

## The Principle

**Asking (Code Smell):**

```ruby
if tenant.root?
  # Skip setup
else
  ensure_connection!(tenant)
end
```

**Telling (Better):**

```ruby
ensure_connection!(tenant) unless tenant.root?
```

**Even Better - Let Object Decide:**

```ruby
tenant.ensure_connection!  # Tenant knows if it needs setup
```

---

## Refactoring Pattern

**Step 1: Identify asking pattern**

```ruby
# Multiple places checking same state
if user.admin?
  allow_access
else
  deny_access
end

# Elsewhere
if user.admin?
  show_admin_panel
end
```

**Step 2: Push logic into object**

```ruby
class User
  def grant_access_to(resource)
    return false unless admin?
    resource.grant!
  end

  def admin_panel?
    admin?
  end
end

# Callers just tell what they want
user.grant_access_to(resource)
```

---

## When to Apply

**Apply when:**
- Logic about object state is duplicated across callers
- Object's internals might change but behavior stays same
- Testing becomes easier (behavior over state)
- Conditional logic clutters calling code

**Example:**

```ruby
# BAD - Asking everywhere
if subscription.status == 'active' && subscription.trial_ended?
  charge_customer
end

# GOOD - Object encapsulates
if subscription.chargeable?
  charge_customer
end

# BETTER - Tell what we want
subscription.charge_if_needed
```

---

## When NOT to Apply

**Don't apply when:**
- Simple one-off check not reused elsewhere
- Guard clause for caller's logic (not object's)
- Performance-critical path (method call overhead)
- Logic truly belongs to caller, not object

**Example (Keep asking):**

```ruby
# This is caller's logic, not user's
def show_dashboard
  return render :login unless current_user  # Caller's guard clause
  render :dashboard
end
```

---

## Object Design Impact

**Push behavior down to objects:**

```ruby
class Tenant
  def ensure_connection!
    return if root?  # Object decides based on its state
    establish_connection!(database_config)
  end

  def root?
    # Internal state check
  end
end
```
