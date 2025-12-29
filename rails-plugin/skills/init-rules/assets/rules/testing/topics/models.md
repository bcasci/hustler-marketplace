---
paths: "test/models/**/*_test.rb"
dependencies: []
---

# Model Testing Patterns

Model tests focus on validations, associations, scopes, and business logic methods unique to the model.

## MINIMAL Model Test Template

```ruby
# TEMPLATE: Copy this for new model tests
require 'test_helper'

class ExampleTest < ActiveSupport::TestCase
  # subject can be either a fixture or .new() - depends on test needs:
  # - Use fixture when testing behavior of existing records
  # - Use .new() when testing initialization/validation or need specific attributes
  subject { examples(:one) }  # OR subject { Example.new(organization: organizations(:one), name: 'Test') }

  describe 'associations' do
    it { assert belong_to(:organization) }
    it { assert have_many(:items).dependent(:destroy) }
  end

  describe 'validations' do
    # Simple validations - NO nested describes needed
    it { assert validate_presence_of(:name) }
    it { assert validate_uniqueness_of(:name).scoped_to(:organization_id) }
    it { assert validate_numericality_of(:amount).is_greater_than(0) }

    # ONLY use nested describe for complex conditional validations
    describe 'price when published' do
      it 'requires price for published items' do
        subject.listing_state = 'published'
        subject.price = nil
        assert_not subject.valid?
        assert_includes subject.errors[:price], "can't be blank"
      end
    end
  end

  describe 'scopes' do
    # For simple scopes:
    describe '.active' do
      subject { Example.active }
      it 'returns only active records' do
        assert_equal 2, subject.count
      end
    end

    # For complex scopes needing setup:
    describe '.with_recent_activity' do
      let(:recent) { examples(:recent) }
      let(:old) { examples(:old) }

      before do
        recent.update_columns(last_activity_at: 1.day.ago)
        old.update_columns(last_activity_at: 1.year.ago)
      end

      it 'returns records with activity in last 30 days' do
        assert_includes Example.with_recent_activity, recent
        assert_not_includes Example.with_recent_activity, old
      end
    end
  end

  describe 'enums' do
    describe 'status' do
      it {
        assert define_enum_for(:status).with_values(
          pending: 0,
          active: 1,
          inactive: 2
        ).with_default(:pending)
      }
    end
  end
end
```

## Right-Size Your Tests

Match test complexity to model complexity:

### Simple Models (< 50 lines, few methods):

- Audit logs, simple lookups, basic records
- Target: 30-60 lines of tests
- Focus: Core functionality only

### Example - Simple Audit Model:

```ruby
class NotificationAuditTest < ActiveSupport::TestCase
  subject { notification_audits(:one) }

  describe 'validations' do
    it { assert validate_presence_of(:event_type) }
  end

  # Test scopes concisely when possible
  describe 'key scopes' do
    # Assuming data exists
    subject { NotificationAudit.for_email('test@example.com') }

    # Alternatives:
    # before { NotificationAudit.create(email: 'test@example.com', ...) }
    # OR: subject { NotificationAudit.for_email(notifications(:some_name).email) }

    it 'finds by email' do
      assert_equal 1, subject.count
    end
  end
end
```

### Complex Models (100+ lines, business logic):

- Core domain models with behavior
- Target: 100-200 lines of tests
- Focus: Business logic, edge cases, integrations

## Model-Specific Anti-Patterns

### DON'T Test Rails Attributes

**Rule:** Never test that Active Record provides getters/setters for database columns. The schema guarantees this.

Test only YOUR custom behavior (normalization, callbacks, calculations).

```ruby
# NEVER - Testing Rails provides attributes
describe 'attributes' do
  it 'has a name attribute' do
    assert_respond_to record, :name  # Useless!
  end

  it 'stores location' do
    audit.location = 'test'
    assert_equal 'test', audit.location  # Useless!
  end
end

# GOOD - Test YOUR custom behavior
describe 'name normalization' do
  it 'capitalizes name on save' do
    record.name = 'john doe'
    record.save
    assert_equal 'John Doe', record.name
  end
end
```

### DON'T Nest Simple Validations

```ruby
# BAD - Unnecessary nesting
describe 'validations' do
  describe 'event_type' do
    it { assert validate_presence_of(:event_type) }
  end
end

# GOOD - Flat structure
describe 'validations' do
  it { assert validate_presence_of(:event_type) }
  it { assert validate_uniqueness_of(:email).case_insensitive }
end
```

## Validation Testing

### Conditional Validations

```ruby
describe 'conditional validations' do
  let(:album) { albums(:draft) }

  it 'requires metadata when published' do
    album.published_at = Time.current

    assert_not album.valid?
    assert_includes album.errors[:metadata], "artist_name is required"
  end
end
```

## Association Testing

### Basic Associations

```ruby
describe 'associations' do
  let(:album) { albums(:published) }

  it 'belongs to organization' do
    assert_instance_of Organization, album.organization
    assert_equal organizations(:org_one), album.organization
  end

  it 'has many tracks' do
    album = albums(:with_tracks)
    assert_respond_to album, :tracks
    assert_equal 3, album.tracks.count
  end
end
```

### Dependent Associations

