---
paths: "app/models/**/*.rb"
dependencies: [passwordless]
---

# Passwordless - User Model

User model integration for magic link authentication.

---

## Basic Setup

Add `passwordless_with` to your authenticatable model:

```ruby
class User < ApplicationRecord
  passwordless_with :email
end
```

---

## Using Different Field

```ruby
class User < ApplicationRecord
  passwordless_with :phone_number  # Use phone instead of email
end
```

---

## Customization Options

```ruby
class User < ApplicationRecord
  passwordless_with :email,
                    timeout: 10.minutes,  # Link expires in 10 minutes (default: 1 hour)
                    token_cost: 12        # BCrypt cost (default: 10)
end
```

**Options:**

- `timeout`: How long magic link remains valid
- `token_cost`: BCrypt cost for token hashing (higher = more secure but slower)

---

## Multi-Tenant Considerations

If using multi-tenant:

```ruby
class User < TenantRecord  # Scoped to tenant database
  passwordless_with :email

  # Ensure sessions are created in correct database
  has_many :passwordless_sessions,
           as: :authenticatable,
           dependent: :destroy
end
```
