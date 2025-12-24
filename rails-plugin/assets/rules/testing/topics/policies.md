---
paths: test/policies/**/*_test.rb
dependencies: []
---

# Policy Testing Patterns

Policy tests verify authorization rules.

## Test Structure

Group by user type (not by action):

```ruby
require "test_helper"

class AlbumPolicyTest < ActiveSupport::TestCase
  let(:album) { albums(:published) }
  let(:owner) { users(:artist) }
  let(:other_user) { users(:other_artist) }

  describe "for owner" do
    subject { described_class.new(owner, album) }

    it "allows all actions" do
      assert_policy subject, :show?
      assert_policy subject, :update?
      assert_policy subject, :destroy?
    end
  end

  describe "for other user" do
    subject { described_class.new(other_user, album) }

    it "allows only show" do
      assert_policy subject, :show?
      assert_policy_not subject, :update?
      assert_policy_not subject, :destroy?
    end
  end

  describe "for guest" do
    subject { described_class.new(nil, album) }

    it "allows only public actions" do
      assert_policy subject, :show?
      assert_policy_not subject, :create?
    end
  end
end
```

## Scope Testing

Test what data each user type can access:

```ruby
describe AlbumPolicy::Scope do
  let(:user) { users(:artist) }
  let(:scope) { described_class.new(user, Album).resolve }

  it "includes user's albums" do
    user_album = albums(:artist_album)
    assert_includes scope, user_album
  end

  it "includes published albums" do
    published = albums(:published)
    assert_includes scope, published
  end

  it "excludes other's drafts" do
    other_draft = albums(:other_draft)
    assert_not_includes scope, other_draft
  end
end
```

## Key Patterns

**Use `subject`**: Define policy instance once, test multiple actions
**Use helpers**: `assert_policy` and `assert_policy_not` from test/helpers/policy_helpers.rb
**Group by user type**: "for owner", "for guest", not "describe '#show?'"
**Test scopes separately**: Scope tests verify data filtering logic
