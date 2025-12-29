---
paths: "test/models/**/*_test.rb"
dependencies: [shoulda-matchers]
---

# Shoulda Matchers

Convenience matchers for Rails validations and associations.

---

## Basic Usage

```ruby
require 'test_helper'

class AlbumTest < ActiveSupport::TestCase
  describe 'Album' do
    describe 'validations' do
      it { assert validate_presence_of(:title) }
      it { assert validate_uniqueness_of(:title).scoped_to(:user_id) }
      it { assert validate_numericality_of(:price_cents).is_greater_than(0) }
    end

    describe 'associations' do
      it { assert belong_to(:user) }
      it { assert have_many(:tracks).dependent(:destroy) }
    end
  end
end
```

---

## Validation Matchers

### Presence

```ruby
it { assert validate_presence_of(:title) }
it { assert validate_presence_of(:description).on(:update) }
```

### Uniqueness

```ruby
it { assert validate_uniqueness_of(:email) }
it { assert validate_uniqueness_of(:title).scoped_to(:user_id) }
it { assert validate_uniqueness_of(:slug).case_insensitive }
```

### Numericality

```ruby
it { assert validate_numericality_of(:price_cents) }
it { assert validate_numericality_of(:price_cents).is_greater_than(0) }
it { assert validate_numericality_of(:quantity).only_integer }
```

### Length

```ruby
it { assert validate_length_of(:title).is_at_most(100) }
it { assert validate_length_of(:description).is_at_least(10) }
```

### Inclusion

```ruby
it { assert validate_inclusion_of(:status).in_array(['draft', 'published']) }
```

### Format

```ruby
it { assert allow_value('user@example.com').for(:email) }
it { assert_not allow_value('invalid').for(:email) }
```

---

## Association Matchers

### Belongs To

```ruby
it { assert belong_to(:user) }
it { assert belong_to(:organization).required }
it { assert belong_to(:category).optional }
it { assert belong_to(:category).class_name('Category') }
```

**Supported options:** `.class_name()`, `.optional`, `.required`, `.dependent()`, `.foreign_key()`, `.autosave()`, `.touch()`, `.counter_cache()`

### Has Many

```ruby
it { assert have_many(:tracks) }
it { assert have_many(:tracks).dependent(:destroy) }
it { assert have_many(:tracks).class_name('Track') }
it { assert have_many(:tags).through(:taggings) }
```

**Supported options:** `.dependent()`, `.through()`, `.source()`, `.class_name()`, `.foreign_key()`, `.autosave()`, `.validate()`, `.inverse_of()`

### Has One

```ruby
it { assert have_one(:profile) }
it { assert have_one(:profile).dependent(:destroy) }
it { assert have_one(:profile).class_name('UserProfile') }
```

**Supported options:** `.class_name()`, `.dependent()`, `.foreign_key()`, `.autosave()`, `.inverse_of()`, `.required`

---

## Limitations

Shoulda matchers **cannot test:**

### 1. Conditional Validations

Rails conditional validations (`:if`, `:unless` options) are not supported.

```ruby
# YOUR CODE
validates :price, presence: true, if: :published?

# ❌ NO MATCHER EXISTS
# There is no Shoulda matcher for this

# ✅ WRITE EXPLICIT TEST
describe 'price validation' do
  describe 'when published' do
    let(:album) { albums(:published) }

    it 'requires price' do
      album.price_cents = nil
      assert_not album.valid?
      assert_includes album.errors[:price_cents], "can't be blank"
    end
  end

  describe 'when draft' do
    let(:album) { albums(:draft) }

    it 'allows blank price' do
      album.price_cents = nil
      assert album.valid?
    end
  end
end
```

### 2. Custom Validation Methods

Custom validate methods have no matcher support.

```ruby
# YOUR CODE
validate :custom_business_rule

# ❌ NO MATCHER EXISTS
# Cannot test with Shoulda

# ✅ WRITE EXPLICIT TEST
it 'validates custom business rule' do
  album.custom_field = 'invalid'
  assert_not album.valid?
  assert_includes album.errors[:custom_field], 'must meet criteria'
end
```

### 3. Scoped Associations

Associations with lambda scopes/conditions have no matcher support.

```ruby
# YOUR CODE
has_many :kept_tracks, -> { kept }, class_name: 'Track'

# ❌ NO MATCHER EXISTS
# Cannot test the scope with Shoulda

# ✅ WRITE EXPLICIT TEST
it 'returns only kept tracks' do
  album = albums(:with_discarded_tracks)
  assert_equal 5, album.kept_tracks.count
  assert_not album.kept_tracks.any?(&:discarded?)
end
```

---

## Discovery

**Find Shoulda matcher usage:**

```
Grep "assert validate_" test/models/**/*_test.rb
Grep "assert belong_to" test/models/**/*_test.rb
Grep "assert have_many" test/models/**/*_test.rb
```

**Shoulda matchers documentation:**

- [GitHub Repository](https://github.com/thoughtbot/shoulda-matchers)
- [Official Documentation](https://matchers.shoulda.io/)
