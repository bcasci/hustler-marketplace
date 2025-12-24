---
paths: test/jobs/**/*_test.rb
dependencies: []
---

# Job Testing Patterns

Job tests focus on testing the job's execution behavior, error handling, and side effects. Testing whether a job is enqueued belongs in the caller's tests (models, commands, controllers).

## Basic Job Test Structure

```ruby
require 'test_helper'

class SendNotificationJobTest < ActiveJob::TestCase
  describe 'SendNotificationJob' do
    let(:user) { users(:customer) }
    let(:album) { albums(:published) }

    it 'performs notification sending' do
      # Test the job execution directly
      SendNotificationJob.perform_now(
        type: :album_published,
        recipient: user,
        resource: album
      )

      # Verify side effects
      assert_equal 1, ActionMailer::Base.deliveries.count
      expected_cache_key = "notification:album_published:user:#{user.id}:album:#{album.id}"
      assert Rails.cache.exist?(expected_cache_key)
    end
  end
end
```

## Testing Job Execution

### Basic Execution

```ruby
describe 'job execution' do
  let(:order) { orders(:pending) }

  it 'processes order successfully' do
    ProcessOrderJob.perform_now(order)

    assert order.reload.processed?
    assert order.processed_at.present?
  end
end
```

### With Arguments

```ruby
describe 'with arguments' do
  let(:user) { users(:artist) }

  it 'sends email with correct parameters' do
    assert_emails 1 do
      WelcomeEmailJob.perform_now(
        user_id: user.id,
        template: 'artist_welcome'
      )
    end

    email = ActionMailer::Base.deliveries.last
    assert_equal user.email, email.to.first
    assert_match 'Welcome', email.subject
  end
end
```

## Error Handling

### Testing Error Handling - Know Your Code

Before writing error tests, understand the code:

```ruby
# If the job rescues errors internally:
def log_notification(**attrs)
  NotificationAudit.create!(...)
rescue StandardError => e
  Rails.logger.error "Failed to create notification audit: #{e.message}"
end

# Then you MUST mock to test the error path:
it 'handles audit creation failures gracefully' do
  NotificationAudit.expects(:create!).raises(StandardError)
  assert_nothing_raised { subject }
  # Verify job continues despite audit failure
end

# If you can't mock/simulate the error, DON'T write the test!
```

### Retry Behavior

```ruby
describe 'retry behavior' do
  let(:webhook_payload) { { event: 'payment.succeeded' } }

  before do
    Stripe::API.stubs(:request).raises(Stripe::APIConnectionError).then.returns(success_response)
  end

  it 'retries on transient failure' do
    assert_nothing_raised do
      StripeWebhookJob.perform_now(webhook_payload)
    end

    # Job should complete after retry
    assert webhooks(:pending).reload.processed?
  end
end
```

### Permanent Failures

```ruby
describe 'permanent failures' do
  it 'handles permanent failure gracefully' do
    assert_raises(ActiveJob::DeserializationError) do
      ProcessDeletedRecordJob.perform_now(999999)
    end

    # Verify error was logged/handled appropriately
    assert_equal 'failed', JobStatus.last.state
  end
end
```

## Testing with ActionMailer

```ruby
describe 'email sending' do
  let(:order) { orders(:completed) }

  it 'sends order confirmation email' do
    assert_emails 1 do
      OrderConfirmationJob.perform_now(order)
    end

    email = ActionMailer::Base.deliveries.last
    assert_equal order.user.email, email.to.first
    assert_equal "Order ##{order.number} Confirmation", email.subject
    assert_match order.total.format, email.body.to_s
  end
end
```

## Testing Time-Sensitive Jobs

```ruby
describe 'scheduled jobs' do
  let(:album) { albums(:scheduled) }

  it 'processes job at correct time' do
    # Test job execution at scheduled time
    travel_to album.scheduled_publish_time do
      PublishAlbumJob.perform_now(album)
      assert album.reload.published?
    end
  end

  it 'skips job if scheduled time not reached' do
    # Test job execution before scheduled time
    travel_to 1.hour.before(album.scheduled_publish_time) do
      PublishAlbumJob.perform_now(album)
      assert_not album.reload.published?
    end
  end
end
```

