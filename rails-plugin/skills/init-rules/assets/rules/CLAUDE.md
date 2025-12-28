# Rules Maintenance Guide

When maintaining these rules, enforce conventions, not document implementations.

## Core Principles

**Rules teach conventions. Code teaches implementations.**

1. **Conventions, not education** - No sales pitches, "why use X" content, or benefits sections
2. **Patterns, not APIs** - Show when/how, not what/where for specific modules
3. **Universal by default** - Philosophy first, implementation second
4. **Composable** - Files work independently, minimal cross-references
5. **Domain-focused** - Stay in your lane, don't teach cross-cutting tools

Path-based auto-loading: Files load when their `paths:` frontmatter matches the file you're editing.

## Required Structure

Every domain uses ONE of these patterns:

**Single file:**
```
domain/conventions.md
```

**Multiple topics:**
```
domain/
├── conventions.md
└── topics/*.md
```

## Content Decision Tree

Before adding/keeping content, ask these questions **in order**:

### 1. Is this about ONE specific module?

Examples: `EventEmission.emit_event(event_name, **payload)`, method signatures for `render_album` helper, FormatMappable mapping table

**→ If YES: Remove it. Belongs in source code comments.**

### 2. Is this discoverable via code navigation?

Examples: "The `kept_packaged_with` association filters by kept scope", exact parameter names for specific helpers, list of all BeerCSS button classes

**→ If YES: Remove it. Trust search and inline docs.**

### 3. Is this teaching WHAT IS instead of WHEN/HOW?

Compare:
- WHAT IS: "Call `emit_event(:published)` to emit events" ❌
- WHEN/HOW: "Use concerns when 3+ models need same behavior" ✅

**→ If teaching WHAT IS: Remove it.**

### 4. Does this apply to multiple implementations?

Compare:
- Multiple: "Use scoped associations for frequently filtered relationships" ✅
- Single: "The albums controller uses a before_action for authorization" ❌

**→ If single implementation: Remove it.**

## What to Keep vs Remove

**KEEP:**
- Architectural decisions (when to use Commands vs. controller logic)
- Structure patterns (concern structure, controller patterns)
- Cross-cutting requirements (all controllers must use Pundit)
- Decision frameworks with criteria
- "Do this / Don't do this" comparisons
- When to break conventions
- **Curated API patterns** - The subset we actually use
- **Project integration patterns** - How gem integrates with our stack
- **Convention guidance** - Our preferred methods/approaches
- **Anti-patterns** - What NOT to use from the API

**REMOVE:**
- Method signatures for specific modules
- API documentation for individual modules
- Configuration tables for specific components
- Comprehensive gem API documentation (copying gem docs)
- Exhaustive option lists
- Usage examples for ONE specific module

## Exception: Structural Scaffolds

UI construction (views, markup) requires reference structures because the pattern IS the markup.

**Location:** `.claude/rules/views/templates/` (copyable .html.erb files)

**Criteria:**
- Production-derived (actual working code)
- Copyable files (.html.erb), not documentation
- Minimal annotations (decision points only)
- Rules reference scaffolds, don't embed them

Example: `.claude/rules/views/templates/index-pattern.html.erb` provides structure to copy. `.claude/rules/views/conventions.md` teaches WHEN to use it.

## API Reference Examples

**Good:**
```markdown
# capybara-system-tests.md

## Element Interaction (curated subset)
click_link 'Edit'
fill_in 'Title', with: 'Album'

## Element Selection Priority (our convention)
1. Semantic methods (prefer)
2. Text-based finders
3. CSS classes (BeerCSS patterns)

## Project Patterns
- Turbo Frames integration
- Stimulus controller testing
- Rails helper usage (dom_id, file_fixture)
```

**Bad:**
```markdown
# capybara-system-tests.md (BAD)

## All Capybara Methods
visit(url, **options) - Navigate to URL
  Options: - wait: Integer (default 2) - **All 15 options documented**
go_back - Navigate back
go_forward - Navigate forward
... (100 more methods with all options)
```

## File Size & Organization

- conventions.md: < 200 lines
- Split to topics/ when > 400 lines total
- Remove redundant cross-references (same domain files load together)
- Cross-domain refs: "Refer to project memory"

**Two-level hierarchy maximum:**

```
authorization/          # First-class topic gets directory
├── conventions.md
└── topics/
    ├── pundit-policies.md
    ├── pundit-controllers.md
    └── pundit-views.md

models/topics/
└── discard-soft-delete.md  # Sub-topic: single comprehensive file
```

