---
paths: test/system/**/*.rb
dependencies: [passwordless]
---

# Passwordless - System Testing

Testing end-to-end magic link authentication flow.

---

## System Test Helper

**DON'T use `passwordless_sign_in` in system tests** - it doesn't work with Capybara.

Instead, manually create session:

```ruby
# test/test_helper.rb or test/system/test_helper.rb
def sign_in_as(user)
  session = user.passwordless_sessions.create!(
    authenticatable: user,
    timeout_at: 1.hour.from_now
  )

  # Set session cookie or use API to establish authentication
  visit root_path
end
```

---

## Testing Magic Link Flow

Test the complete sign-in flow:

```ruby
# test/system/authentication_test.rb
class AuthenticationTest < ApplicationSystemTestCase
  test "user signs in with magic link" do
    user = users(:alice)

    visit sign_in_path
    fill_in "Email", with: user.email
    click_button "Send magic link"

    assert_text "Check your email"

    # In tests, you can access the session token directly
    session = user.passwordless_sessions.last
    visit users_sign_in_path(session.token)

    assert_text "Welcome"
    assert_current_path dashboard_path
  end

  test "expired magic link shows error" do
    user = users(:alice)
    session = user.passwordless_sessions.create!(
      timeout_at: 1.hour.ago  # Expired
    )

    visit users_sign_in_path(session.token)

    assert_text "Link has expired"
    assert_current_path sign_in_path
  end
end
```

---

## Testing Sign Out

```ruby
test "user signs out" do
  user = users(:alice)
  sign_in_as(user)

  visit dashboard_path
  click_link "Sign out"

  assert_text "Signed out"
  assert_current_path root_path
end
```

---

## Multi-Tenant System Tests

```ruby
test "user signs in to correct tenant" do
  tenant = tenants(:acme)
  user = tenant.users.first

  Tenant.connect(tenant.id) do
    sign_in_as(user)

    visit dashboard_path
    assert_text tenant.name
  end
end
```
