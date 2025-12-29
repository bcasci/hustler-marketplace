---
paths: "test/policies/**/*.rb"
dependencies: [pundit]
---

# Pundit - Policy Testing

Testing authorization policies.

---

## Basic Policy Test

Test policy methods directly:

```ruby
# test/policies/album_policy_test.rb
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

  it "allows everyone to view public albums" do
    public_album = albums(:published)
    guest_policy = AlbumPolicy.new(nil, public_album)
    assert guest_policy.show?
  end
end
```

---

## Testing Policy Scopes

Test scoped queries:

```ruby
describe AlbumPolicy::Scope do
  let(:user) { users(:artist) }
  let(:scope) { AlbumPolicy::Scope.new(user, Album.all) }

  it "returns user's albums plus public albums" do
    user_album = albums(:user_album)
    public_album = albums(:published)
    private_album = albums(:other_private)

    result = scope.resolve

    assert_includes result, user_album
    assert_includes result, public_album
    refute_includes result, private_album
  end

  it "returns all albums for admins" do
    admin = users(:admin)
    scope = AlbumPolicy::Scope.new(admin, Album.all)

    assert_equal Album.count, scope.resolve.count
  end

  it "returns only public albums for guests" do
    scope = AlbumPolicy::Scope.new(nil, Album.all)

    result = scope.resolve
    assert result.all?(&:published?)
  end
end
```

---

## Testing Custom Actions

```ruby
describe "custom policy actions" do
  let(:user) { users(:artist) }
  let(:album) { albums(:draft) }
  let(:policy) { AlbumPolicy.new(user, album) }

  it "allows publishing drafts" do
    assert policy.publish?
  end

  it "denies publishing already published albums" do
    album.update!(status: :published)
    refute policy.publish?
  end

  it "allows archiving published albums" do
    album.update!(status: :published)
    assert policy.archive?
  end
end
```

---

## Testing Role-Based Access

```ruby
describe "role-based access" do
  it "admins can do everything" do
    admin = users(:admin)
    album = albums(:any)
    policy = AlbumPolicy.new(admin, album)

    assert policy.show?
    assert policy.create?
    assert policy.update?
    assert policy.destroy?
  end

  it "guests can only view public content" do
    public_album = albums(:published)
    private_album = albums(:draft)

    public_policy = AlbumPolicy.new(nil, public_album)
    private_policy = AlbumPolicy.new(nil, private_album)

    assert public_policy.show?
    refute private_policy.show?
    refute public_policy.create?
  end
end
```

---

## Testing Multi-Tenant Policies

```ruby
describe "multi-tenant authorization" do
  it "users can only access their organization's albums" do
    user = users(:artist)
    org_album = albums(:user_album)
    other_org_album = albums(:other_org_album)

    assert AlbumPolicy.new(user, org_album).update?
    refute AlbumPolicy.new(user, other_org_album).update?
  end
end
```
