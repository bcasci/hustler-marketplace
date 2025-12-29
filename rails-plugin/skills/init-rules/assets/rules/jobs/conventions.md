---
paths: "app/jobs/**/*.rb"
dependencies: []
---

# Job Patterns

---

## When to Delegate vs Self-Contained

**Delegate to commands when:**

- Operation involves multiple models
- Business logic needs testing separately
- Error handling is complex

**Self-contained when:**

- Simple queries (`User.subscribed.find_each`)
- Job coordination (spawning other jobs)
- Cleanup operations (`Session.where(...).destroy_all`)

**Rule:** If you'd test it separately from job infrastructure, extract to a command.

---

## Queue Organization

```ruby
queue_as :critical     # Payments, urgent notifications
queue_as :default      # Standard priority
queue_as :low          # Reports, analytics, cleanup

# Domain-specific
queue_as :payouts      # Financial transfers
queue_as :emails       # Email delivery
queue_as :webhooks     # External API callbacks
```

---

## Error Handling

### retry_on vs discard_on

**retry_on:** Transient errors that may succeed on retry

```ruby
retry_on Stripe::RateLimitError, wait: :exponentially_longer, attempts: 5
retry_on ActiveRecord::Deadlocked, wait: :exponentially_longer, attempts: 3
retry_on Net::ReadTimeout, wait: 5.seconds, attempts: 3
```

**discard_on:** Permanent failures that won't succeed on retry

```ruby
discard_on ActiveRecord::RecordNotFound
discard_on Stripe::InvalidRequestError
discard_on ArgumentError
```

### Conditional Retry

```ruby
def perform(payout_id)
  process_payout(payout_id)
rescue SomeError => e
  if transient?(e)
    raise  # Triggers retry_on
  else
    Rails.logger.warn "Permanent failure: #{e.message}"
    # Doesn't raise, job completes
  end
end
```

---

## Idempotency

**CRITICAL:** Jobs must be safe to run multiple times.

### Early Return Guards

```ruby
class ProcessOrderJob < ApplicationJob
  def perform(order_id)
    order = Order.find(order_id)

    return if order.processed?  # Idempotent guard

    # Process order...
  end
end
```

### Caching to Prevent Duplicate Work

```ruby
class SendNotificationJob < ApplicationJob
  def perform(type:, recipient_id:, resource_id:)
    cache_key = "notification:#{type}:#{recipient_id}:#{resource_id}"

    return if Rails.cache.exist?(cache_key)

    send_notification(type, recipient_id, resource_id)
    Rails.cache.write(cache_key, true, expires_in: 7.days)
  end
end
```

### Database Guards

```ruby
class CreatePayoutJob < ApplicationJob
  def perform(user_id:, period_end:)
    # Idempotent: unique constraint prevents duplicates
    Payout.create!(
      user_id: user_id,
      period_end: period_end
    )
  rescue ActiveRecord::RecordNotUnique
    Rails.logger.info "Payout already exists, skipping"
  end
end
```

---

## Job Chaining

### Sequential Operations

```ruby
def perform(order_id)
  process_order(order_id)

  # Spawn follow-up jobs on success
  SendOrderConfirmationJob.perform_later(order_id)
  NotifyWarehouseJob.perform_later(order_id)
  UpdateInventoryJob.perform_later(order_id)
end
```

### Conditional Chaining

```ruby
def perform(order_id)
  if process_order(order_id)
    SendConfirmationJob.perform_later(order_id)
  else
    NotifyFailureJob.perform_later(order_id)
  end
end
```

### Batch Processing

```ruby
class ProcessDailyPayoutsJob < ApplicationJob
  queue_as :low

  def perform(date = Date.current)
    eligible_users(date).find_each do |user|
      CreatePayoutJob.perform_later(user_id: user.id, date: date)
    end
  end
end
```

---

## Scheduling

```ruby
# Immediate execution
ProcessOrderJob.perform_later(order)

# Delayed execution
PublishAlbumJob.set(wait: 1.hour).perform_later(album)

# Scheduled time
SendReminderJob.set(wait_until: album.release_date).perform_later(album)
```

---

## Logging

```ruby
def perform(order_id)
  Rails.logger.info "Processing order: order_id=#{order_id}"

  process_order(order_id)

  Rails.logger.info "Order processed: order_id=#{order_id} duration=#{duration}"
end
```

---

## Discovery

**Job examples:** `Glob "app/jobs/**/*.rb"`

**Enqueue sites:** `Grep "perform_later" app/{controllers,models}/**/*.rb`
