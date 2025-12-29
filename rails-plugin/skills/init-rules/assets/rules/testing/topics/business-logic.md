---
paths: "test/business_logic/**/*_test.rb"
dependencies: []
---

# Command Testing Patterns

Commands encapsulate business logic and are tested for both success/failure paths and context population.

## Basic Command Test Structure

```ruby
require 'test_helper'

class Albums::CreateTest < ActiveSupport::TestCase
  describe 'Albums::Create' do
    let(:user) { users(:artist) }
    let(:organization) { organizations(:org_one) }
    let(:context) { Context.new(user: user, organization: organization) }
    let(:valid_params) { { title: 'New Album', price_cents: 1000 } }

    it 'creates album successfully' do
      command = Albums::Create.new(context, valid_params)

      assert_difference 'Album.count' do
        assert command.run
      end

      assert command.context[:album].persisted?
      assert_equal 'New Album', command.context[:album].title
    end
  end
end
```

## Testing Success Paths

### Basic Success

```ruby
describe 'when valid data provided' do
  let(:order) { orders(:pending) }
  let(:command) { Orders::Checkout.new(context, order: order) }

  it 'executes successfully' do
    assert command.run
    assert command.errors.empty?
    assert_equal :completed, command.context[:order].state
  end
end
```

### Context Population

```ruby
describe 'context population' do
  let(:command) { Stripe::CreateAccount.new(context) }

  it 'populates context with expected values' do
    assert command.run

    # Test all context keys this command sets
    assert command.context[:account_id].present?
    assert command.context[:account_link].present?
    assert_match %r{https://connect.stripe.com}, command.context[:account_link]
  end
end
```

### Side Effects

Test observable outcomes, not method calls:

```ruby
describe 'side effects' do
  let(:album) { albums(:draft) }
  let(:command) { Albums::Publish.new(context, album: album) }

  it 'publishes the album' do
    assert command.run
    assert album.reload.published?
  end

  # Only mock when you can't verify via side effects
  it 'enqueues notification job' do
    # Justified: Can't verify email sent without checking queue
    assert_enqueued_with(job: AlbumPublishedJob, args: [album.id]) do
      assert command.run
    end
  end
end
```

## Testing Failure Paths

### Validation Failures

```ruby
describe 'with invalid params' do
  let(:command) { Albums::Create.new(context, title: '') }

  it 'fails validation' do
    assert_not command.run
    assert command.errors.any?
    assert_includes command.errors[:title], "can't be blank"
  end
end
```

### Business Rule Failures

```ruby
describe 'authorization' do
  let(:other_user) { users(:other_artist) }
  let(:other_context) { Context.new(user: other_user) }
  let(:album) { albums(:published) }
  let(:command) { Albums::Update.new(other_context, album: album) }

  it 'fails when user lacks permission' do
    assert_not command.run
    assert_includes command.errors[:base], 'Not authorized'
  end
end
```

### Context on Failure

```ruby
describe 'failure context' do
  let(:invalid_params) { { payment_token: 'invalid' } }
  let(:command) { Orders::Checkout.new(context, invalid_params) }

  it 'populates error context on failure' do
    assert_not command.run
    assert command.context[:error].present?
    assert_equal 'Payment declined', command.context[:error]
    assert_nil command.context[:order] # Should not set success keys
  end
end
```

## Testing Transactional Behavior

```ruby
describe 'transaction rollback' do
  let(:order) { orders(:pending) }
  let(:command) { Orders::CompleteCheckout.new(context, order: order) }

  it 'rolls back all changes on failure' do
    # Stub payment processing to fail
    Payment.stub :process!, ->(*_args) { raise Stripe::CardError } do
      assert_no_difference ['Order.count', 'Payment.count', 'Access.count'] do
        assert_not command.run
      end

      assert order.reload.pending? # State unchanged
    end
  end
end
```

## Testing Complex Commands

### Multi-Step Operations

```ruby
describe 'multi-step operations' do
  let(:album_params) do
    {
      title: 'Album with Tracks',
      tracks_attributes: [
        { title: 'Track 1' },
        { title: 'Track 2' },
        { title: 'Track 3' }
      ]
    }
  end
  let(:command) { Albums::CreateWithTracks.new(context, album_params) }

  it 'executes all steps in order' do
    assert_difference 'Album.count' do
      assert_difference 'Track.count', 3 do
        assert command.run
      end
    end

    album = command.context[:album]
    assert_equal 3, album.tracks.count
    assert album.published?
    assert command.context[:notification_sent]
  end
end
```

