## Document Examples

**Good Documentation Prompt:**

```
Document the authentication system for our Rails API. Include:

1. Overview: How authentication works in our system
2. Setup: How to configure authentication for a new service
3. Usage: How to authenticate requests (with code examples)
4. Token management: How tokens are created, refreshed, and revoked
5. Security considerations: Best practices and common pitfalls

Write in clear prose with code examples. Assume the reader is a developer familiar with Rails but new to our codebase.
```

Why it works: Clear scope, specific sections, target audience defined.

**Bad Documentation Prompt:**

```
Write docs about the auth system.
```

Why it's bad: No scope, no structure, no audience.

## Reference Document Examples

**Good Reference (using plain paths):**

```
# Project Context

This is a Rails subscription management app.

## Architecture
- Authentication: app/services/auth/
- Payments: app/services/payments/ using Stripe
- Background jobs: app/jobs/ using Sidekiq

## Conventions
- Use RSpec with AAA pattern
- Services are single-purpose classes
- API uses JSON:API format

## Troubleshooting
For authentication errors, see docs/auth-troubleshooting.md
For payment issues, see docs/payment-debugging.md
```

Why it works: Concise essentials, points to detailed docs with plain paths.

**Bad Reference (forcing imports when not necessary):**

```
# Project Context

@docs/architecture.md
@docs/conventions.md
@docs/troubleshooting.md
@docs/payment-guide.md
@docs/testing-guide.md
```

Why it's bad: Forces all content into context immediately, bloats context window.

