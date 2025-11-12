# Decision Framework

## Start Here: Natural Language

Every prompt should begin with clear, direct natural language instructions. This is your baseline.

## Then Ask: Would a prompting technique help?

- Complex reasoning needed? Consider CoT
- Need specific format/style? Consider Few-Shot
- Multiple types of information? Consider XML separation
- Already clear and effective? Stop, you're done

## Then Ask: Would Claude Code features help in the prompt content?

- Should this prompt reference CLAUDE.md knowledge?
- Should this prompt invoke existing skills?
- Should this prompt delegate to subagents?
- Should this prompt invoke MCP tools?
- Complex structure? Use XML tags for progressive disclosure

## Principle: Less is More

Don't add techniques just because you can. Add them when they solve a specific problem. Most prompts work best with just clear natural language.

## Skill Invocation Patterns

For skills, include trigger phrases to ensure intentional activation:

- "use your [skill-name] to..."
- "use the [skill-name] for..."
- Include trigger words from skill description

For subagents, use clear delegation language:

- "use your [subagent-name] subagent to..."
- "use the [subagent-name] subagent for..."
- Match language to subagent's description triggers

Claude auto-discovers skills and subagents but may skip them without explicit triggers in the prompt.
