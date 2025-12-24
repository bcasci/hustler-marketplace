---
paths: test/**/*_test.rb
dependencies: [minitest-spec-rails]
---

# Minitest Stubbing

When to stub and Minitest's built-in syntax for hard-to-reproduce scenarios.

**This project uses Minitest's built-in `.stub()`** - no external mocking gems (no Mocha, no RSpec mocks).

---

## When to Stub

**DEFAULT: Prefer real objects and recorded interactions.**

### Prefer Instead

- **Real objects** for domain logic
- **Fixtures** for database records
- **VCR** for external API happy paths
- **Time manipulation** (`travel_to`) for time-dependent behavior

### Stub When Cost-Benefit Favors It

Ask in order:

1. Can I test with real objects or recordings? → **Don't stub**
2. Is reproducing impractical? (rate limits, specific API errors, network failures) → **Consider stubbing**
3. Does stubbing test important error handling I can't trigger? → **Stub with justification**
4. Am I stubbing just to verify a method was called? → **Don't stub, test outcomes**

**Every stub MUST have a comment explaining why real objects/recordings won't work.**

---

## Minitest Stub Syntax

### Basic Stub

```ruby
Stripe::Account.stub :create, fake_account do
  result = Stripe::Account.create(params)
  assert_equal fake_account, result
end
# Original method restored after block
```

### Stub with Lambda

```ruby
Stripe::Account.stub :create, ->(params) { build_account(params) } do
  result = Stripe::Account.create(country: 'US')
  assert_equal 'US', result.country
end
```

### Stub to Raise Errors

```ruby
error = Stripe::InvalidRequestError.new('Invalid country')

Stripe::Account.stub :create, ->(*_args) { raise error } do
  assert_not command.run
  assert_includes command.errors[:base], 'Invalid country'
end
```

### Nested Stubs

```ruby
def perform_with_stubs
  Stripe::Account.stub(:create, fake_account) do
    Stripe::AccountLink.stub(:create, fake_link) do
      yield
    end
  end
end

it 'handles both API calls' do
  perform_with_stubs do
    assert command.run
  end
end
```

---

## Project Patterns

### Error Condition Testing

```ruby
it 'handles rate limit gracefully' do
  # Justified: Can't trigger real rate limit in tests
  error = Stripe::RateLimitError.new('Too many requests')

  Stripe::Account.stub :create, ->(*_args) { raise error } do
    result = command.run

    assert_not result[:success]
    assert_equal 'rate_limit', command.context[:error_type]
  end
end
```

### Testing Graceful Degradation

```ruby
it 'handles audit logging failures gracefully' do
  # Justified: Testing that audit failures don't break notification sending
  NotificationAudit.stub(:create!, ->(*) { raise StandardError }) do
    VCR.use_cassette('send_notification') do
      assert subject
      assert notification.reload.sent?
    end
  end
end
```

### Helper Methods for Complex Stubs

```ruby
it 'creates account and link' do
  perform_with_stubs do
    assert command.run
    assert command.context[:account_id].present?
  end
end

private

def perform_with_stubs
  Stripe::Account.stub(:create, fake_account) do
    Stripe::AccountLink.stub(:create, fake_link) do
      yield
    end
  end
end

def fake_account
  OpenStruct.new(id: 'acct_123')
end
```

---

## When NOT to Stub

### Don't Stub Domain Logic

```ruby
# ❌ BAD - Stubbing your own code
Album.stub :published, fake_albums do
  # Testing the stub, not your code
end

# ✅ GOOD - Use real objects
let(:published_albums) { Album.where(status: 'published') }
```

### Don't Stub Just to Verify Calls

```ruby
# ❌ BAD - Testing implementation
it 'calls calculate_total' do
  order.expects(:calculate_total).once  # Wrong
  order.save
end

# ✅ GOOD - Test outcome
it 'calculates total on save' do
  order.line_items << create(:line_item, price: 10)
  order.save
  assert_equal 10, order.total
end
```

### Don't Stub Happy Paths

```ruby
# ❌ BAD - Stub successful API call
Stripe::PaymentIntent.stub :create, fake_intent do
  # Fragile, doesn't verify real API contract
end

# ✅ GOOD - Use VCR for happy path
VCR.use_cassette('stripe_payment_intent') do
  # Real API response, verifies contract
end
```

### Don't Stub Everything

```ruby
# ❌ BAD - Over-stubbing hides real behavior
User.stub :find, fake_user do
  Album.stub :create, fake_album do
    # Testing nothing real
  end
end

# ✅ GOOD - Use real objects
let(:user) { users(:artist) }
let(:album) { Album.create!(valid_params) }
```

### Don't Stub Without Justification

```ruby
# ❌ BAD - No comment explaining why
Stripe::Account.stub :create, fake_account do
  # Why stub? Could use VCR?
end

# ✅ GOOD - Justified with comment
it 'handles rate limit error' do
  # Justified: Can't trigger real rate limit without hitting API limits
  error = Stripe::RateLimitError.new('Too many requests')
  Stripe::Account.stub :create, ->(*_args) { raise error } do
    assert_not command.run
  end
end
```

---

## Common Stub Scenarios

```ruby
# API errors
error = Stripe::AuthenticationError.new('Invalid API key')
Stripe::Account.stub :create, ->(*_args) { raise error } do
  assert_not command.run
end

# Timeouts
HTTParty.stub :post, ->(*_args) { raise Net::ReadTimeout } do
  assert_nothing_raised { ExternalSyncJob.perform_now(user) }
end

# Fallback behavior
ExternalService.stub :fetch_config, ->(*_args) { raise ConnectionError } do
  result = service.load_configuration
  assert_equal DEFAULT_CONFIG, result
end
```

---

## Discovery

**Find stubbing patterns:**

```
Grep "\.stub" test/**/*_test.rb
```

**Minitest documentation:**

- https://docs.seattlerb.org/minitest/
