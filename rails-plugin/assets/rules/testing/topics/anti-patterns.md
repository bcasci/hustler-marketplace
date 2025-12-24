---
paths: test/**/*.rb
dependencies: []
---

# Testing Anti-Patterns

What NOT to test - common mistakes and how to avoid them.

## Don't Test Rails Framework

```ruby
# BAD - Testing Rails framework, not your code
describe 'attributes' do
  it 'has a name attribute' do
    assert_respond_to record, :name  # Testing Rails!
  end
end

# BAD - Testing basic ActiveRecord functionality
it 'stores data correctly' do
  record.name = 'test'
  assert_equal 'test', record.name  # Testing Rails!
end

# GOOD - Testing YOUR configuration
describe 'validations' do
  it 'requires name' do
    record.name = nil
    assert_not record.valid?
    assert_includes record.errors[:name], "can't be blank"
  end
end

# GOOD - Testing custom behavior
describe 'name normalization' do
  it 'capitalizes name on save' do
    record.name = 'john doe'
    record.save
    assert_equal 'John Doe', record.name
  end
end
```

## Don't Test Rails Associations

```ruby
# BAD - Testing that Rails associations work
it 'provides parent name through association' do
  assert_equal item.parent.name, 'Parent Name'  # Testing Rails!
end

# GOOD - Test actual business behavior
it 'preserves parent data at time of snapshot' do
  original_name = parent.name

  # Owner changes parent after snapshot
  parent.update!(name: 'Changed Name')
  parent.discard

  # Test that item still shows original parent data
  assert_equal original_name, item.parent_name_at_snapshot
end
```

## Never Test Private Methods

```ruby
# BAD - Testing private methods bypasses encapsulation
it 'checks unsafe paths' do
  # NEVER use send() to test private methods - tests implementation, not behavior
  assert analyzer.send(:unsafe_path?, '../etc/passwd')
end

# GOOD - Test through public interface
it 'filters unsafe paths from zip contents' do
  # Create fixture/setup that exercises the private method via public API
  paths = analyzer.metadata[:zip_contents].map { |e| e[:path] }
  assert_not_includes paths, '../etc/passwd'
end
```

If you need to test something only accessible via a private method, this signals:
1. Extract the logic to a separate, testable class/module
2. Test the behavior through public methods that use this logic
3. Create appropriate test fixtures that exercise the code path

## Never Use @Instance Variables in Tests

```ruby
# BAD - Never use @variables
before do
  @user = users(:example)  # WRONG
  @record = records(:one)  # WRONG
end

# GOOD - Always use let
let(:user) { users(:example) }
let(:record) { records(:one) }
```

## Don't Use Temporary Test Files

```ruby
# BAD - Creating temporary test files
before do
  @temp_file = Tempfile.new('test')
  @temp_file.write('test data')
  @temp_file.close
end

# GOOD - Use existing test files from fixtures
let(:test_file) { file_fixture('sample.txt') }
```

## General Anti-Patterns

- **NEVER use `rails runner` for testing** - Always use `bin/rails test`
- **NEVER use `send()` to test private methods** - Test through public interface
- **AVOID temporary test files** - Use existing test files
- **Write tests first (TDD)** - Default practice for all features
- **See failing tests before implementing** - Red-Green-Refactor cycle
- **NEVER use rails console for testing** - Write proper tests

## Test File Selection

**Rule:** Never create a test file without first showing evidence that no suitable test file exists

Before creating a new test file:

1. Check if a similar test file exists
2. Check if an existing test file can be extended
3. Only create new file if truly necessary

## Common Pattern Violations

### Over-Testing

```ruby
# BAD - Testing the same thing multiple ways
it 'has a title' do
  assert_respond_to @album, :title
end

it 'stores title' do
  @album.title = 'Test'
  assert_equal 'Test', @album.title
end

it 'validates title presence' do
  assert validate_presence_of(:title)
end

# GOOD - Just test the validation (the only custom behavior)
it { assert validate_presence_of(:title) }
```

### Testing Implementation Details

```ruby
# BAD - Testing method calls (implementation)
it 'calls calculate_total' do
  order.expects(:calculate_total).once
  order.save
end

# GOOD - Test the outcome (behavior)
it 'calculates total on save' do
  order.line_items << create(:line_item, price: 10)
  order.save
  assert_equal 10, order.total
end
```

### Testing Framework Behavior

```ruby
# BAD - Testing that validations work (framework behavior)
it 'is invalid without email' do
  user.email = nil
  assert_not user.valid?  # Testing Rails, not your code
end

# GOOD - Test your business rules
it 'requires email for account activation' do
  user.email = nil
  user.activate!
  assert_includes user.errors[:email], "can't be blank"
end
```

## Avoiding Brittle Tests

### Don't Rely on Fixture Data

```ruby
# BAD - Assumes fixture data
it 'finds published albums' do
  result = Album.search('Album')
  assert_includes result, albums(:one)  # Assumes :one is published
end

# GOOD - Explicit test data
describe '.search' do
  let(:album) { albums(:one) }
  let(:search_term) { 'UniqueAlbum2024' }

  before do
    album.update!(title: search_term, status: 'published')
  end

  it 'finds published albums' do
    result = Album.search(search_term)
    assert_equal [album], result
  end
end
```

### Don't Hardcode IDs or Timestamps

```ruby
# BAD - Hardcoded IDs
it 'finds album by id' do
  album = Album.find(1)  # Brittle!
  assert_equal 'Title', album.title
end

# GOOD - Use fixtures or let
let(:album) { albums(:example) }

it 'finds album by id' do
  assert_equal 'Title', album.title
end
```

## Test Smell Detection

Signs your test is problematic:

1. **Can't fail** - Comment out code, test still passes
2. **Too complex** - More than 5 lines of setup
3. **Brittle** - Breaks when unrelated code changes
4. **Slow** - Takes >1 second to run
5. **Unclear** - Can't tell what broke from failure message

**If you see these smells, refactor or delete the test.**

## Quick Anti-Pattern Reference

| Anti-Pattern | Why Bad | Instead |
|--------------|---------|---------|
| Testing Rails | Wastes time | Test YOUR code |
| @instance vars | Not lazy, harder to debug | Use `let` |
| Mocking everything | Brittle, hides bugs | Use real objects |
| Testing private methods | Tests implementation | Test through public API |
| Complex setup | Hard to understand | Extract helpers |
| Hardcoded data | Brittle | Use fixtures/let |
| Testing implementation | Breaks on refactor | Test behavior |
| No arrange-act-assert | Unclear structure | Use AAA pattern |
