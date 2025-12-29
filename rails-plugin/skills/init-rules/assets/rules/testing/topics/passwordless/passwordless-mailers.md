---
paths: "test/mailers/**/*.rb"
dependencies: [passwordless]
---

# Passwordless - Mailer Testing

Testing magic link email delivery.

---

## Basic Mailer Test

Test custom magic link mailer:

```ruby
# test/mailers/auth_mailer_test.rb
class AuthMailerTest < ActionMailer::TestCase
  test "magic link email" do
    user = users(:alice)
    url = "https://example.com/sign_in/token123"

    email = AuthMailer.magic_link(user, url).deliver_now

    assert_equal [user.email], email.to
    assert_includes email.body.to_s, url
    assert_includes email.subject, "Sign in"
  end

  test "magic link email includes user name" do
    user = users(:alice)
    url = "https://example.com/sign_in/token123"

    email = AuthMailer.magic_link(user, url).deliver_now

    assert_includes email.body.to_s, user.name
  end
end
```

---

## Testing Email Content

Verify email contains required elements:

```ruby
test "magic link email has all required elements" do
  user = users(:alice)
  url = "https://example.com/sign_in/token123"

  email = AuthMailer.magic_link(user, url).deliver_now

  # Verify recipients
  assert_equal [user.email], email.to
  assert_equal ENV['MAILER_FROM'], email.from.first

  # Verify content
  body = email.body.to_s
  assert_includes body, url
  assert_includes body, "expires"
  assert_includes body, "Sign in"
end
```

---

## Testing Email Delivery

Test that emails are queued/delivered:

```ruby
test "requesting magic link sends email" do
  user = users(:alice)

  assert_emails 1 do
    post users_sign_in_path, params: { email: user.email }
  end

  email = ActionMailer::Base.deliveries.last
  assert_equal [user.email], email.to
end
```

---

## Multi-Tenant Mailer Tests

```ruby
test "magic link email uses tenant branding" do
  tenant = tenants(:acme)
  user = tenant.users.first

  Tenant.connect(tenant.id) do
    email = AuthMailer.magic_link(user, sign_in_url).deliver_now

    assert_includes email.subject, tenant.name
    assert_includes email.body.to_s, tenant.name
  end
end
```
