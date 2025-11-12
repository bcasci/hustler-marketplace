---
name: prompt-writing
description: Use your prompt-writing skill to generate, analyze, and optimize prompts for Claude Code artifacts (skills, commands, subagents, reference docs) and free-form prompts. Applies real prompting techniques, Claude-specific features, and bloat avoidance.
allowed-tools: Read
---

## Purpose

Provides prompt generation, analysis, and optimization using documented prompting techniques (CoT, Few-Shot, Zero-Shot, ReAct, System/User, XML), Claude Code features (CLAUDE.md, MCP tools, subagents, skills), and bloat avoidance principles.

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

## Output

**Generation mode**: Complete prompt
**Analysis mode**: Evaluation with specific improvement opportunities
**Optimization mode**: Refined prompt with before/after comparison and rationale

## Common Errors

**Wrong frontmatter**: Each artifact type has specific required/optional fields - verify against artifact guides
**Bloat**: Removed by asking "Does this sentence change Claude's behavior?"
**Wrong technique**: Apply decision framework - not all prompts benefit from CoT or Few-Shot
**Missing trigger words**: Skills need invocation phrases like "use your [skill-name] to..."
**Absolute paths**: Use `{baseDir}/references/` not full paths
**Subagent terminology**: Use "subagent" not "agent" in `.claude/agents/` files

## Resources

**Techniques**: `{baseDir}/references/techniques-catalog.md` - complete definitions with when/how/when-not-to-use
**Decision Framework**: `{baseDir}/references/decision-framework.md` - when to apply techniques and Claude Code features
**Bloat Avoidance**: `{baseDir}/references/bloat.md` - principles for concise prompts
**Claude Features**: `{baseDir}/references/claude-features.md` - CLAUDE.md, MCP, subagents, skills

**Artifact Guides**:

- `{baseDir}/references/artifact-guides/skills.md`
- `{baseDir}/references/artifact-guides/commands.md`
- `{baseDir}/references/artifact-guides/agents.md`
- `{baseDir}/references/artifact-guides/reference_documents.md`

**Templates**:

- `{baseDir}/references/templates/skill-template.md`
- `{baseDir}/references/templates/command-template.md`
- `{baseDir}/references/templates/subagent-template.md`
- `{baseDir}/references/templates/reference-document-template.md`

**Examples** (good/bad patterns):

- `{baseDir}/references/examples/technique-examples.md`
- `{baseDir}/references/examples/skill-examples.md`
- `{baseDir}/references/examples/command-examples.md`
- `{baseDir}/references/examples/document-examples.md`
- `{baseDir}/references/examples/subagent-examples.md`
