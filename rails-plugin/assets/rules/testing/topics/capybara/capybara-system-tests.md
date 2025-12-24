---
paths: test/system/**/*_test.rb
dependencies: [capybara]
---

# Capybara System Test DSL

Browser automation DSL for system tests.

---

## Complete Test Structure

```ruby
require 'test_helper'

class AlbumsTest < ApplicationSystemTestCase
  describe 'album management' do
    let(:user) { users(:artist) }
    let(:album) { albums(:published) }

    before { passwordless_sign_in(user) }

    it 'creates album' do
      visit new_album_path

      fill_in 'Title', with: 'New Album'
      fill_in 'Price', with: '9.99'
      click_button 'Create Album'

      assert_text 'Album was successfully created'
      assert_current_path album_path(Album.last)
    end

    it 'edits album' do
      visit album_path(album)

      click_link 'Edit'
      fill_in 'Title', with: 'Updated Title'
      click_button 'Update Album'

      assert_text 'Album was successfully updated'
      assert_text 'Updated Title'
    end
  end

  describe 'discovering through genres' do
    let(:genre) { genres(:rock) }

    it 'completes discovery-to-purchase journey' do
      visit genres_path

      within 'turbo-frame#genres' do
        click_link album.name
      end

      assert_text album.artist_name
      click_button 'Add to Cart'
      assert_text 'Cart (1)'
    end
  end
end
```

**Structure notes:**
- Inherit from `ApplicationSystemTestCase`
- Use `describe/it/let/before` for organization (see system.md for when/how to organize)
- Group by user journeys or actions
- Test complete user workflows, not isolated clicks

---

## Navigation

```ruby
visit root_path
visit album_path(album)
visit new_album_path
```

---

## Element Interaction

### Clicking

```ruby
click_link 'Edit'
click_button 'Save'
click_on 'Album Title'  # Works for links or buttons

# With specific element
find('article', text: 'Specific Album').click
```

### Form Input

```ruby
# Text fields
fill_in 'Title', with: 'Album Name'
fill_in 'Email', with: 'user@example.com'

# Selects
select 'Rock', from: 'Genre'

# File uploads
attach_file 'Cover Image', file_fixture('album_cover.jpg')

# Checkboxes
check 'Published'
uncheck 'Featured'

# Radio buttons
choose 'Option 1'
```

---

## Assertions

### Text Content

```ruby
assert_text 'Expected text'
assert_no_text 'Should not appear'

# With wait option
assert_text 'Async content', wait: 5
```

### Element Presence

```ruby
assert_selector 'a.button.primary'
assert_selector 'article', text: 'Album Title'
assert_no_selector '.error-message'

# CSS selectors
assert_selector 'li.background.small-round', text: album.name
assert_selector 'turbo-frame#genres'
```

### Page State

```ruby
assert_current_path album_path(album)
assert_response :success
```

---

## Scoping

### Within Blocks

```ruby
within '#album-section' do
  click_link 'Edit'
  assert_text album.title
end

within 'turbo-frame#genres' do
  click_link album.name
end

# With DOM ID helper
within "##{dom_id(album)}" do
  click_link 'Delete'
end
```

---

## Finding Elements

### Finders

```ruby
# Basic finders
find('article', text: 'Album Title')
find('#album-123')
find('.button.primary')

# First/last
first('article').click
all('li').last.click

# Count
assert_equal 5, all('article').count
```

---

## Waiting

### Implicit Waiting

```ruby
# Capybara waits automatically for assertions
assert_text 'Loaded content'  # Waits up to default timeout

# Custom wait time
assert_text 'Async content', wait: 10
```

### Explicit Waiting

```ruby
# ❌ AVOID - Never use sleep
sleep 2

# ✅ GOOD - Use assertions with wait
assert_text 'Content loaded', wait: 5
```

---

## Dialogs

### Confirm/Alert

