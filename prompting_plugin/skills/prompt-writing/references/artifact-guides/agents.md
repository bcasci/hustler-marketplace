<agents>

## Writing Claude Code Subagent Prompts

Subagents are specialized AI assistants defined in markdown files with YAML frontmatter. Each subagent has its own context window and specific tool permissions. When generating subagent prompts, focus on effective frontmatter and purposeful system prompts.

## Subagent File Structure

**Format:**

```
---
name: subagent-name
description: Clear description of what this does and when to use it
tools: Read, Grep, Glob, Bash
model: inherit
---

System prompt content here.
Define behavior, expertise, and workflow.
```

**File locations:** Project-level at .claude/agents/ or user-level at ~/.claude/agents/

## Frontmatter Architecture

**name (required):**
Unique identifier. Use lowercase with hyphens.

**description (required):**
Critical field that determines when Claude invokes the subagent. Must include:

- What the subagent does
- When it should be used
- What context it needs to start
- How to intentionally trigger it

Good: "Expert code reviewer. Use PROACTIVELY after code changes to check security, style, and maintainability. Reviews git diffs and provides prioritized feedback."

Poor: "Reviews code" (too vague, no trigger conditions)

**tools (optional):**
Comma-separated list. Omit to inherit all tools from main thread.
Common: Read, Write, Edit, Bash, Glob, Grep, WebSearch, WebFetch
Can include MCP tools when relevant (check available MCPs)
Principle: Grant only necessary tools.

**model (optional):**
Specify model or use "inherit" for main thread's model.

## System Prompt Design

The content after frontmatter defines the subagent's behavior. Use any prompting strategy that fits the purpose: Chain-of-Thought, Few-Shot, XML structure, decision frameworks, plain instructions.

**System prompt should define:**

- Role and expertise
- Specific responsibilities and workflow
- Constraints and boundaries
- Expected output format
- Edge case handling

**No restrictions on approach:** The system prompt can be structured however best accomplishes the subagent's purpose.

## Architecting Effective Descriptions

The description determines when the subagent is invoked. Make it actionable and specific.

**Trigger words:** "Use PROACTIVELY" or "MUST BE USED" encourage automatic invocation.

**Specific conditions:**
Good: "Use after code changes to run tests and fix failures"
Bad: "Helps with testing"

**Required context:**
Good: "Analyzes git diffs to review changed code paths"
Bad: "Reviews code"

**Invocation clarity:**
Description should make it obvious how to explicitly request this subagent using phrases like "use your [subagent-name] subagent to..." or "use the [subagent-name] subagent for..."

## System Prompt Patterns

**Goal-Oriented:**
Define what to accomplish, let subagent determine approach within constraints.

**Process-Driven:**
For workflows requiring specific steps (TDD, security audits), outline them explicitly.

**Tool-Aware:**
Reference available tools and when to use them.

**Output-Focused:**
Specify expected format (JSON, markdown, structured reports).

**Any Strategy Works:**
CoT for complex reasoning, Few-Shot for specific patterns, XML for organization, decision trees for branching logic.

## Common Subagent Architectures

**Read-Only Analyst:**
tools: Read, Grep, Glob
Purpose: Analyze and provide feedback without modification

**Code Implementer:**
tools: Read, Write, Edit, Bash, Grep, Glob
Purpose: Implement features, fix bugs, modify code

**Test Executor:**
tools: Read, Bash, Grep
Purpose: Run tests, analyze failures, report results

**Documentation Writer:**
tools: Read, Write, Grep, Glob
Purpose: Generate or update documentation

**Research Specialist:**
tools: Read, Grep, WebSearch, WebFetch
Purpose: Gather information, analyze patterns

## What to Include When Generating Subagent Prompts

**Frontmatter design:**

- Clear, unique name
- Actionable description with trigger conditions and context needs
- Minimal necessary tool permissions
- Model choice if needed

**System prompt design:**

- Clear role definition
- Specific responsibilities
- Workflow or approach guidance
- Constraints and boundaries
- Output expectations
- Appropriate prompting strategy for the task

## What to Avoid

**Vague descriptions:** Claude won't know when to invoke the subagent

**Over-permissioning:** Only grant necessary tools for security and focus

**Rigid process when flexibility needed:** Allow adaptation within constraints

**No trigger guidance:** Without clear conditions, subagent may never be automatically invoked

**Missing context requirements:** Specify what the subagent needs to start effectively

</agents>
