---
paths: app/policies/**/*.rb
dependencies: [pundit]
---

# Pundit - Writing Policies

---

## Core Pattern

```ruby
class AlbumPolicy < ApplicationPolicy
  def show?
    record.published? || user_is_owner?
  end

  def create?
    user_can_manage_organization?
  end

  def update?
    user_is_owner?
  end

  def destroy?
    user_is_owner? && record.draft?
  end

  private

  def user_is_owner?
    user.present? && record.organization == user_organization
  end

  def user_can_manage_organization?
    user.present? && user.organization_memberships.exists?(
      organization: record.organization,
      role: ["admin", "artist"]
    )
  end
end
```

---

## Policy Scopes

Filter collections based on permissions:

```ruby
class AlbumPolicy < ApplicationPolicy
  class Scope < ApplicationPolicy::Scope
    def resolve
      if user.nil?
        scope.published.salable
      elsif user.admin?
        scope.all
      else
        scope.where(organization: user.organizations)
             .or(scope.published.salable)
      end
    end
  end
end
```

**Controllers call:** `@albums = policy_scope(Album)`

**Pattern:**

- Scope class nested inside policy
- `resolve` method returns filtered collection
- Different logic based on user role/state

---

## Index Actions

In scoped contexts (manage/, account/), `index?` usually returns `true`:

```ruby
module Manage
  class AlbumPolicy < ApplicationPolicy
    class Scope < Scope
      def resolve
        Album.where(organization: user.organization).kept
      end
    end

    def index?
      true  # Authentication sufficient, scope filters data
    end
  end
end
```

**Pattern:** `index?` = can user access? Scope = what can user see?

---

## Custom Actions

```ruby
class AlbumPolicy < ApplicationPolicy
  def publish?
    update? && record.draft?
  end

  def archive?
    update? && record.published?
  end
end
```

**Controllers call:** `authorize @album, :publish?`

---

## Conditional UI Methods

For view-level authorization checks:

```ruby
class AlbumPolicy < ApplicationPolicy
  def show?
    true  # Everyone can view
  end

  def manage?
    user_is_owner?  # For conditional edit/delete UI
  end
end
```

**Views call:** `policy(@album).manage?` to show/hide UI elements

---

## ApplicationPolicy Helpers

Base helpers available in all policies:

```ruby
protected

def user_organization
  @user_organization ||= user&.organizations&.first
end

def user_in_organization?
  user.present? &&
  user.organization_memberships.exists?(organization: record.organization)
end
```

**Location:** `app/policies/application_policy.rb`

---

## Testing Policies

```ruby
describe AlbumPolicy do
  let(:user) { users(:artist) }
  let(:album) { albums(:user_album) }
  let(:policy) { AlbumPolicy.new(user, album) }

  it "allows owner to update" do
    assert policy.update?
  end

  it "denies non-owner from updating" do
    other_user = users(:other_artist)
    policy = AlbumPolicy.new(other_user, album)
    refute policy.update?
  end
end
```

---

## Discovery

**Policy examples:**

```
Glob "app/policies/**/*.rb"
Read app/policies/application_policy.rb
```

**Scope patterns:**

```
Grep "class Scope" app/policies/**/*.rb
```
