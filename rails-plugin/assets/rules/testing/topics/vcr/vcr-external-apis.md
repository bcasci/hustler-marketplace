---
paths: test/**/*_test.rb
dependencies: [vcr]
---

# VCR - External API Testing

Record and replay HTTP interactions for deterministic tests.

---

## When to Use VCR

**Happy path** - Real API responses:

```ruby
# ✅ GOOD - VCR for successful API calls
it 'creates payment intent' do
  VCR.use_cassette('stripe_payment_intent_creation') do
    assert command.run
    assert command.context[:payment_intent_id].present?
  end
end
```

**Error conditions** - Stub failures:

```ruby
# ✅ GOOD - Stub for error scenarios
it 'handles card declined' do
  error = Stripe::CardError.new('Card declined', {}, code: 'card_declined')

  Stripe::PaymentIntent.stub :create, ->(*_args) { raise error } do
    assert_not command.run
    assert_equal 'card_declined', command.context[:error_code]
  end
end
```

---

## Basic Usage

### Jobs

```ruby
describe 'external API sync' do
  let(:user) { users(:customer) }

  it 'syncs with SendPulse' do
    VCR.use_cassette('sendpulse_add_contact') do
      SendPulseJob.perform_now(user)

      assert user.reload.synced_to_sendpulse?
      assert user.sendpulse_id.present?
    end
  end
end
```

---

## Cassette Naming

**Pattern:** `[service]_[action]`

**One scenario per cassette** - Don't reuse across different tests.

```ruby
# ✅ GOOD - Descriptive names
VCR.use_cassette('stripe_create_payment_intent')
VCR.use_cassette('stripe_charge_card')
VCR.use_cassette('sendpulse_add_contact')
VCR.use_cassette('aws_s3_upload_file')

# ❌ AVOID - Generic names
VCR.use_cassette('test_1')
VCR.use_cassette('api_call')
```

---

## VCR vs Stubbing

### Use VCR For:

- **Happy path scenarios** - Successful API calls
- **Real API responses** - Actual data structures
- **Integration confidence** - Verify API contract
- **Deterministic tests** - Same response every time

### Use Stubbing For:

- **Error conditions** - Failures, timeouts, invalid responses
- **Rate limiting** - Can't trigger via real API
- **Edge cases** - Hard to reproduce with real API
- **When you control the error path** - Internal rescue blocks

```ruby
# Error condition - Stub
it 'handles timeout gracefully' do
  HTTParty.stub :post, ->(*_args) { raise Net::ReadTimeout } do
    assert_not command.run
    assert_equal 'timeout', command.context[:error_type]
  end
end
```

---

## Recording Cassettes

### Initial Recording

1. Set real API credentials (test mode - never production)
2. Run test - VCR records HTTP interactions
3. Cassette saved to `test/vcr_cassettes/`
4. Subsequent runs replay from cassette
5. Check cassettes into git (team shares same responses)

### Re-recording

Delete cassette and re-run when API changes:

```bash
rm test/vcr_cassettes/stripe_payment_intent_creation.yml
bin/rails test test/business_logic/payments/create_test.rb
```

---

## Cassette Organization

```
test/vcr_cassettes/
├── stripe_create_payment_intent.yml
├── stripe_charge_card.yml
├── sendpulse_add_contact.yml
└── aws_s3_upload_file.yml
```

**Project convention:** Flat structure, descriptive names.

---

## Testing Multiple Scenarios

```ruby
describe 'Stripe payment creation' do
  describe 'with valid card' do
    it 'creates payment' do
      VCR.use_cassette('stripe_payment_valid_card') do
        assert command.run
      end
    end
  end

  describe 'with card requiring 3D Secure' do
    it 'requires authentication' do
      VCR.use_cassette('stripe_payment_3d_secure') do
        assert command.run
        assert_equal 'requires_action', command.context[:status]
      end
    end
  end

  describe 'with invalid card' do
    # Can't capture real error - use stub
    it 'handles error' do
      error = Stripe::CardError.new('Card declined')

      Stripe::PaymentIntent.stub :create, ->(*_args) { raise error } do
        assert_not command.run
      end
    end
  end
end
```

---

## Idempotency with VCR

```ruby
describe 'idempotent API calls' do
  it 'handles duplicate requests' do
    VCR.use_cassette('stripe_idempotent_charge') do
      # First call
      result1 = command.run
      id1 = command.context[:charge_id]

      # Second call with same idempotency key
      result2 = command.run
      id2 = command.context[:charge_id]

      assert_equal id1, id2  # Same charge returned
    end
  end
end
```

---

## Sensitive Data

**VCR configuration handles sensitive data filtering.**

Check `test/support/vcr.rb` for filter configuration.

```ruby
# Cassettes automatically filter:
# - API keys
# - Secret tokens
# - User emails
# - Payment details
```

---

## Common Mistake

```ruby
# ❌ AVOID - Testing VCR cassette existence
it 'has VCR cassette' do
  # This tests VCR, not your code
end

# ✅ GOOD - Test your code's behavior
it 'syncs with external API' do
  VCR.use_cassette('api_sync') do
    assert service.sync
    assert service.synced_at.present?
  end
end
```

---

## Discovery

**Find VCR usage:**

```
Grep "VCR.use_cassette" test/**/*_test.rb
```

**List recorded cassettes:**

```
ls test/vcr_cassettes/
```

**VCR documentation:**

- https://github.com/vcr/vcr
