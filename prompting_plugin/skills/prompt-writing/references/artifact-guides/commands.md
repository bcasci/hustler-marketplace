<commands>

## What is a Custom Slash Command (Factual Definition)

A custom slash command is a markdown file stored in the `.claude/commands/` folder that contains a prompt or set of instructions. When you type `/` in Claude Code, these commands appear in a menu and can be invoked by name.

**Facts from Documentation:**

- Commands are markdown files in `.claude/commands/` directory
- They contain prompt templates for repeated workflows
- They become available in the slash commands menu when you type `/`
- They can be checked into git to share with your team
- They support a special `$ARGUMENTS` keyword for passing parameters

## How Commands Work

When you invoke a command (e.g., `/my-command some-input`): 1. Claude Code reads the markdown file from `.claude/commands/my-command.md` 2. If the file contains `$ARGUMENTS`, it replaces it with "some-input" 3. The resulting text becomes the prompt that Claude receives 4. Claude executes based on those instructions

## Command File Structure

Command files can contain optional frontmatter followed by the prompt content.

**Frontmatter (Optional but Recommended):**

```yaml
---
description: Brief description of what this command does
argument-hint: [issue-number] [priority]
allowed-tools: "Bash(git:*), Read, Write"
model: claude-3-5-haiku-20241022
disable-model-invocation: false
---
```

All frontmatter fields are optional:
- `description`: Brief description (defaults to first line of prompt). Include this for SlashCommand tool discovery.
- `argument-hint`: Expected arguments for auto-completion
- `allowed-tools`: Tools this command can use (inherits from conversation if omitted). Can include MCP tools when relevant.
- `model`: Specific model to use (inherits from conversation if omitted)
- `disable-model-invocation`: Set to true to prevent SlashCommand tool from calling this command (defaults to false)

**Prompt Content:**

After frontmatter (or if no frontmatter), the markdown content becomes the prompt Claude receives.

Simple example:
```
Run the test suite and report any failures in the scratchpad.
```

Example with frontmatter:
```yaml
---
description: Fix GitHub issues following TDD workflow
argument-hint: [issue-number]
allowed-tools: "Bash(gh:*), Read, Write, Edit"
---

Analyze GitHub issue $ARGUMENTS and create a fix:
1. Use `gh issue view $ARGUMENTS` to read the issue
2. Identify the root cause
3. Implement a fix
4. Run tests to verify
```

## Writing Prompts for Commands

When writing a prompt that will live in a command file, consider:

**Purpose:** Commands are for repeated workflows you want quick access to. If you're only going to say something once, just say it directly - don't make a command.

**Reusability:** If the prompt needs to work with different inputs (issue numbers, file paths, feature names), use `$ARGUMENTS` to make it flexible.

**Clarity:** The prompt will be executed exactly as written. Be explicit about what Claude should do.

**Context:** Commands don't have access to special context beyond what's in the prompt. If Claude needs to reference a CLAUDE.md file or skill, mention it in the prompt.

## Argument Handling

Commands support two argument patterns:

**`$ARGUMENTS` - All arguments as single string:**

Captures everything after the command name as one value.

Example:
- Command file contains: `Fix issue $ARGUMENTS`
- Invocation: `/fix-issue 123 high-priority`
- Result: `$ARGUMENTS` becomes `123 high-priority`
- Claude receives: `Fix issue 123 high-priority`

**Positional Parameters (`$1`, `$2`, `$3`) - Individual arguments:**

Access specific arguments separately, like shell script parameters.

Example:
- Command file contains: `Review PR #$1 with priority $2 assigned to $3`
- Invocation: `/review-pr 456 high alice`
- Result: `$1` = `456`, `$2` = `high`, `$3` = `alice`
- Claude receives: `Review PR #456 with priority high assigned to alice`

**When to use each:**
- `$ARGUMENTS`: All input as single value (commit messages, search queries, issue numbers with descriptions)
- `$1, $2, $3`: Multiple distinct values (PR number + priority + assignee, file path + operation + output format)

## Special Command Features

**Bash Execution (`!` prefix):**

Execute bash commands before the slash command runs. The output is included in the command context.

Example:
```yaml
---
description: Analyze current git status and suggest next steps
allowed-tools: "Bash(git:*)"
---

Current git status:
!`git status --short`

Based on the above status, suggest what to do next.
```

Note: Requires `allowed-tools` frontmatter with Bash tool specified.

**File References (`@` prefix):**

Include file contents directly in the command context.

Example:
```
Review the implementation in @src/auth/login.js and suggest improvements.
```

**Extended Thinking:**

Activate extended thinking by including relevant keywords in command definitions.

Example:
```
Think deeply about the architecture implications of this change and analyze thoroughly before proposing a solution.
```

## Commands vs Other Formats

**Command vs Skill:** Command is a prompt stored in `.claude/commands/`, invoked explicitly with `/`. Skill is instructions in a folder, invoked automatically when Claude determines it's relevant.

**Command vs CLAUDE.md:** Command is a prompt you explicitly invoke when needed. CLAUDE.md is context automatically loaded at the start of every conversation.

**Command vs Just Typing:** Command saves typing for repeated prompts, shareable via git. Typing is appropriate for one-off requests or things you don't repeat.

## What Matters When Generating Command Prompts

When your prompt-writing skill generates a prompt for a command, it should:

**Understand the use case:** Is this a repeated workflow? Does it need parameters?

**Be complete:** The prompt should contain all instructions needed. Commands don't have special powers - they're just text that becomes Claude's input.

**Use $ARGUMENTS appropriately:** If the workflow needs input, use `$ARGUMENTS`. If it doesn't, don't include it.

**Be explicit:** Commands execute exactly as written. Don't assume Claude will infer missing steps.

**Consider prompting techniques:** Commands can use any prompting strategy (CoT, Few-Shot, XML, etc.) - they're just prompts in files.

</commands>