## Testing Job Callbacks

```ruby
class JobWithCallbacksTest < ActiveJob::TestCase
  describe 'callbacks' do
    it 'executes before_perform callback' do
      job = LoggingJob.new
      job.expects(:log_start)

      job.perform_now
    end

    it 'executes after_perform callback' do
      job = MetricsJob.new
      Metrics.expects(:increment).with('jobs.completed')

      job.perform_now
    end
  end
end
```

## Testing with External Services

### Using Recorded HTTP Interactions

Use recorded HTTP interactions for happy path testing:

```ruby
describe 'external API integration' do
  let(:user) { users(:customer) }

  it 'syncs with external API' do
    # Use recorded HTTP interactions for happy path testing
    with_recorded_http('sendpulse_add_contact') do
      SendPulseJob.perform_now(user)

      assert user.reload.synced_to_sendpulse?
      assert user.sendpulse_id.present?
    end
  end
end
```

### Mocking for Error Conditions

```ruby
describe 'API error handling' do
  let(:user) { users(:customer) }

  before do
    # Mock only when necessary (e.g., error conditions)
    HTTParty.expects(:post).raises(Net::ReadTimeout)
  end

  it 'handles API errors gracefully' do
    assert_nothing_raised do
      ExternalSyncJob.perform_now(user)
    end

    assert_equal 'sync_failed', user.reload.sync_status
  end
end
```

## Testing Idempotency

```ruby
describe 'idempotency' do
  let(:album) { albums(:draft) }

  it 'is idempotent' do
    # First run
    PublishAlbumJob.perform_now(album)
    assert album.reload.published?
    first_published_at = album.published_at

    # Second run should not change anything
    PublishAlbumJob.perform_now(album)
    assert_equal first_published_at, album.reload.published_at
  end
end
```

## Testing Solid Queue Features

```ruby
describe 'Solid Queue features' do
  let(:resource) { resources(:important) }

  it 'sets job priority' do
    job = HighPriorityJob.perform_later(resource)

    solid_queue_job = SolidQueue::Job.last
    assert_equal 10, solid_queue_job.priority
  end
end
```

## What NOT to Test in Job Tests

```ruby
# DON'T test if jobs are enqueued - that belongs in caller tests
describe 'bad example' do
  it 'enqueues job' do
    assert_enqueued_with(job: MyJob) do
      model.trigger_job  # Test this in model/command/controller tests
    end
  end
end

# DON'T test ActiveJob internals
describe 'bad example' do
  it 'inherits from ApplicationJob' do
    assert MyJob < ApplicationJob  # Framework concern
  end
end
```

## Where to Test Job Enqueueing

Test that jobs are enqueued in the appropriate caller tests:

- **Model tests**: When callbacks enqueue jobs
- **Command tests**: When commands trigger async work
- **Controller tests**: When actions enqueue jobs
- **System tests**: When user actions trigger background work

## Common Helpers

```ruby
# Custom assertion for job side effects
def assert_job_processed_successfully(job_class, *args)
  job_class.perform_now(*args)

  # Add job-specific assertions
  yield if block_given?
end

# Test job with command delegation
def assert_delegates_to_command(job_class, command_class, *args)
  command_mock = mock('command')
  command_mock.expects(:run).returns(true)
  command_mock.expects(:context).returns({}).at_least_once

  command_class.expects(:new).returns(command_mock)

  job_class.perform_now(*args)
end
```

## Best Practices

1. **Test job execution** - Use `perform_now` to test synchronously
2. **Verify side effects** - Check what the job actually does
3. **Test error handling** - How the job handles command failures
4. **Test idempotency** - Jobs should be safe to run multiple times
5. **Mock sparingly** - Only for error conditions or external APIs
6. **Record HTTP interactions** - Use recorded responses for external API happy paths
