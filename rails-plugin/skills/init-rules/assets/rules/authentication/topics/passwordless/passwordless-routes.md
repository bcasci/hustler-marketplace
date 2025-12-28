---
paths: config/routes.rb
dependencies: [passwordless]
---

# Passwordless - Routes

Magic link authentication routes.

---

## Basic Setup

Add passwordless routes for your authenticatable model:

```ruby
# config/routes.rb
Rails.application.routes.draw do
  passwordless_for :users
end
```

---

## Custom Path Prefix

```ruby
passwordless_for :users, at: "/auth"
```

---

## Custom Controller

Use custom controller instead of default:

```ruby
passwordless_for :users, controller: "auth/sessions"
```

**Requires:**

- Controller at `app/controllers/auth/sessions_controller.rb`
- Must inherit from `Passwordless::SessionsController`

---

## Namespace Example

```ruby
namespace :admin do
  passwordless_for :users, controller: "admin/sessions"
end
```

---

## Multiple Authenticatable Models

```ruby
passwordless_for :users
passwordless_for :admins, at: "/admin/auth"
```

---

## Constraints

Restrict passwordless routes:

```ruby
constraints subdomain: 'app' do
  passwordless_for :users
end
```
