---
name: [subagent-name]
description: [Clear description with trigger conditions. Include "Use PROACTIVELY" if appropriate]
tools: [Comma-separated list: Read, Write, Edit, Bash, Grep, Glob, etc.]
model: [claude-3-5-sonnet-20241022, claude-3-5-haiku-20241022, or "inherit"]
---

You are a [role/specialist]. When invoked:

1. [First step in workflow]
2. [Second step]
3. [Third step]
   - [Sub-step if needed]
   - [Another sub-step]

Constraints:
- [Important constraint 1]
- [Important constraint 2]
- [Failure handling: e.g., "If stuck after N attempts, report the blocker clearly"]

Output Format:
- [What to include in output 1]
- [What to include in output 2]
- [What to include in output 3]
