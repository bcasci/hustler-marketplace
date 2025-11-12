## Command Examples

**Good Command with $ARGUMENTS:**

```
Analyze GitHub issue $ARGUMENTS and implement a fix:

1. Run `gh issue view $ARGUMENTS` to read the issue
2. Identify the root cause
3. Write tests that reproduce the bug
4. Implement the fix
5. Verify tests pass
6. Comment on the issue with your solution
```

Why it works: Flexible with any issue number, treats all input as one string.
Usage: /fix-issue 123

**Good Command with Positional Parameters:**

```
Review PR #$1 with priority $2 and assign to $3.

Focus on:
- Security vulnerabilities
- Performance implications
- Code style consistency

Report findings and tag $3 for follow-up.
```

Why it works: Accesses each argument individually for different purposes.
Usage: /review-pr 456 high alice

**When to use each:**

$ARGUMENTS: When you want all input as a single value (issue numbers, commit messages, search queries)

$1, $2, $3: When you need to handle multiple distinct pieces of information (PR number + priority + assignee, or feature name + test type + output format)

**Bad Command:**

```
Fix the bug.
```

Why it's bad: No process, no context, too vague.

**Good Command:**

```
Implement the feature using test-driven development:

1. Read the feature description from work-items.md
2. Write a failing test that verifies the feature
3. Run the test to confirm it fails
4. Write minimal code to make the test pass
5. Run tests to verify they pass
6. Run full test suite to check for regressions
7. Update scratchpad with progress

If stuck after 3 attempts, log the blocker and ask for guidance.
```

Why it works: Clear steps, explicit process, handles failure.

