---
paths: "app/business_logic/**/*.rb, app/models/**/*.rb"
dependencies: []
---

# Business Logic - Command Pattern

---

## When to Use Commands

**Use commands for:**

- Multiple models created/updated together
- External service calls needing coordination
- Complex validations across multiple objects
- Business rules that don't belong to one model

**Keep in models for:**

- Simple CRUD operations
- Single model updates
- Basic validations
- State queries and calculations

**Rule:** If logic is complex enough to test separately from the model, use a command.

---

## Base Classes

- `BaseCommand` - Simple operations without user context
- `BaseContextCommand` - Operations needing user/organization context

Both use `attribute` and return true/false.

```ruby
# Simple command
module Commands
  class SendNotification < BaseCommand
    attribute :recipient
  end
end

# Context command
class Albums::Create < BaseContextCommand
  def initialize(context, params)
    super(context)  # Required
    @params = params
  end

  # Access: current_user, organization, current_member
end
```

---

## The Context Hash

Commands use `@context` hash to pass data to controllers:

```ruby
# In command
def run
  order = create_order
  context[:order] = order
  context[:confirmation_number] = order.confirmation
  true
rescue => e
  context[:error] = e.message
  false
end

# In controller
if @command.run
  redirect_to order_path(@command.context[:order])
else
  flash[:error] = @command.context[:error]
end
```

---

## Error Handling

### When to use run_with_rescue

Use when operation can raise exceptions (update!, create!):

```ruby
def run
  run_with_rescue do
    @record.update!(params)  # Catches RecordInvalid
  end
end
```

### When to use manual handling

Use when validation logic determines success/failure:

```ruby
def run
  if invalid?
    errors.add(:base, "Cannot perform action")
    context[:error_details] = validation_errors
    return false
  end
  # continue...
end
```

---

## Key Conventions

1. **Returns:** Always true/false
2. **Data:** Use context hash for controller data needs
3. **Errors:** Use `errors.add()` AND/OR `context[:error]`
4. **Naming:** VerbNoun in modules (Albums::Create, Orders::Checkout)
5. **Attributes:** Use `attribute` from ActiveModel
6. **Transactions:** Wrap multi-step operations in ActiveRecord::Base.transaction

---

## Directory Structure

Commands live at `app/business_logic/commands/` root level by default.

Create subdirectories for:

- External service operations (e.g., `stripe_operations/`)
- Shared validators (e.g., `validators/`)
- Clear logical groupings with 3+ related commands

---

## Testing

Test both success paths AND context contents:

```ruby
describe Albums::Create do
  let(:context) { Context.new(user: users(:artist)) }
  let(:command) { described_class.new(context, params) }

  it "creates album and populates context" do
    assert command.run
    assert command.context[:album].persisted?
  end

  it "handles errors with context" do
    refute command.run
    assert command.errors.any?
    assert command.context[:error]
  end
end
```

---

## Discovery

**Command examples:** `Glob "app/business_logic/commands/**/*.rb"`

**Controller usage:** `Grep "\.new(context" app/controllers/**/*.rb`
