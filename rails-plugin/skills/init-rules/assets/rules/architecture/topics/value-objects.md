---
paths: app/**/*.rb
dependencies: []
---

# Value Object Pattern

---

## Quick Decision Checklist

**Extract to value object when:**
- [ ] Model has 5+ related methods on one concept
- [ ] Methods are complex (10+ lines) and cluttering model
- [ ] Logic is read-focused (calculations, queries, transformations)

**Keep in model when:**
- [ ] Just 1-3 simple methods
- [ ] Logic directly related to persistence
- [ ] Simple calculation (1-3 lines)

**Use Command instead when:**
- [ ] Logic spans multiple models
- [ ] Write-focused operation (create, update, delete, external APIs)
- [ ] Complex workflow with validations

---

## When to Use Value Objects

### Extract When Logic Clutters Model

```ruby
# ❌ BAD - Subscription logic clutters model
class Tenant
  def subscription_valid?
    if external_subscription_status.present?
      ['active', 'trialing'].include?(external_subscription_status)
    elsif trial?
      !trial_expired?
    else
      true
    end
  end

  def trial_days_remaining
    # complex calculation
  end

  def subscription_expiring_soon?
    # more logic
  end

  # 10+ more subscription methods...
end

# ✅ GOOD - Focused model, extracted value object
class Tenant
  def subscription
    @subscription ||= Subscriptions::Status.new(self)
  end
end

class Subscriptions::Status
  def initialize(tenant)
    @tenant = tenant
  end

  def valid?
    # Implementation
  end

  def days_remaining
    # Implementation
  end
end
```

### Multiple Related Calculations

```ruby
class Money
  def initialize(cents, currency)
    @cents = cents
    @currency = currency
  end

  def to_dollars
    @cents / 100.0
  end

  def format
    "$#{to_dollars}"
  end

  def tax(rate)
    Money.new((@cents * rate).to_i, @currency)
  end
end
```

---

## When NOT to Use Value Objects

### 1. Simple Methods Work Fine

```ruby
# ✅ GOOD - No value object needed
class User
  def full_name
    "#{first_name} #{last_name}"
  end
end
```

### 2. Logic Spans Multiple Models

```ruby
# ❌ BAD - Use a Command instead
class OrderProcessor
  def initialize(order)
    @order = order
  end

  def process_payment  # Touches Order, Payment, Inventory
    # Use Commands::ProcessOrder instead
  end
end
```

### 3. Need Persistence/Callbacks

```ruby
# ❌ BAD - Use an ActiveRecord model
class Subscription
  # If you need to save to database, it's a model, not a value object
end
```

---

## Implementation Pattern

### File Location

**Pattern:** `app/models/[domain_plural]/[concept].rb`

```
app/models/
├── subscriptions/
│   └── status.rb       # Subscriptions::Status
├── addresses/
│   └── validator.rb    # Addresses::Validator
└── money/
    └── converter.rb     # Money::Converter
```

**Use plural namespace:** `Subscriptions::Status` NOT `Subscription::Status`

### Basic Structure

```ruby
# app/models/subscriptions/status.rb
class Subscriptions::Status
  attr_reader :subscription

  def initialize(subscription)
    @subscription = subscription
  end

  # Business logic methods
  def active?
    # Implementation
  end

  def days_remaining
    # Implementation
  end

  # Methods that update the underlying model
  def update_from_webhook(data)
    @subscription.update!(
      status: data[:status],
      next_billing_date: data[:billing_date]
    )
  end
end
```

### Model Integration

```ruby
class Subscription < ApplicationRecord
  # Direct field access still available
  # - status
  # - next_billing_date

  # Value object for complex logic
  def status_checker
    @status_checker ||= Subscriptions::Status.new(self)
  end
end
```

### Usage

```ruby
# Controllers
def show
  if @subscription.status_checker.active?
    render :dashboard
  else
    redirect_to upgrade_path
  end
end

# Views
<% if @subscription.status_checker.expiring_soon? %>
  <div class="alert">Expires in <%= @subscription.status_checker.days_remaining %> days</div>
<% end %>

# Jobs
Subscription.find_each do |subscription|
  next if subscription.status_checker.active?

  ExpirationMailer.warning(subscription).deliver_later
end
```

---

## Value Objects vs Other Patterns

### vs Model Methods

**Use model method when:**
- Simple calculation (1-3 lines)
- Single responsibility
- Directly related to persistence

**Use value object when:**
- Complex logic (10+ lines)
- Multiple related methods (5+ methods)
- Encapsulating a concept

### vs Commands

**Value Objects:**
- Encapsulate logic around **existing data**
- Read-focused (calculations, queries, transformations)
- No side effects beyond updating wrapped model
- Stateless (recreated each time)

**Commands:**
- Orchestrate **operations** across multiple models
- Write-focused (create, update, delete, external APIs)
- Complex workflows with validations
- Execute once and return result

### vs Concerns

**Concerns:**
- Shared behavior across **multiple models**
- Mixed into model class
- Use when same logic needed in 2+ models

**Value Objects:**
- Behavior specific to **one model**
- Separate object, not mixed in
- Use when logic is complex but model-specific

---

## Anti-Patterns

### Anemic Value Objects

```ruby
# ❌ BAD - Just data, no behavior
class Address
  attr_accessor :street, :city, :state, :zip

  # No methods - should just be model attributes
end

# ✅ GOOD - Has behavior
class Address
  def initialize(street:, city:, state:, zip:)
    @street = street
    @city = city
    @state = state
    @zip = zip
  end

  def formatted
    "#{street}\n#{city}, #{state} #{zip}"
  end

  def domestic?
    US_STATES.include?(state)
  end
end
```

### Direct Persistence

```ruby
# ❌ BAD - Value objects shouldn't have their own persistence
class Status
  def save
    ActiveRecord::Base.connection.execute(...)
  end
end

# ✅ GOOD - Update through wrapped model
class Status
  def activate!
    @record.update!(status: 'active')
  end
end
```
