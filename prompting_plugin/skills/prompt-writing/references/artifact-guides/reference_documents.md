<documents>

## Writing Reference Documents for Claude Code

Reference documents provide context that helps Claude Code understand projects. When generating prompts that create or improve reference documents, focus on making them useful without bloating context windows.

## File Reference Strategies

**Plain Path (Default Approach):**

- Syntax: path/to/file.md (no @)
- Behavior: Claude reads the file only if it determines it's valuable
- Default for: Reference documents, documentation pointers, optional resources
- Benefit: No context cost unless actually needed

**@ Symbol (Explicit Import):**

- Syntax: @path/to/file.md
- Behavior: Forces immediate load of entire file content into context
- Use only when: The file content must be available right now for the current task
- Cost: Immediate context window consumption

## When to Use Each Reference Type

**Use plain paths (the default):**

- In reference documents pointing to other docs
- Troubleshooting guides that are conditionally relevant
- Architecture documentation that applies to specific scenarios
- Any "available if needed" reference
- When you want Claude to decide based on the actual task

**Use @ (rarely):**

- Interactive prompts when working directly with a specific file ("Review @src/auth.js")
- Current task explicitly requires this exact file content now
- Small, critical files that must be in context immediately

**In reference documents: Almost always use plain paths**
Reference docs should point to resources, not force-load them. Let Claude decide what it needs based on the task at hand.

## Providing Context with Plain Paths

When using plain paths in reference documents, explain when the file is relevant so Claude knows when to read it.

**Good examples:**
"For database migration failures, see docs/db-troubleshooting.md"
"Authentication implementation details are in docs/auth-architecture.md"
"If encountering FooBarError, consult docs/foobar-guide.md"

**Poor examples:**
"See docs/troubleshooting.md" (no context about when)
"@docs/troubleshooting.md" (forces load unnecessarily)
"docs/file1.md, docs/file2.md, docs/file3.md" (just a list with no guidance)

## Progressive Disclosure Pattern

For complex topics, recommend organizing with overview first and details in XML-tagged sections.

Pattern: High-level explanation accessible immediately, detailed content wrapped in semantic XML tags that Claude references when needed.

Why: Prevents context window bloat while keeping information available.

Example structure: Overview paragraph explaining the system, then authentication_details section with implementation specifics, payment_processing section with flow details, error_handling section with troubleshooting steps.

## What Makes Effective Reference Documents

**High-Value Content:**

- Project structure (where things live)
- Conventions and patterns actually used
- Architecture decisions with rationale
- Domain-specific business concepts
- Non-obvious behaviors
- Where to find key functionality
- Pointers to detailed docs (plain paths with context)

**Low-Value Content:**

- Obvious information about languages or frameworks
- Rapidly changing information
- Exhaustive details better kept elsewhere
- Information obvious from code
- Force-loaded content (via @) that's rarely needed

## Composition Guidance

**Default to Plain Paths:** Reference files without @. Provide context about when they're relevant. Let Claude decide when to read them.

**Be Specific:** Concrete facts beat vague descriptions. "JWT tokens expire after 1 hour" beats "modern auth patterns".

**Explain Relevance:** "For database migration errors, see docs/db-troubleshooting.md" tells Claude when that file matters.

**Stay Concise:** Every word should add value. Verbosity wastes context budget.

**Trust Claude's Judgment:** Plain paths let Claude determine what's relevant based on the actual task. This is usually better than forcing content into context upfront.

## Writing Prompts for Reference Documents

When generating a prompt that asks Claude Code to create or improve a reference document, include guidance on:

**Structure:** Overview first, details organized logically, use progressive disclosure for complex topics

**Content Selection:** Focus on non-obvious information, explain the "why" not just "what", use plain paths to point to detailed docs

**References:** Default to plain paths with context about when files are relevant, use @ only when file content must be immediately available

**Brevity:** Make every sentence count, remove redundancy, assume Claude knows common concepts

**Maintenance:** Write content that stays relevant, avoid time-sensitive details, make it easy to update

</documents>
