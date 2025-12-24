---
paths: test/system/**/*_test.rb
dependencies: []
---

# System Testing Philosophy

System tests verify complete user workflows through browser automation.

**Industry consensus (DHH 2024, Thoughtbot, Betterment, Rails Guides):** Use system tests sparingly for critical user journeys only. Test at the lowest level that gives confidence.

---

## When to Write System Tests

**Decision tree - Ask in order:**

1. **Did this break in production and affect users?**

   - YES → Test it (prevent regression)
   - NO → Continue to #2

2. **Can this be tested without a browser?** (No JavaScript/frontend framework required?)

   - YES → Use integration/request test (faster, more stable)
   - NO → Continue to #3

3. **Does this test a complete user journey?** (browse → discover → purchase)

   - YES → System test (if revenue/security-critical)
   - NO → Continue to #4

4. **Is this testing framework configuration?** (frontend framework escapes, client-side wiring)

   - YES → System test (can't verify without browser)
   - NO → Continue to #5

5. **Is this testing a proven pattern that hasn't failed?**

   - YES → Don't test (verified in QA, trust the pattern)
   - NO → Continue to #6

6. **Is this revenue or security-critical?**
   - YES → System test for happy path only
   - NO → Use integration test or don't test

**Pragmatism over purity:** Production regressions that require a browser deserve tests, even if they seem simple.

**Target: 10-20 system tests covering critical journeys + framework integration points.**

---

## Journey Tests vs Standalone Tests

**After deciding to write a system test, determine the type:**

**Journey Test (PREFER THIS):**

- Tests complete user workflow (browse → discover → purchase)
- Framework integration happens naturally within the journey
- Provides more value (tests flow AND integration points)
- Example: User discovers music through genres and adds to cart

**Standalone Test (only when necessary):**

- Journey test already covers this behavior
- Isolated framework integration that can't fit in a journey
- Must document why journey isn't feasible

**Decision framework:**

1. **What user journey includes this behavior?**

   - Browse → Discover → Purchase?
   - Register → Verify → Complete profile?
   - Search → Filter → Select?

2. **Can I test this within that journey?**

   - YES → Write/extend journey test
   - NO → Continue to #3

3. **Does a journey test already cover this?**

   - YES → Don't duplicate, standalone not needed
   - NO → Continue to #4

4. **Why can't this be a journey test?**
   - Can document valid reason → Standalone OK
   - Cannot articulate reason → Should be journey test

**Journey-first principle:** When production bugs break framework integration, test them within the user journey they affect, not as isolated navigation checks.

---

## What System Tests Should Test

**✅ Test these with system tests:**

- Complete purchase flows (browse → cart → checkout → payment)
- Multi-step authentication workflows (register → verify → complete profile)
- Complex JavaScript interactions (drag-and-drop, real-time updates)
- Cross-page user journeys spanning multiple controllers
- **Framework integration that broke in production**
- **Frontend framework behavior that can't be tested otherwise**

**❌ Don't test these with system tests:**

- Basic navigation where framework config isn't the concern
- Rails framework behavior (associations, validations - use unit tests)
- CRUD operations without JavaScript (use integration tests)
- Patterns proven AND never failed (trust working patterns)
- Edge cases and validations (use unit/integration tests)

**Key distinction:**

- ❌ "Does this link navigate?" → Framework behavior, don't test
- ✅ "Does this frame escape properly?" → Framework integration, needs system test
- ❌ "Does Rails routing work?" → Framework behavior, don't test
- ✅ "Does our client-side controller wire up correctly?" → Framework integration, needs system test

**Balance:** Navigation tests CAN be brittle, but framework integration bugs ARE real. Test what breaks in production.

---

## Test Organization

**Organize by user journeys and goals:**

```ruby
describe 'discovering music through genres' do  # User goal + context
  it 'displays albums grouped by genre' do      # What user sees
  it 'completes discovery-to-purchase journey' do  # Complete flow
end
```

**Alternative: Organize by action when multiple scenarios exist:**

```ruby
describe 'showing' do  # Primary action
  describe 'profile information' do
  describe 'navigation tabs' do
end

describe 'following' do  # Different action
  describe 'when visitor is not owner' do
  describe 'when visitor is owner' do
end
```

**Naming patterns:**

**Describe block:** User goal with context (how/where)
**Test name:** Active verb describing completion or outcome

```ruby
# ✅ GOOD - Concise, no redundancy
describe 'discovering music through genres' do
  it 'completes discovery-to-purchase journey' do

# ❌ BAD - Verbose, redundant
describe 'browsing genres to discover and purchase music' do
  it 'enables discovery-to-purchase journey through genre browsing' do
    # "browsing genres" repeated, "enables" is passive
```

**Pattern rules:**

1. **Avoid redundancy** - Don't repeat describe context in test name
2. **Use active verbs** - "completes", "purchases", "discovers" (not "enables", "allows")
3. **Describe = goal + context** - "purchasing albums as curator", "managing cart items"
4. **Test = outcome** - What the user successfully does
5. **No technical terms** - User language only (no framework jargon in test names)

**More examples:**

```ruby
# User authentication flow
describe 'signing in with magic link' do
  it 'completes authentication and redirects to dashboard' do

# Multi-step workflow
describe 'creating album with tracks' do
  it 'publishes album with uploaded content' do

# Error handling
describe 'purchasing sold-out album' do
  it 'shows unavailable message and suggests alternatives' do
```

---

## Best Practices

1. **Test at the lowest level that gives confidence** - Can you test it without a browser? Use integration test
2. **Test complete user journeys when possible** - Prefer full flows over isolated checks
3. **Test production regressions** - If it broke once, prevent it from breaking again
4. **Target 10-20 system tests** - Critical journeys + framework integration points
5. **Trust proven patterns that haven't failed** - Don't test working patterns, but DO test patterns that broke
6. **Framework integration needs system tests** - Can't be tested otherwise
7. **Happy path focus for journeys** - Edge cases belong in unit/integration tests
8. **Keep tests independent** - Each test sets up its own data
9. **Use descriptive names** - Explain what's being tested and why it matters
10. **No database assertions** - Test only user-visible behavior

**Industry guidance context:** DHH removed HEY's system tests because they became brittle. However, framework-heavy apps need system tests for integration. Balance: fewer tests, but cover what actually breaks.

**When in doubt:** Did this break in production? → Test it. Can you fold it into a journey? → Do that. Never broke and always works? → Skip it.

---

## Anti-Patterns

### Navigation Tests: When They're Worth It

**DON'T test basic navigation:**

```ruby
# ❌ BAD - Just testing if links work
it 'navigates to album show page' do
  click_link 'Album Name'
  assert_current_path album_path(album)  # Framework routing works, nothing to test here
end
```

**DO test framework integration:**

```ruby
# ✅ GOOD - Testing framework escape configuration (broke in production!)
it 'navigates to album show page from genre context' do
  visit genres_path

  within 'frame#genres' do
    click_link album.name  # Testing: does frame escape work?
  end

  assert_current_path album_path(album)
  assert_no_text 'Content missing'  # Verifies frame escape succeeded
end
```

**BETTER - Test as part of user journey:**

```ruby
# ✅ BEST - Complete user goal with framework integration naturally included
it 'discovers and purchases music through genre browsing' do
  visit genres_path

  within '#rock-section' do
    click_link album.name  # Frame escape happens naturally
  end

  assert_text album.artist_name
  click_button 'Add to Cart'
  assert_text 'Cart (1)'
end
```

**Decision framework:**

- Basic navigation that always worked? → Don't test or fold into journey
- Framework integration that broke in production? → Test it
- Can you fold it into a journey test? → Prefer that
- Is it a one-off critical integration point? → Standalone test OK

### Other Anti-Patterns

**❌ Database assertions** - Test user-visible behavior only:

```ruby
# ❌ BAD: assert_difference 'Follow.count', 1
# ✅ GOOD: assert_selector 'button', text: 'Unfollow'
```

**❌ Separate visibility tests** - Test complete journey instead of checking if elements exist then testing their interaction

**❌ Over-testing edge cases** - Use unit/integration tests for edge cases, keep system tests focused on realistic user scenarios