```ruby
accept_confirm { click_button 'Delete' }
dismiss_confirm { click_button 'Delete' }

accept_alert { click_button 'Warning' }
```

### Prompts

```ruby
accept_prompt(with: 'User input') { click_button 'Prompt' }
```

---

## Element Selection Priority

**1. Semantic Capybara methods (prefer):**

```ruby
click_link 'Edit'
click_button 'Save'
fill_in 'Email', with: 'user@example.com'
```

**2. Text-based finders:**

```ruby
click_on 'Album Title'
find('article', text: 'Specific Album').click
```

**3. CSS classes (BeerCSS patterns - grep existing tests first):**

```ruby
find('li.background.small-round', text: album.name).click
assert_selector 'a.button.primary', text: 'Edit'
```

**4. DOM ID (Rails dom_id helper):**

```ruby
within "##{dom_id(album)}" { click_link 'Edit' }
```

---

## Authentication Helper

```ruby
passwordless_sign_in(user)

# In test
describe 'authenticated user' do
  before { passwordless_sign_in(users(:artist)) }

  it 'accesses dashboard' do
    visit dashboard_path
    assert_text 'Welcome'
  end
end
```

---

## Common Patterns

### Forms

```ruby
visit new_album_path

fill_in 'Title', with: 'My Album'
fill_in 'Description', with: 'Album description'
select 'Rock', from: 'Genre'
attach_file 'Cover', file_fixture('cover.jpg')

click_button 'Create Album'

assert_text 'Album was successfully created'
assert_current_path album_path(Album.last)
```

### Turbo Frames

```ruby
# Verify frame loads
visit discover_path
assert_selector 'turbo-frame#genres'

# Interact within frame
within 'turbo-frame#genres' do
  click_link album.name
end
```

### Turbo Streams

```ruby
# Verify no page reload
visit album_path(album)
assert_text "Cart (0)"

click_button "Add to Cart"

assert_text "Cart (1)"
assert_text album.title  # Still on same page
```

### Stimulus Controllers

```ruby
visit page_with_toggle_path

assert_no_text "Hidden content"
click_button "Toggle"
assert_text "Hidden content"
```

### Modals

```ruby
click_button "Open Modal"
within '.modal' do
  fill_in 'Name', with: 'Value'
  click_button 'Submit'
end

assert_no_selector '.modal'
assert_text 'Success'
```

---

## Anti-Patterns

### Don't Use data-testid

```ruby
# ❌ AVOID - Not used in this project
find('[data-testid="album-card"]').click

# ✅ GOOD - Use semantic selectors
click_on album.title
```

### Don't Use Overly Specific Selectors

```ruby
# ❌ AVOID - Brittle, couples to structure
find('div > ul > li:first-child > a').click

# ✅ GOOD - Semantic, resistant to changes
within "##{dom_id(album)}" do
  click_link 'Edit'
end
```

### Don't Use Styling Selectors

```ruby
# ❌ AVOID - Changes with design
find('.red.text-lg').click

# ✅ GOOD - Semantic or content-based
click_on 'Delete'
find('article', text: album.title).click
```

---

## Best Practices

1. **Prefer semantic methods** - `click_link` over `find('a').click`
2. **Use text when possible** - `click_on album.title` over CSS selectors
3. **Grep existing tests** - Match established patterns for same UI elements
4. **Avoid sleep** - Use `wait:` option on assertions
5. **Scope interactions** - Use `within` to limit search area
6. **Test user-visible behavior** - Not DOM structure
7. **Use Rails helpers** - `dom_id`, `file_fixture`

---

## Discovery

**Find Capybara usage patterns:**

```
Grep "click_link\|click_button\|fill_in" test/system/**/*_test.rb
Grep "assert_text\|assert_selector" test/system/**/*_test.rb
Grep "within.*do" test/system/**/*_test.rb
```

**Capybara documentation:**

- https://rubydoc.info/github/teamcapybara/capybara/master
