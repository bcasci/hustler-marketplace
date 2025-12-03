---
description: [Brief description shown in /help menu]
# argument-hint: [arg1] [arg2]  # Optional: show expected arguments in autocomplete
# allowed-tools: "Read, Write, Edit, Bash"  # Optional: restrict to specific tools
# model: claude-3-5-haiku-20241022  # Optional: use faster/cheaper model
# disable-model-invocation: false  # Set true for simple template expansion
---

[Direct imperative instructions for what you must do when this command runs]

## Simple Example Structure

[Action verb] the [thing] and [action verb] any [results].

## Structured Example

[Action verb] $ARGUMENTS and [accomplish objective]:

1. [First action you must take]
2. [Second action you must take]
3. [Third action you must take]

[Any additional requirements or constraints]

## Using Arguments

- Use `$ARGUMENTS` to capture all arguments as one string
- Use `$1`, `$2`, `$3` for individual positional arguments
- Use `!command` to execute bash commands (requires allowed-tools with Bash)
- Use `@file/path` to include file contents

## Output Requirements

Provide:
- [What you must include in output]
- [What format to use]