### Conditional Logic

```ruby
describe 'conditional paths' do
  describe 'express processing' do
    let(:command) { Orders::Process.new(context, express: true) }

    it 'handles express path' do
      assert command.run
      assert command.context[:express_processed]
    end
  end

  describe 'standard processing' do
    let(:command) { Orders::Process.new(context, express: false) }

    it 'handles standard path' do
      assert command.run
      assert command.context[:standard_processed]
    end
  end
end
```

## Testing Commands with External Dependencies

Focus on testing the **command's behavior**, not the external service mechanics.

```ruby
describe 'payment processing' do
  let(:command) { Payments::CreateIntent.new(context, amount: 1000) }

  it 'populates context on success' do
    # External API interaction happens here
    assert command.run

    # Test what the COMMAND does with the response
    assert command.context[:payment_intent_id].present?
    assert_equal 1000, command.context[:amount]
    assert command.context[:status].present?
  end

  it 'handles external errors gracefully' do
    # Simulate external failure
    assert_not command.run

    # Test how COMMAND handles the error
    assert command.errors[:payment].any?
    assert command.context[:error_code].present?
  end
end
```

**Testing external service mechanics (HTTP recording, mocking) is covered in separate testing patterns, not here.**

## Testing BaseCommand vs BaseContextCommand

### BaseCommand (No User Context)

```ruby
class Commands::SendNotificationTest < ActiveSupport::TestCase
  describe 'Commands::SendNotification' do
    let(:command) do
      Commands::SendNotification.new(
        type: 'album_featured',
        recipient: 'user@example.com'
      )
    end

    it 'sends notification without user context' do
      assert command.run
      assert command.context[:sent_at].present?
    end
  end
end
```

### BaseContextCommand (With User Context)

```ruby
class Albums::CreateTest < ActiveSupport::TestCase
  describe 'Albums::Create' do
    let(:user) { users(:artist) }
    let(:organization) { organizations(:label) }
    let(:context) { Context.new(user: user, organization: organization) }
    let(:command) { Albums::Create.new(context, title: 'New Album') }

    it 'uses current user and organization from context' do
      assert command.run

      album = command.context[:album]
      assert_equal user, album.created_by
      assert_equal organization, album.organization
    end
  end
end
```

## Testing Error Handling

### Error Messages

```ruby
describe 'error messages' do
  let(:command) { Albums::Create.new(context, {}) }

  it 'provides clear error messages' do
    assert_not command.run

    assert_includes command.errors[:title], "can't be blank"
    assert_includes command.errors[:price], 'is not a number'
    assert_match /missing required fields/i, command.context[:error]
  end
end
```

## Testing Idempotency

```ruby
describe 'idempotency' do
  let(:resource) { resources(:active) }
  let(:command) { Commands::SyncData.new(context, resource: resource) }

  it 'is idempotent' do
    # First run
    assert command.run
    first_result = command.context[:sync_id]

    # Second run - should succeed but not duplicate
    command2 = Commands::SyncData.new(context, resource: resource)
    assert command2.run
    assert_equal first_result, command2.context[:sync_id]

    # Verify no duplication
    assert_equal 1, SyncRecord.where(resource: resource).count
  end
end
```

## Test Helpers

```ruby
private

def valid_album_params
  {
    title: 'Test Album',
    description: 'Description',
    price_cents: 999,
    metadata: { artist_name: 'Test Artist' }
  }
end

def assert_command_success(command)
  assert command.run, "Command failed: #{command.errors.full_messages.join(', ')}"
  assert command.errors.empty?
end

def assert_command_failure(command, error_key = nil)
  assert_not command.run
  assert command.errors.any?
  assert command.errors[error_key].any? if error_key
end
```

## Best Practices

1. **Test both paths** - Success and failure scenarios
2. **Test context** - Verify all context keys are set correctly
3. **Test side effects** - Ensure expected changes occur
4. **Test transactions** - Verify rollback on failure
5. **Test command behavior** - Focus on what commands do, not external service mechanics
6. **Test edge cases** - Empty data, nil values, limits
7. **Document context keys** - Know what each command sets