**NEVER create three-level hierarchies:**
```
❌ models/topics/soft-delete/
   ├── concept.md
   └── discard.md
```

## Philosophy vs Implementation Separation

When conventions depend on tool choices, separate into two layers:

### Universal Philosophy Layer (Always Present)

Principles that apply regardless of tool choice:

```markdown
# testing/conventions.md

## Mocking Policy

DEFAULT: Prefer real objects and recorded interactions.

Mock when cost-benefit favors it:
1. Can I test this with real objects? → Don't mock
2. Is reproducing this impractical? → Consider mocking
```

Characteristics:
- No tool names (Minitest, RSpec, VCR, WebMock)
- No gem-specific syntax
- Decision frameworks, principles, "when to use" guidance
- Works for users of any tool in that category

### Tool-Specific Implementation Layer (Conditional)

Gem/framework-specific patterns:

```markdown
# testing/topics/minitest-spec-structure.md

## Minitest Spec Syntax
describe/it/let/before patterns...
```

Characteristics:
- Gem name in filename: `[gem]-[function].md`
- Comprehensive (concept + implementation in one file)
- Only loads when gem detected
- No cross-references to universal files (works standalone)

Examples: `minitest-spec-structure.md`, `vcr-external-apis.md`, `discard-soft-delete.md`

### Categories Requiring Flexibility

- Testing frameworks: Minitest vs RSpec
- Test data: Fixtures vs FactoryBot vs builders
- Assertions: Minitest assertions vs RSpec matchers
- System tests: Capybara vs other browser automation
- HTTP recording: VCR vs WebMock vs other tools

**Exception:** Rails-specific patterns (ActiveRecord, ActionController) are fine - this is a Rails project.

## Composability & Cross-References

### Files Must Work Independently

DO NOT assume other files are present:

```markdown
# ❌ BAD - Assumes VCR file exists
Use VCR for external APIs (see vcr-external-apis.md for details)

# ✅ GOOD - Works without VCR file
Use recorded HTTP interactions for external API happy paths
```

### Cross-Reference Rules

**Within same context (same directory) → NO cross-references:**

```markdown
# ❌ BAD in models/topics/associations.md
See discard-soft-delete.md for soft delete filtering

# ✅ GOOD
Filtering soft-deleted records with scoped associations
```

All `models/topics/*.md` files load together when editing models. Cross-references are redundant.

**Across different contexts → DO cross-reference:**

```markdown
# ✅ GOOD in controllers/conventions.md
For authorization patterns, see authorization rules

# ✅ GOOD in views/conventions.md
For authorization in views, refer to project memory
```

Controller rules don't auto-load with authorization rules. User needs pointer.

### Gem-Specific Files Are Comprehensive

Include concept + implementation in single file:

```markdown
# discard-soft-delete.md

## What is Soft Delete
Brief explanation (2-3 sentences max)

## Usage
Discard gem API

## Project Rules
When we use soft delete filtering

## Patterns
Scoped associations, testing
```

DON'T split into: `soft-delete.md` (concept) + `discard-soft-delete.md` (implementation)

## Domain Focus

Domain files focus on domain patterns, NOT cross-cutting tools.

**Belongs in business-logic.md:** Testing command success/failure paths, context population patterns, transaction behavior, idempotency testing

**DOESN'T belong:** How to use VCR (that's in vcr-external-apis.md), how to mock external APIs (that's in conventions.md mocking policy), Minitest syntax (that's in minitest-spec-structure.md)

**Rule:** If it's about a tool/framework used across multiple domains, it doesn't belong in domain-specific files.

## File Naming

**Gem-specific files:** `[gem-name]-[function].md`
- Examples: `discard-soft-delete.md`, `pundit-policies.md`, `minitest-spec-structure.md`, `vcr-external-apis.md`

**Universal files:** `[concept].md`
- Examples: `associations.md`, `concerns.md`, `conventions.md`

## Quick Quality Checklist

Before finalizing any rules file:

- [ ] No "why use X" or benefits sections
- [ ] No tool opinions (unless gem-specific file)
- [ ] No cross-references within same context
- [ ] Domain files don't teach cross-cutting tools
- [ ] Gem-specific files have gem name in filename
- [ ] No method signatures for specific modules
- [ ] No "what is X" education (just conventions)
- [ ] File works independently of other files
- [ ] Focus on WHEN/HOW, not WHAT/WHERE
