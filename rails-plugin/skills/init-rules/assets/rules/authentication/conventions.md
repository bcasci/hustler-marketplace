---
paths: "app/controllers/**/*.rb, app/helpers/**/*.rb, app/views/**/*.erb"
dependencies: []
---

# Authentication Conventions

Authentication establishes `current_user`. See authorization rules for permission checking.

---

## Rails Naming Conventions

Use these method names (Rails community standard):

```ruby
# app/controllers/application_controller.rb
helper_method :current_user, :authenticated?

private

def current_user
  # Implementation varies by authentication choice
end

def authenticated?
  current_user.present?
end

def authenticate_user!
  # Redirect or raise if not authenticated
end
```

**Standard names:**
- `current_user` - Returns authenticated user or nil
- `authenticated?` - Boolean check for authentication
- `authenticate_user!` - Before action to require authentication

**Make available to views:** `helper_method :current_user, :authenticated?`

---

## Implementation

Authentication requires choosing an implementation:

- **Magic links** - Passwordless gem
- **Passwords** - Devise, has_secure_password
- **OAuth** - OmniAuth
- **JWT tokens** - Custom implementation

**See gem-specific files in `authentication/topics/` for patterns.**
