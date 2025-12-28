---
name: add-rule
description: Interactive wizard for creating new rule files following CLAUDE.md guidelines
---

# Add Rule

Create new rule file in `rails-plugin/skills/init-rules/assets/rules/`.

**Apply standards from project memory.**

## Workflow

### 1. Gather Requirements

Ask user for:

- Domain (models, views, controllers, testing, locales, architecture, code-style)
- Universal or framework-specific (`dependencies: []` vs `dependencies: [gem]`)
- Path scope (`app/models/**/*.rb`, `app/views/**/*.erb`, etc.)

### 2. Determine Structure

Present options:

- **Single file**: `domain/conventions.md` (< 200 lines)
- **With topics**: `domain/conventions.md` + `domain/topics/*.md` (universal + framework-specific)
- **Topics only**: `domain/topics/[gem]-[feature].md` (no universal conventions)

### 3. Check for Conflicts

Verify placement:

```bash
ls rails-plugin/skills/init-rules/assets/rules/[domain]/
Grep "paths: app/[domain]" rails-plugin/skills/init-rules/assets/rules/**/*.md
```

Check:

- No duplicate domain/conventions.md
- Frontmatter paths don't conflict
- Correct file naming for framework-specific files

### 4. Generate File

**Frontmatter:**

```yaml
---
paths: [from requirements]
dependencies: [from requirements]
examples: [if examples directory exists]
---
```

**Template structure:**

For universal conventions.md:

- Brief description
- Core Patterns (When to use / When NOT to use)
- Standard Pattern (with generic examples)
- Decision Framework
- Discovery section

For framework-specific topics/[gem]-[feature].md:

- Brief description (2-3 sentences)
- When to Use / Don't use for
- Standard Pattern (with generic examples)
- Integration Patterns
- Discovery section

Create file:

```bash
mkdir -p rails-plugin/skills/init-rules/assets/rules/[domain]/topics
```

File naming:

- Universal: `[domain]/conventions.md`
- Topics: `[domain]/topics/[topic].md`
- Framework: `[domain]/topics/[gem]-[feature].md`

### 5. Report Creation

```markdown
## Created: rails-plugin/skills/init-rules/assets/rules/[path]

**Frontmatter:**

- paths: [confirmed]
- dependencies: [confirmed]

**Next:**

1. Fill in pattern details
2. Test: Edit file matching `paths:` to verify auto-load
3. Run `/validate-rules` when complete
```
