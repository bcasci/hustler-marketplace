---
name: prompt-writing
description: Generates, analyzes, and optimizes prompts for skills, commands,
  subagents, reference docs, and free-form text. Use when generating prompt content, analyzing prompt files, or optimizing prompt text to
  apply techniques and reduce bloat. Trigger with phrases like '[generate|analyze|optimize] prompt', '[generate|analyze|optimize] [file-path]', 'create [skill|command|subagent]'.
allowed-tools: "Read, Glob, Grep"
---

## Operating Modes

**Generation**: Takes user intent and artifact type → generates complete prompt with appropriate frontmatter, techniques, and Claude Code features.

**Analysis**: Evaluates existing prompt → identifies what works, what could improve, suggests specific enhancements with reasoning.

**Optimization**: Refines prompt → preserves intent, applies decision framework, improves clarity/conciseness, explains changes.

## Workflow

1. **Understand context**: Determine artifact type (skill/command/subagent/reference doc/free-form) and user's goal
2. **Apply decision framework**: Use `{baseDir}/references/decision-framework.md` to determine which techniques and features to add
3. **Check artifact requirements**:
   - Skills: `{baseDir}/references/artifact-guides/skills.md`
   - Commands: `{baseDir}/references/artifact-guides/commands.md`
   - Subagents: `{baseDir}/references/artifact-guides/agents.md`
   - Reference docs: `{baseDir}/references/artifact-guides/reference_documents.md`
4. **Apply techniques**: Reference `{baseDir}/references/techniques-catalog.md` for definitions
5. **Avoid bloat**: Follow `{baseDir}/references/bloat.md` principles
6. **Use Claude features**: Reference `{baseDir}/references/claude-features.md` when appropriate
7. **Use templates**: Start from `{baseDir}/references/templates/` for structure
8. **Reference examples**: Check `{baseDir}/references/examples/` for good/bad patterns

## Common Errors

**Wrong frontmatter**: Each artifact type has specific required/optional fields - verify against artifact guides
**Bloat**: Removed by asking "Does this sentence change Claude's behavior?"
**Wrong technique**: Apply decision framework - not all prompts benefit from CoT or Few-Shot
**Missing trigger words**: Skills need invocation phrases like "use your [skill-name] to..."
**Absolute paths**: Use `{baseDir}/references/` not full paths
**Subagent terminology**: Use "subagent" not "agent" in `.claude/agents/` files

## Resources

**Core:**

- `{baseDir}/references/techniques-catalog.md`
- `{baseDir}/references/decision-framework.md`
- `{baseDir}/references/bloat.md`
- `{baseDir}/references/claude-features.md`

**Artifact Guides:**

- `{baseDir}/references/artifact-guides/skills.md`
- `{baseDir}/references/artifact-guides/commands.md`
- `{baseDir}/references/artifact-guides/agents.md`
- `{baseDir}/references/artifact-guides/reference_documents.md`

**Templates:**

- `{baseDir}/references/templates/skill-template.md`
- `{baseDir}/references/templates/command-template.md`
- `{baseDir}/references/templates/subagent-template.md`
- `{baseDir}/references/templates/reference-document-template.md`

**Examples:**

- `{baseDir}/references/examples/technique-examples.md`
- `{baseDir}/references/examples/skill-examples.md`
- `{baseDir}/references/examples/command-examples.md`
- `{baseDir}/references/examples/document-examples.md`
- `{baseDir}/references/examples/subagent-examples.md`
