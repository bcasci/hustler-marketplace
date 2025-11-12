<skills>

## SKILL.md Format

**Frontmatter (REQUIRED):**
Two fields are mandatory:

- name: Unique identifier (lowercase, hyphens for spaces)
- description: Complete description following this pattern:
  1. What the skill does
  2. When to use it (be specific about context)
  3. What it needs (when applicable)
  4. How to trigger it (specific phrases: "Trigger with phrases like '[action] [context]'")

Example: "Generates, analyzes, and optimizes prompts for skills, commands, subagents, reference docs, and free-form text. Use when generating prompt content, analyzing prompt files, or optimizing prompt text. Trigger with phrases like '[generate|analyze|optimize] prompt', '[generate|analyze|optimize] [file-path]', 'create [skill|command|subagent]'."

**Optional Frontmatter:**

- allowed-tools: Scope tool access (e.g., `allowed-tools: "Read, Bash(git:*)"`)

**Markdown Body (FLEXIBLE):**
No required structure. Use any prompting strategy.

</skills>
