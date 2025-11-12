<examples>

## Chain-of-Thought Examples

**Good CoT Prompt:**
"A train travels 120 miles in 2 hours, then 180 miles in 3 hours. What is its average speed for the entire journey? Think through this step by step, showing your calculations."

Why it works: Complex calculation benefits from showing intermediate steps.

**Bad CoT Prompt:**
"What is 5 + 3? Think step by step."

Why it's bad: Trivial calculation doesn't benefit from step-by-step reasoning.

## Few-Shot Examples

**Good Few-Shot Prompt:**

```
Convert user stories into test descriptions:

Example 1:
User Story: As a user, I want to reset my password so I can regain access
Test: User can request password reset and receive email with reset link

Example 2:
User Story: As an admin, I want to deactivate accounts so I can manage access
Test: Admin can deactivate user account and user loses access

Now convert:
User Story: As a user, I want to filter search results by date
```

Why it works: Format transformation isn't obvious, examples show the pattern.

**Bad Few-Shot Prompt:**

```
Write Python functions.

Example: def add(a, b): return a + b

Now write a multiply function.
```

Why it's bad: Writing basic functions is standard knowledge, examples add no value.

## XML Context Separation Examples

**Good XML Usage:**

```
<codebase_context>
Rails app using RSpec for testing, FactoryBot for test data, Pundit for authorization
</codebase_context>

<work_items>
1. Add admin role
2. Restrict user deletion to admins
3. Add admin dashboard
</work_items>

<instructions>
For each work item, follow TDD: write failing test, implement feature, verify tests pass
</instructions>
```

Why it works: Three distinct information types clearly separated.

**Bad XML Usage:**

```
<instructions>
Write code that works and follows our standards.
</instructions>
```

Why it's bad: Single vague piece of information doesn't need XML.

