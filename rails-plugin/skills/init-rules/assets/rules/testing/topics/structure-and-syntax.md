---
paths: "test/**/*.rb"
dependencies: []
---

# Test Organization and Clarity

Universal principles for organizing and writing clear, maintainable tests.

---

## Test Setup: Clarity Over Performance

Test setup code should prioritize clarity and debuggability over performance optimization.

**Prefer explicit operations:**

```ruby
before do
  Parent.find_each do |parent|
    parent.children.reload
    parent.children.each { |child| child.update_columns(status: 'draft') }
  end
end
```

**Avoid premature optimization:**

```ruby
before do
  # Harder to debug, unclear what's happening per-record
  Child.joins(:parent).update_all(status: 'draft')
end
```

**Rationale:**

- Test setup runs once per test - performance is negligible
- Explicit operations are easier to debug when tests fail
- Clear iteration makes test intent obvious
- Prevents flaky tests from hidden side effects

**Exception:** Only optimize test setup if test suite runtime demonstrably slow (>30s) AND profiled setup as bottleneck.

---

## Test Organization

### Organize by Action or Context

Organize test sections by **action or context**, not by feature:

```ruby
# ✅ GOOD - Organized by action/context
class RecordsTest < TestCase
  describe 'showing' do  # The action/context
    describe 'navigation tabs' do  # Feature within that context
    describe 'record details' do  # Another feature within same context
  end

  describe 'creating' do  # Different action/context
    describe 'when visitor is not owner' do
    describe 'when visitor is owner' do
  end
end

# ❌ BAD - Random feature-based organization
class RecordsTest < TestCase
  describe 'navigation tabs' do  # Feature without context
  describe 'when user has role X' do  # Mixed context
    describe 'showing' do  # Action buried inside
  end
end
```

**Common action/context patterns:**

- `showing` - Viewing/displaying content
- `creating` - Form submissions and object creation
- `updating` - Editing existing objects
- `destroying` - Deletion actions
- `searching` - Search and filter operations
- `processing` - Background jobs and async operations

**Nest features under actions:**

When the same action applies to multiple features, nest them:

```ruby
describe 'showing' do
  let(:shared_variables) { ... }  # Shared setup for all showing tests

  describe 'basic view' do
  describe 'navigation tabs' do
  describe 'related items' do
end
```

---

## Keep Tests Focused

One assertion focus per test:

```ruby
# ❌ BAD - Too many assertions in one test
it 'creates audit record' do
  audit = Audit.create!(...)
  assert audit.persisted?
  assert_equal 'test', audit.event_type
  assert_equal 'user@example.com', audit.recipient_email
  assert audit.payload.present?
  assert_nil audit.error_message
end

# ✅ GOOD - Split into focused tests
describe 'creating audit record' do
  let(:audit) { Audit.create!(valid_attributes) }

  it 'persists the record' do
    assert audit.persisted?
  end

  it 'sets the correct attributes' do
    assert_equal 'test', audit.event_type
    assert_equal 'user@example.com', audit.recipient_email
  end

  it 'stores the payload' do
    assert audit.payload.present?
  end
end
```

---

## Avoid Testing Variations of the Same Behavior

When behavior is identical except for configuration/initial state, test the behavior once and test variations separately:

```ruby
# ❌ BAD - Duplicating entire flow to test different defaults
describe 'when user has role A' do
  it 'defaults to Tab X and allows navigation' do
    visit record_path(role_a_user)
    assert_selector 'a.active', text: 'Tab X'  # Different default

    click_link 'Tab Y'  # Same navigation behavior
    assert_selector 'a.active', text: 'Tab Y'
    click_link 'Tab Z'
    assert_selector 'a.active', text: 'Tab Z'
  end
end

# ✅ GOOD - Test behavior once, test variations separately
it 'defaults to Tab X for role A' do
  visit record_path(role_a_user)
  assert_selector 'a.active', text: 'Tab X'
end

it 'defaults to Tab Z for role B' do
  visit record_path(role_b_user)
  assert_selector 'a.active', text: 'Tab Z'
end

it 'allows navigation between tabs' do
  visit record_path(role_a_user)  # Behavior same for any role

  click_link 'Tab Y'
  assert_selector 'a.active', text: 'Tab Y'

  click_link 'Tab Z'
  assert_selector 'a.active', text: 'Tab Z'
end
```

---

## Make Tests Explicit

When testing search or filtering functionality, use explicit, unique values instead of relying on baseline test data:

```ruby
# ❌ BAD - Relies on test data that might change
it 'finds records by name' do
  result = Record.search('Example')  # Brittle!
  assert_includes result, records(:one)
end

# ✅ GOOD - Explicit test data with unique values
describe '.search' do
  let(:record) { records(:one) }
  let(:search_term) { 'UniqueTestRecord2024' }

  before do
    record.update!(name: search_term)
  end

  it 'finds records by name' do
    result = Record.search(search_term)
    assert_equal [record], result
  end
end
```

**When to make test data explicit:**

- Search/filter tests - Update attributes explicitly so test is clear
- Tests sensitive to specific values - Don't assume baseline data values
- Edge cases - Set the exact boundary condition you're testing

**When baseline data is sufficient:**

- Testing relationships (`user.organization`)
- Testing basic record existence
- Testing associations and traversals

---

## Test Smell Checklist

Before committing any test, ask:

1. **Does this test actually test what it claims?**
2. **Is the test complexity appropriate?** (Simple model = simple tests)
3. **Am I testing the same thing twice?**
4. **Can this test actually fail?** (If not, delete it)
5. **Am I testing my code or the framework?** (Test your code only)

---

## Best Practices

1. **Test one thing** - Each test has single assertion focus
2. **Descriptive names** - Clear test descriptions
3. **Explicit setup** - Don't hide setup in baseline data when values matter
4. **Right-size tests** - Match test complexity to code complexity
5. **Organize by action** - Group tests by what's being done, not what feature
6. **Avoid duplication** - Test behavior once, test variations separately
7. **Make tests explicit** - Use unique test data for search/filter tests
