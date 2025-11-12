<skills>

## What is a Claude Code Skill (Factual Definition)

A skill is a folder containing a SKILL.md file that Claude Code loads dynamically to improve performance on specialized tasks. Skills teach Claude how to complete specific tasks in a repeatable way through prompt injection - the skill's instructions are loaded into Claude's context when relevant to the task.

**Key Facts:**

- Skills are folders that can contain SKILL.md, scripts, and other resources
- Claude automatically invokes skills based on task relevance
- Skills operate through context injection, not code execution
- Skills prepare Claude to solve a problem rather than solving it directly
- The description in frontmatter is the primary signal for when Claude invokes the skill

## Required SKILL.md Format

**Frontmatter (REQUIRED):**
Two fields are mandatory:

- name: Unique identifier (lowercase, hyphens for spaces)
- description: Complete description of what the skill does and when to use it (this is Claude's primary signal for deciding to invoke the skill)

**Optional Frontmatter:**

- allowed-tools: Scope tool access when restricting to specific tools is beneficial (e.g., `allowed-tools: "Read, Bash(git:*)"` restricts to Read and only git-related Bash commands). Can include MCP tools when relevant.

**Markdown Body (FLEXIBLE):**
The markdown content below the frontmatter contains instructions, examples, and guidelines that Claude will follow. There is NO required structure for this content. The goal is clarity and usability for Claude.

## Should Skills Have Consistent Format?

**Frontmatter: YES - Mandatory**
The name and description fields are required and must follow YAML format.

**Markdown Body: NO - Flexible by Design**
Looking at Anthropic's own skills (docx, pdf, pptx, xlsx, skill-creator), they vary significantly in structure. Some have detailed sections with XML tags for progressive disclosure, others are more straightforward. The content should be organized for Claude's comprehension, not conforming to a rigid template.

**Recommended (Not Required):**

- Clear overview or purpose statement
- Organized sections with headers
- Examples when helpful
- Guidelines or best practices
- Progressive disclosure for complex skills (detailed sections in XML tags)

**The Key Principle:**
Write the skill so Claude can understand and follow it. Structure serves comprehension, not vice versa.

## Operational Instructions vs Meta-Structure

**Meta-Structure (Frontmatter):**

- Required format: name and description
- This is how Claude discovers and decides to use the skill

**Operational Instructions (Markdown Body):**

- Completely flexible
- Can use any prompting strategy (CoT, Few-Shot, XML separation, etc.)
- Should be written for Claude's comprehension
- Can include or reference scripts in the skill folder
- Can use progressive disclosure with XML tags for complex skills
- No enforced template or structure

## What Goes in a Skill

**Instructions:** Tell Claude how to perform the task
**Examples:** Show Claude what good output looks like (when helpful)
**Guidelines:** Provide constraints, best practices, or decision frameworks
**References:** Point to related resources or documentation
**Scripts:** Include executable code that Claude can run (optional)

## What Makes an Effective Skill

**Clear Description:** The frontmatter description determines when Claude invokes the skill - make it specific and action-oriented
**Organized Content:** Structure the markdown for easy comprehension
**Actionable Guidance:** Tell Claude what to do, not just what to know
**Appropriate Detail:** Balance completeness with clarity
**Progressive Disclosure:** For complex skills, use XML tags to organize detailed sections Claude can reference as needed

</skills>