```ruby
describe 'dependent associations' do
  let(:album) { albums(:with_tracks) }

  it 'destroys dependent records' do
    track_ids = album.tracks.pluck(:id)

    assert_difference ['Album.count', 'Track.count'], [-1, -3] do
      album.destroy
    end

    assert Track.where(id: track_ids).empty?
  end
end
```

## Scope Testing Patterns

```ruby
describe 'scopes' do
  describe '.published' do
    let(:published_album) { albums(:published) }
    let(:draft_album) { albums(:draft) }

    before do
      # Set known states explicitly
      published_album.update_columns(published_at: 1.day.ago)
      draft_album.update_columns(published_at: nil)
    end

    it 'returns only published albums' do
      assert_equal [published_album], Album.published.to_a
    end
  end
end
```

**Scope Testing Guidelines:**

- Use fixtures when they fit the scenario
- Set up known states explicitly in `before` block
- Use clear assertions: `assert_equal`, `assert_includes`, `assert_equal N, result.count`
- Don't over-test edge cases unless critical

### Choosing Test Style

- Simple scope (no setup) → Concise style with subject
- Complex setup → Use let/before blocks
- Edge cases → Only if critical

### Parameterized Scopes

```ruby
describe '.by_genre' do
  let(:rock_album) { albums(:rock_album) }
  let(:jazz_album) { albums(:jazz_album) }

  before do
    rock_album.update_columns(genre: 'rock')
    jazz_album.update_columns(genre: 'jazz')
  end

  it 'filters by the given genre' do
    assert_equal [rock_album], Album.by_genre('rock')
  end
end
```

## Callback Testing

### Before Callbacks

```ruby
describe 'callbacks' do
  it 'generates slug before validation' do
    album = Album.new(title: "My Great Album!")
    album.valid?

    assert_equal "my-great-album", album.slug
  end
end
```

### Conditional Callbacks

```ruby
describe 'conditional callbacks' do
  let(:album) { albums(:draft) }

  it 'sends notification only on first publish' do
    # Track notification calls
    notification_count = 0
    NotificationService.stub :album_published, ->(*_args) { notification_count += 1 } do
      album.publish! # First publish
      album.update!(title: "Updated") # Should not trigger

      assert_equal 1, notification_count
    end
  end
end
```

## Method Testing

### Instance Methods

```ruby
describe 'instance methods' do
  let(:album) { albums(:with_tracks) }

  it 'calculates total duration' do
    expected = album.tracks.sum(:duration)
    assert_equal expected, album.total_duration
  end

  it 'formats price for display' do
    album = albums(:published)
    album.price_cents = 999

    assert_equal "$9.99", album.formatted_price
  end
end
```

### Business Logic

```ruby
describe 'business logic' do
  let(:album) { albums(:published) }
  let(:order_items) { [order_items(:album_purchase), order_items(:album_purchase_two)] }

  it 'calculates royalties correctly' do
    royalties = album.calculate_royalties(order_items)

    assert_equal 150, royalties[:artist_share]
    assert_equal 50, royalties[:platform_fee]
  end
end
```

## State Machine Testing

```ruby
describe 'state transitions' do
  let(:album) { albums(:draft) }

  it 'transitions through states correctly' do
    assert album.draft?
    assert album.can_publish?

    album.publish!
    assert album.published?
    assert_not album.can_publish?
  end

  it 'prevents invalid transitions' do
    album = albums(:archived)

    assert_raises(StateMachine::InvalidTransition) do
      album.publish!
    end
  end
end
```

## STI (Single Table Inheritance) Testing

```ruby
describe 'STI behavior' do
  it 'uses correct STI type' do
    album = Album.create!(valid_attributes)
    track = Track.create!(valid_attributes)

    assert_equal "Album", album.type
    assert_equal "Track", track.type
    assert_equal "products", album.class.table_name
    assert_equal "products", track.class.table_name
  end
end
```

## Monetization Testing

```ruby
describe 'money attributes' do
  let(:album) { albums(:published) }

  it 'works with money gem' do
    album.price = Money.new(1599, "USD")

    assert_equal 1599, album.price_cents
    assert_equal "USD", album.price_currency
    assert_equal "$15.99", album.price.format
  end
end
```

## Edge Case Testing

```ruby
describe 'edge cases' do
  it 'handles nil values gracefully' do
    album = Album.new(metadata: nil)

    assert_nil album.artist_name
    assert_equal [], album.tags
    assert_equal 0, album.total_duration
  end

  it 'handles empty associations' do
    album = albums(:no_tracks)

    assert_empty album.tracks
    assert_equal 0, album.tracks_count
    assert_nil album.latest_track
  end
end
```

## Testing Concerns

```ruby
# Test concern behavior in isolation
class SearchableTest < ActiveSupport::TestCase
  describe 'Searchable concern' do
    it 'includes searchable in models' do
      [Album, Organization, Track].each do |model|
        assert_includes model.included_modules, Searchable
        assert_respond_to model, :search
      end
    end
  end
end
```

## Test Helpers

```ruby
# From test/support/model_helper.rb
assert_valid album # Better than assert album.valid?

# Custom assertions
def assert_monetized(model, attribute)
  assert_respond_to model, attribute
  assert_respond_to model, "#{attribute}_cents"
  assert_respond_to model, "#{attribute}_currency"
end
```
