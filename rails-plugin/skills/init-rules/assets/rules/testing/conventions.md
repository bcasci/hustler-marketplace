---
paths: "test/**/*.rb"
dependencies: []
---

# Testing Philosophy

## Test Type Decision Tree

**START HERE: What are you testing?**

### Browser/UI Behavior? → System Test

- Testing what users see/do in a browser
- UI interactions (clicks, forms, navigation)
- JavaScript/Stimulus controllers
- Turbo Frames/Streams
- Complete user workflows

**Granularity:** One complete user journey per test

**Example:** "User updates settings and sees confirmation"

### Multi-Request Workflow? → Integration Test

- Multiple HTTP requests in sequence
- No browser or JavaScript needed
- Authentication flows, API workflows
- Cross-controller workflows

**Granularity:** One workflow per test, multiple assertions per step

**Example:** "Magic link authentication with token reuse"

### Single Behavior? → Unit Test

- Individual model/controller/command behavior
- Isolated functionality
- Fast execution

**Granularity:** One focused assertion per test

**Example:** "Payment validation", "Controller authorization"

## Granularity Rules

### Unit Test: One Assertion per Test

```ruby
# ✅ GOOD - Precise failure diagnosis
it 'sets status to successful' do
  assert_equal 'successful', subject.status
end

it 'sets completed_at timestamp' do
  assert_not_nil subject.completed_at
end
```

**Why:** When test fails, you know EXACTLY which behavior broke.

### Integration Test: One Workflow per Test

```ruby
# ✅ GOOD - Complete workflow with checkpoints
it 'authenticates user with magic link' do
  # Step 1: Request link
  post auth_sign_in_path, params: { email: user.email }
  assert_response :success

  # Step 2: Click link
  get confirm_auth_sign_in_path(session, token)
  assert_response :redirect

  # Step 3: Access protected resource
  get dashboard_path
  assert_response :success
end
```

**Why:** Workflow steps have sequential dependencies.

### System Test: One Journey per Test

```ruby
# ✅ GOOD - Complete user task
it 'updates timezone via settings' do
  click_link "Settings"
  select "Eastern Time", from: "Timezone"
  click_button "Save"

  assert_text "Settings updated"
  assert_text "America/New_York"
end
```

**Why:** Users complete tasks, not individual clicks.

## Test Smell Checklist

Before committing any test, verify:

- [ ] Does this test what it claims?
- [ ] Can this test actually fail?
- [ ] Am I testing MY code or Rails?
- [ ] Is granularity correct for test type?

---

## The Core Question: Does This Test Earn Its Place?

Before writing any test, ask these three questions in order:

1. **What behavior am I testing?** - If you can't name a specific behavior, STOP
2. **Would a user or business owner care?** - If no, reconsider
3. **Am I testing MY code or Rails?** - Test your code only

**If any answer is unclear, you're likely writing a useless test.**

## How We Test: Behavior-Driven, Value-Focused

**Test behaviors, not structure:**

- ✅ GOOD: "preserves item data after owner changes it"
- ❌ BAD: "has a name attribute"

**Test business value, not Rails functionality:**

- ✅ GOOD: "calculates discount correctly for bulk purchases"
- ❌ BAD: "saves to database successfully"

**Focus on "why it matters" not "what it does":**

- ✅ GOOD: "prevents double-processing when user clicks twice"
- ❌ BAD: "calls process method once"

## What We Test: The Litmus Test

**DO test these behaviors:**

1. **Business logic** - Calculations, transformations, decisions
2. **Validation rules** - What data is acceptable
3. **Edge cases and boundaries** - Error conditions, limits, invalid states
4. **Integration points** - How components work together
5. **Security and authorization** - Access control, data isolation

**DON'T test these (waste of time):**

1. **Rails framework** - ActiveRecord, associations, basic CRUD
2. **Library functionality** - Gems, standard library
3. **Implementation details** - Method names, variable assignments
4. **Duplicate coverage** - Testing the same behavior multiple ways

## Test Value Proposition: Each Test Must Justify Itself

**A test earns its place when it:**

1. **Catches regressions** - Would fail if behavior breaks
2. **Documents requirements** - Makes business rules clear
3. **Guides refactoring** - Enables safe code changes
4. **Has clear failure modes** - You know exactly what broke

**A test wastes time when it:**

1. **Always passes** - Can't fail even with broken code
2. **Tests framework** - Verifies Rails/library functionality
3. **Duplicates coverage** - Tests what's already tested elsewhere
4. **Tests structure** - Verifies implementation details, not behavior

**The "Can I Make It Fail?" Test:**

Before committing a test, try to make it fail by:

- Commenting out the code it supposedly tests
- Breaking the business logic intentionally
- Removing validations or checks

If you can't make it fail, delete it.

## Practical Testing Approach

**Our methodology:**

1. **TDD by default** - Write failing test first (Red-Green-Refactor)
2. **Test at the right level** - Test where the logic lives
   - Model logic → Model test
   - Controller behavior → Integration test
   - User interactions → System test
3. **Use real objects** - Prefer real objects over mocks (except for unavoidable external APIs)
4. **Keep tests focused** - One behavior per test
5. **Make tests explicit** - Don't rely on brittle baseline data for search/filter tests

**Quick decision tree:**

```text
Is this business logic?
  → YES: Write test
  → NO: Is it a validation/authorization rule?
    → YES: Write test
    → NO: Is it an edge case/error condition?
      → YES: Write test
      → NO: Skip the test
```

## Test Data Philosophy

**Make test data explicit when it matters:**

- Search/filter tests - Set attributes explicitly so test is clear
- Tests sensitive to specific values - Don't assume baseline data values
- Edge cases - Set the exact boundary condition you're testing

**Use baseline data for structure:**

- Testing relationships (`user.organization`)
- Testing basic record existence
- Testing associations and traversals

**Prefer real objects over mocks:**

- Mocks hide integration problems
- Mocks create brittle tests tied to implementation
- Mocks don't test real behavior
- Use mocks strategically when cost-benefit favors it

## Integration Tests vs System Tests

- Controller tests (ActionDispatch::IntegrationTest): For HTTP requests/responses
- System tests: For full user flows with Turbo, clicking buttons, filling forms
- With heavy Turbo usage, end-to-end tests must be system tests, not integration tests

### Test Location

Test where the logic lives, not where you saw the bug.

**Check domain-specific patterns:**

- Models → test/topics/models.md
- Controllers → test/topics/controllers.md
- Commands → test/topics/business-logic.md
- Policies → test/topics/policies.md
- Jobs → test/topics/jobs.md
- System tests → test/topics/system.md
