---
paths: "test/models/**/*.rb"
dependencies: [passwordless]
---

# Passwordless - Model Testing

Testing User model integration with passwordless authentication.

---

## Model Association Testing

Test passwordless relationships and session creation:

```ruby
# test/models/user_test.rb
class UserTest < ActiveSupport::TestCase
  test "has passwordless sessions association" do
    user = users(:alice)
    assert user.respond_to?(:passwordless_sessions)
  end

  test "can create passwordless session" do
    user = User.create!(email: "test@example.com")
    session = user.passwordless_sessions.create!(
      timeout_at: 1.hour.from_now
    )

    assert session.persisted?
    assert_equal user, session.authenticatable
  end

  test "session belongs to correct authenticatable" do
    user = users(:alice)
    session = user.passwordless_sessions.create!(timeout_at: 1.hour.from_now)

    assert_equal user, session.authenticatable
  end
end
```

---

## Multi-Tenant Testing

When using multi-tenant (separate databases):

```ruby
test "creates sessions in correct tenant database" do
  Tenant.connect(tenant_id) do
    user = users(:alice)
    session = user.passwordless_sessions.create!(timeout_at: 1.hour.from_now)

    assert session.persisted?
    # Verify session is in tenant database, not default
  end
end
```
