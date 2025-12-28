---
paths: app/mailers/**/*.rb
dependencies: [passwordless]
---

# Passwordless - Magic Link Mailer

Customizing magic link email delivery.

---

## Custom Mailer

Create custom mailer to customize email:

```ruby
# app/mailers/auth_mailer.rb
class AuthMailer < ApplicationMailer
  def magic_link(authenticatable, sign_in_url)
    @user = authenticatable
    @sign_in_url = sign_in_url

    mail(
      to: @user.email,
      subject: "Sign in to #{ENV['APP_NAME']}"
    )
  end
end
```

**View template:**

```erb
<%# app/views/auth_mailer/magic_link.html.erb %>
<h1>Welcome back!</h1>

<p>Click the link below to sign in:</p>

<%= link_to "Sign in to #{ENV['APP_NAME']}", @sign_in_url %>

<p>This link expires in 1 hour.</p>
```

---

## Configure Custom Mailer

```ruby
# config/initializers/passwordless.rb
Passwordless.configure do |config|
  config.parent_mailer = "ApplicationMailer"
  config.mailer_from = ENV['MAILER_FROM']
end
```
