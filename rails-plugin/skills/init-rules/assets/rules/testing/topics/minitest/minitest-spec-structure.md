---
paths: "test/**/*_test.rb"
dependencies: [minitest-spec-rails]
---

# Minitest Spec Syntax

---

## Class-Based Structure

```ruby
require 'test_helper'

class AlbumTest < ActiveSupport::TestCase
  describe 'Album' do
    # Nested describe blocks for organization
    describe '#publish' do
      it 'marks album as published' do
        # test implementation
      end
    end
  end
end
```

**Rules:**

- Class name: `[Model]Test`, `[Controller]Test`, `[Job]Test`
- Inherit from appropriate base: `ActiveSupport::TestCase`, `ActionDispatch::IntegrationTest`, `ApplicationSystemTestCase`
- One top-level `describe` block matching class name
- Nested `describe` blocks for methods or contexts

---

## Spec Syntax

**Use describe/it syntax (not def test_):**

```ruby
# ✅ GOOD
describe 'Album' do
  it 'validates presence of title' do
    album = Album.new
    assert_not album.valid?
  end
end

# ❌ AVOID
def test_validates_presence_of_title
  album = Album.new
  assert_not album.valid?
end
```

---

## Test Setup

### let() - Lazy Evaluation

```ruby
describe 'Album' do
  let(:album) { albums(:published) }
  let(:user) { users(:artist) }

  it 'has correct owner' do
    assert_equal user, album.user
  end
end
```

**When to use:**
- Most test data (evaluated lazily)
- Data only needed in specific tests
- Clean, declarative setup

### before() - Eager Setup

```ruby
describe 'with published albums' do
  before do
    @album = albums(:published)
    @album.update(featured: true)
  end

  it 'appears in featured list' do
    assert_includes Album.featured, @album
  end
end
```

**When to use:**
- Setup required for ALL tests in block
- State modifications needed before each test
- Actions with side effects

### subject() - Primary Test Object

```ruby
describe 'Album#publish' do
  subject { album.publish }

  let(:album) { albums(:draft) }

  it 'marks as published' do
    subject
    assert album.published?
  end
end
```

**When to use:**
- Testing single method/action repeatedly
- Same operation tested with different assertions
- Improves readability when clear

---

## Assertion Syntax

**Use assert/assert_not (not refute):**

```ruby
# ✅ GOOD - Consistent assertions
assert album.published?
assert_not album.draft?
assert_equal 'Published', album.status
assert_not_equal 'Draft', album.status

# ❌ AVOID - refute methods (inconsistent)
refute album.draft?
refute_equal 'Draft', album.status

# ❌ AVOID - double negatives
assert_not album.unpublished?
```

**Common assertions:**

```ruby
# Equality
assert_equal expected, actual
assert_not_equal not_expected, actual

# Presence
assert album.present?
assert_nil value
assert_not_nil value

# Collections
assert_includes collection, item
assert_not_includes collection, item
assert_empty collection
assert_not_empty collection

# Exceptions
assert_raises(ErrorClass) { code }
assert_nothing_raised { code }

# Predicates
assert album.published?
assert_not album.draft?

# Matching
assert_match /pattern/, string
assert_no_match /pattern/, string
```

---

## Model Test Template

```ruby
require 'test_helper'

class AlbumTest < ActiveSupport::TestCase
  describe 'Album' do
    let(:album) { albums(:published) }

    describe 'associations' do
      it 'belongs to user' do
        assert_respond_to album, :user
      end
    end

    describe 'validations' do
      it 'requires title' do
        album.title = nil
        assert_not album.valid?
        assert_includes album.errors[:title], "can't be blank"
      end
    end

    describe '#publish' do
      let(:draft) { albums(:draft) }

      it 'marks as published' do
        draft.publish
        assert draft.published?
      end
    end
  end
end
```

---

## Integration Test Template

```ruby
require 'test_helper'

class AlbumsFlowTest < ActionDispatch::IntegrationTest
  describe 'Albums flow' do
    let(:user) { users(:artist) }

    before { sign_in_as(user) }

    it 'creates and publishes album' do
      get new_album_path
      assert_response :success

      post albums_path, params: { album: { title: 'New Album' } }
      assert_response :redirect

      album = Album.last
      assert_equal 'New Album', album.title
    end
  end
end
```

---

## System Tests

System tests require browser automation tools. See:
- `system.md` for when/how to organize system tests
- `capybara-system-tests.md` for complete Capybara test structure

---

## Nested Contexts

**Organize by scenarios:**

```ruby
describe 'Album#publish' do
  describe 'when draft' do
    let(:album) { albums(:draft) }

    it 'publishes successfully' do
      assert album.publish
    end
  end

  describe 'when already published' do
    let(:album) { albums(:published) }

    it 'returns false' do
      assert_not album.publish
    end
  end
end
```

---

## Discovery

**Find Minitest structure examples:**

```
Grep "describe.*do" test/**/*_test.rb
```

**Find let/before usage:**

```
Grep "^\s+let\(:" test/**/*_test.rb
Grep "^\s+before do" test/**/*_test.rb
```
