---
description: [What this command does - shown in /help]
argument-hint: [Example arguments shown to user]
allowed-tools: [Comma-separated list of tools, or "all" or omit for all tools]
model: [claude-3-5-sonnet-20241022, claude-3-5-haiku-20241022, or omit to inherit]
disable-model-invocation: [true/false - set true for simple template expansion]
---

[Command instructions that Claude will receive when this command is invoked]

[Use $ARGUMENTS to capture all arguments as a single string]
[Use $1, $2, $3 for positional parameters]
[Use ! prefix for bash commands: !git status]
[Use @ prefix to include file contents: @path/to/file.md]

[Step-by-step process if needed]

[Expected output or deliverables]
