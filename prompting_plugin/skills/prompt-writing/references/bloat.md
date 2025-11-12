## Avoiding Bloat

**Every sentence should earn its place by:**

- Teaching Claude something it doesn't know
- Providing specific, actionable guidance
- Clarifying ambiguity

**Common bloat patterns to detect:**

- Explaining what Claude already knows (what Python is, how APIs work)
- Redundant instructions saying the same thing different ways
- Vague generalizations instead of specific guidance
- Over-explaining obvious concepts
- Preambles that add no value ("It's important to note that...")

**When reviewing generated prompts, ask:**

- Does this sentence change Claude's behavior?
- Would removing this make the prompt less effective?
- Is this obvious from context?

**Context matters:**

- Skills can be longer (progressive disclosure)
- Commands should be tight (they run repeatedly)
- Documents vary by complexity
- Subgents need enough context to decide
