---
paths: "app/controllers/**/*.rb"
dependencies: [passwordless]
---

# Passwordless - Session Controller

Magic link authentication patterns.

---

## Basic Setup

Inherit from Passwordless::SessionsController:

```ruby
class SessionsController < Passwordless::SessionsController
  # Customize as needed
end
```

---

## Customizing Redirect After Sign In

Override `passwordless_success_redirect_path`:

```ruby
class SessionsController < Passwordless::SessionsController
  private

  def passwordless_success_redirect_path(_authenticatable)
    dashboard_path
  end
end
```

**Use cases:**

- Redirect to user dashboard
- Role-based redirects
- Return to requested page

---

## Custom Layout

```ruby
class SessionsController < Passwordless::SessionsController
  layout "minimal"  # Use minimal layout for auth pages
end
```

---

## Multi-Tenant Considerations

If using multi-tenant architecture:

```ruby
class SessionsController < Passwordless::SessionsController
  # Skip tenant checks for auth pages
  skip_before_action :set_current_tenant, raise: false
  skip_before_action :verify_tenant_access, raise: false

  private

  # Override to query correct database
  def build_passwordless_session(authenticatable)
    authenticatable.passwordless_sessions.build
  end
end
```

---

## Customizing Email Sending

```ruby
class SessionsController < Passwordless::SessionsController
  private

  # Override to use custom mailer
  def send_sign_in_email(authenticatable)
    CustomMailer.magic_link(authenticatable, sign_in_url).deliver_now
  end
end
```
