<claude_md_awareness>
Many projects have domain-specific CLAUDE.md files containing core behaviors, domain knowledge, patterns, and conventions.

**When generating prompts:**

- If the prompt relates to established knowledge → leverage existing reference files (CLAUDE.md, project docs)
- If repeated patterns emerge → recommend storing in appropriate reference files
  </claude_md_awareness>

<mcp_servers>
**Self-Reflection on Available MCP Servers**
Before generating a prompt, check available MCP servers and consider:

- Does the prompt's intent require external data/tools that an MCP provides?
- Would delegating to an MCP server improve accuracy or capabilities?
- Is the task complex enough to justify the token/time cost of MCP invocation?

**When Generating Prompts:**

- Check if available MCPs are useful to the task
- Scope relevant MCPs in tool lists when appropriate (e.g., `allowed-tools: "Read, Write, mcp__playwright__navigate"`)
- Include intentional invocation phrases when needed (e.g., "use your playwright mcp to navigate")

**Delegation Decision Framework:**

- Trivial tasks (simple lookups, basic operations) → Handle directly
- Complex tasks (external data, specialized tools, multi-step) → Consider MCP delegation
- Include MCP usage in generated prompts when it adds clear value
  </mcp_servers>

<subagents>
**Self-Reflection on Available Subagents**
Before generating a prompt, check available subagents (analyst, test-writer, implementer, validator, reviewer, etc.) and consider:
- Does the prompt's intent map to a specialized subagent's domain?
- Would delegating to a subagent improve quality or efficiency?
- Is the task complex enough to justify the token/time cost of subagent invocation?

**Delegation Decision Framework:**

- Simple tasks (single-step, straightforward) → Handle directly
- Specialized tasks (analysis, testing, validation) → Consider subagent delegation
- Multi-phase tasks → Recommend subagent orchestration in the generated prompt
  </subagents>

<existing_skills>
**Self-Reflection on Available Skills**
Before generating a prompt from scratch, check if existing skills can be:

- Used directly (the skill already solves this)
- Composed together (combine multiple skills)
- Referenced as patterns (use similar structure/approach)

Recommend skill composition when multiple skills can work together to achieve the intent.
</existing_skills>
