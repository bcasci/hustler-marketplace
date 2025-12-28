---
paths: test/controllers/**/*.rb
dependencies: [passwordless]
---

# Passwordless - Controller Testing

Testing SessionsController and authentication flow.

---

## Test Helper

Use `passwordless_sign_in` helper for controller tests:

```ruby
# test/test_helper.rb
include Passwordless::TestHelpers

# In controller tests
class AlbumsControllerTest < ActionDispatch::IntegrationTest
  setup do
    passwordless_sign_in(users(:alice))
  end

  test "authenticated user can access index" do
    get albums_path
    assert_response :success
  end
end
```

---

## Testing Sign In Flow

Test requesting magic link:

```ruby
# test/controllers/sessions_controller_test.rb
class SessionsControllerTest < ActionDispatch::IntegrationTest
  test "GET sign_in shows form" do
    get sign_in_path
    assert_response :success
    assert_select "form"
  end

  test "POST sign_in creates session and sends email" do
    user = users(:alice)

    assert_emails 1 do
      post sign_in_path, params: { email: user.email }
    end

    assert_redirected_to root_path
    assert_equal "Check your email", flash[:notice]
  end

  test "POST sign_in with unknown email shows error" do
    post sign_in_path, params: { email: "unknown@example.com" }

    assert_response :unprocessable_entity
    assert_equal "Email not found", flash[:alert]
  end
end
```

---

## Testing Magic Link Verification

```ruby
test "GET sign_in with valid token authenticates user" do
  user = users(:alice)
  session = user.passwordless_sessions.create!(
    timeout_at: 1.hour.from_now
  )

  get users_sign_in_path(session.token)

  assert_redirected_to dashboard_path
  assert_equal "Welcome", flash[:notice]
  # Verify user is signed in
  get dashboard_path
  assert_response :success
end

test "GET sign_in with expired token shows error" do
  user = users(:alice)
  session = user.passwordless_sessions.create!(
    timeout_at: 1.hour.ago  # Expired
  )

  get users_sign_in_path(session.token)

  assert_redirected_to sign_in_path
  assert_equal "Link expired", flash[:alert]
end
```

---

## Testing Sign Out

```ruby
test "GET sign_out clears authentication" do
  passwordless_sign_in(users(:alice))

  get sign_out_path

  assert_redirected_to root_path
  assert_equal "Signed out", flash[:notice]

  # Verify user is signed out
  get dashboard_path
  assert_redirected_to sign_in_path
end
```

---

## Testing Custom Redirects

```ruby
test "redirects to custom path after sign in" do
  user = users(:alice)
  session = user.passwordless_sessions.create!(
    timeout_at: 1.hour.from_now
  )

  # Assuming your SessionsController overrides passwordless_success_redirect_path
  get users_sign_in_path(session.token)

  assert_redirected_to user_dashboard_path(user)
end
```

---

## Testing Protected Actions

```ruby
test "requires authentication for protected actions" do
  get albums_path

  assert_redirected_to sign_in_path
  assert_equal "Please sign in", flash[:alert]
end

test "authenticated user can access protected actions" do
  passwordless_sign_in(users(:alice))

  get albums_path

  assert_response :success
end
```

---

## Multi-Tenant Controller Tests

```ruby
test "user signs in to correct tenant" do
  tenant = tenants(:acme)
  user = tenant.users.first

  Tenant.connect(tenant.id) do
    session = user.passwordless_sessions.create!(timeout_at: 1.hour.from_now)

    get users_sign_in_path(session.token)

    assert_redirected_to dashboard_path
    # Verify user is in correct tenant context
    get dashboard_path
    assert_select "h1", tenant.name
  end
end
```
