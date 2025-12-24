# Rails Rules Maintenance Guide

This file describes the structure and maintenance practices for Rails coding convention rules. Use these guidelines whether maintaining the source rules in the plugin or the copied rules in your project.

When maintaining these rules, enforce conventions, not document implementations.

## Core Principles

**Rules teach conventions. Code teaches implementations.**

1. **Conventions, not education** - No sales pitches, no "why use X" content, no benefits sections
2. **Patterns, not APIs** - Show when/how, not what/where for specific modules
3. **Universal by default** - Philosophy first, implementation second
4. **Composable** - Files work independently, minimal cross-references
5. **Domain-focused** - Stay in your lane, don't teach cross-cutting tools

Path-based auto-loading: Files load when their `paths:` frontmatter matches the file you're editing.

## Required Structure

Every domain uses ONE of these patterns (zero exceptions):

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

**Examples:**

- `EventEmission.emit_event(event_name, **payload)` ❌
- Method signatures for `render_album` helper ❌
- FormatMappable mapping table ❌

**→ If YES: Remove it. Belongs in source code comments.**

### 2. Is this discoverable via code navigation?

**Examples:**

- "The `kept_packaged_with` association filters by kept scope" ❌
- Exact parameter names for specific helpers ❌
- List of all BeerCSS button classes ❌

**→ If YES: Remove it. Trust search and inline docs.**

### 3. Is this teaching WHAT IS instead of WHEN/HOW?

**Compare:**

- WHAT IS: "Call `emit_event(:published)` to emit events" ❌
- WHEN/HOW: "Use concerns when 3+ models need same behavior" ✅

**→ If teaching WHAT IS: Remove it.**

### 4. Does this apply to multiple implementations?

**Compare:**

- Multiple: "Use scoped associations for frequently filtered relationships" ✅
- Single: "The albums controller uses a before_action for authorization" ❌

**→ If single implementation: Remove it.**

## Keep These

✅ Architectural decisions (when to use Commands vs. controller logic)
✅ Structure patterns (concern structure, controller patterns)
✅ Cross-cutting requirements (all controllers must use Pundit)
✅ Decision frameworks with criteria
✅ "Do this / Don't do this" comparisons
✅ When to break conventions

## Exception: Structural Scaffolds

**UI construction (views, markup) requires reference structures** because the pattern IS the markup.

**Location:** `views/examples/` (copyable .html.erb files)

**Criteria for scaffolds:**

- Production-derived (actual working code, not hypothetical)
- Copyable files (.html.erb), not documentation
- Minimal annotations (decision points only)
- Rules reference scaffolds, don't embed them

**Example:** `views/examples/beercss/index.html.erb` provides structure to copy. `views/topics/beercss/beercss-components.md` teaches WHEN to use it.

**Why exception needed:** AI consistently fails building views from scratch. Framework-specific syntax (BeerCSS classes, Turbo frame IDs) requires reference implementations, not abstracted patterns.

## Remove These

❌ Method signatures for specific modules
❌ API documentation for individual modules
❌ Configuration tables for specific components
❌ **Comprehensive** gem API documentation (copying gem docs)
❌ Exhaustive option lists
❌ Usage examples for ONE specific module
❌ "Why use X" benefits sections
❌ Educational content about what tools/patterns are
❌ Sales pitches explaining advantages

## Keep These (API References)

✅ **Curated API patterns** - The subset we actually use
✅ **Project integration patterns** - How gem integrates with our stack
✅ **Convention guidance** - Our preferred methods/approaches
✅ **Anti-patterns** - What NOT to use from the API

**Example - Good API Reference:**

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

**Example - Bad API Reference:**

```markdown
# capybara-system-tests.md (BAD)

## All Capybara Methods

visit(url, **options) - Navigate to URL
Options: - wait: Integer (default 2) - **All 15 options documented\*\*
go_back - Navigate back
go_forward - Navigate forward
... (100 more methods with all options)
```

## File Size Limits

- conventions.md: < 200 lines
- Split to topics/ when > 400 lines total
- Remove redundant cross-references (same domain files load together)
- Cross-domain refs: "Refer to project memory"

## Quick Reference

**Good:**

```markdown
## When to Extract Concerns

Extract when:

- 3+ models need same behavior
- Model > 200 lines
- Independent feature name
```

**Bad:**

```markdown
## FormatMappable API

Maps MIME types to formats:

- video/\* → video
- audio/\* → audio

Usage: extract_format_from_content_type(type)
```

**Why bad:** Documents one module. Move to `app/models/concerns/format_mappable.rb`.

## Action Items

When you see:

- Method signatures → Move to source comments
- Component catalogs → Link to source or remove
- One-module examples → Replace with pattern principles
- Mapping tables → Remove (discoverable in code)
- "Why use X" sections → Remove entirely
- "Benefits of X" → Remove entirely
- Tool opinions ("We use Minitest") → Make universal or extract to gem-specific file

---

## Philosophy vs Implementation Separation

**When conventions depend on tool choices, separate into two layers:**

### Universal Philosophy Layer (Always Present)

Contains principles that apply regardless of tool choice:

```markdown
# testing/conventions.md

## Mocking Policy

DEFAULT: Prefer real objects and recorded interactions.

Mock when cost-benefit favors it:

1. Can I test this with real objects? → Don't mock
2. Is reproducing this impractical? → Consider mocking
```

**Characteristics:**

- No tool names (Minitest, RSpec, VCR, WebMock)
- No gem-specific syntax
- Decision frameworks, principles, "when to use" guidance
- Works for users of any tool in that category

### Tool-Specific Implementation Layer (Conditional)

Contains gem/framework-specific patterns:

```markdown
# testing/topics/minitest-spec-structure.md

## Minitest Spec Syntax

describe/it/let/before patterns...
```

**Characteristics:**

- Gem name in filename: `[gem]-[function].md`
- Comprehensive (concept + implementation in one file)
- Only loads when gem detected
- No cross-references to universal files (works standalone)

**Examples:**

- `testing/topics/minitest-spec-structure.md` - Only if using Minitest
- `testing/topics/vcr-external-apis.md` - Only if using VCR
- `models/topics/discard-soft-delete.md` - Only if using Discard gem

---

## Composability Rules

### Files Must Work Independently

**DO NOT assume other files are present:**

```markdown
# ❌ BAD - Assumes VCR file exists

Use VCR for external APIs (see vcr-external-apis.md for details)

# ✅ GOOD - Works without VCR file

Use recorded HTTP interactions for external API happy paths
```

### Cross-References Strategy

**Within same context (same directory) → NO cross-references:**

```markdown
# ❌ BAD in models/topics/associations.md

See discard-soft-delete.md for soft delete filtering

# ✅ GOOD

Filtering soft-deleted records with scoped associations
```

**Why:** All `models/topics/*.md` files load together when editing models. Cross-references are redundant.

**Across different contexts → DO cross-reference:**

```markdown
# ✅ GOOD in controllers/conventions.md

For authorization patterns, see authorization rules

# ✅ GOOD in views/conventions.md

For authorization in views, refer to project memory
```

**Why:** Controller rules don't auto-load with authorization rules. User needs pointer.

### Gem-Specific Files Are Comprehensive

**Include concept + implementation in single file:**

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

**DON'T split into:**

- `soft-delete.md` (concept)
- `discard-soft-delete.md` (implementation)

Sub-topics use single comprehensive files.

---

## Domain Focus - Stay In Your Lane

**Domain files focus on domain patterns, NOT cross-cutting tools.**

### What Belongs in Domain Files

```markdown
# business-logic.md ✅

- Testing command success/failure paths
- Context population patterns
- Transaction behavior
- Idempotency testing
```

### What DOESN'T Belong

```markdown
# business-logic.md ❌

- How to use VCR (that's in vcr-external-apis.md)
- How to mock external APIs (that's in conventions.md mocking policy)
- Minitest syntax (that's in minitest-spec-structure.md)
```

**Rule:** If it's about a tool/framework used across multiple domains, it doesn't belong in domain-specific files.

---

## Tool Flexibility - No Opinions

**Rules must support multiple valid tool choices in same category.**

### Bad - Tool Opinionated

```markdown
IMPORTANT: We use Minitest with spec syntax and fixtures
```

**Why bad:** Excludes RSpec users, FactoryBot users

### Good - Tool Flexible

```markdown
## Test Data Philosophy

Make test data explicit when it matters.
Use baseline data for structure.
```

**Why good:** Works for Minitest/RSpec, Fixtures/FactoryBot/builders

### Categories Requiring Flexibility

- **Testing frameworks:** Minitest vs RSpec
- **Test data:** Fixtures vs FactoryBot vs builders
- **Assertions:** Minitest assertions vs RSpec matchers
- **System tests:** Capybara vs other browser automation
- **HTTP recording:** VCR vs WebMock vs other tools

**Exception:** Rails-specific patterns (ActiveRecord, ActionController) are fine - this is a Rails plugin.

---

## File Naming Conventions

### Gem-Specific Files

**Pattern:** `[gem-name]-[function].md`

**Examples:**

- `discard-soft-delete.md`
- `pundit-policies.md`
- `pundit-controllers.md`
- `minitest-spec-structure.md`
- `vcr-external-apis.md`

**Why:** Clear which gem this file requires. Simple automation mapping.

### Universal Files

**Pattern:** `[concept].md`

**Examples:**

- `associations.md`
- `concerns.md`
- `conventions.md`

---

## No Sales Pitches

**Rules enforce conventions, not sell tools.**

### Bad - Sales Pitch

```markdown
## Why Soft Delete

Benefits:

- Safer than hard delete
- Audit trail preservation
- Easy data recovery
- Prevents accidental data loss
```

**Why bad:** Educational content about tool benefits. Not conventions.

### Good - Conventions

```markdown
## Project Rules

**Filtering:**

- Shopping UI → Use `.kept`
- Order history → Include discarded (buyers retain access)
- Admin interfaces → Context-dependent

## Scoped Associations

has_many :kept_packaged_with, -> { kept }
```

**Why good:** Shows HOW we use it, not WHY it's good.

---

## Two-Level Hierarchy Maximum

**First-class topics** get directories:

```
authorization/
├── conventions.md
└── topics/
    ├── pundit-policies.md
    ├── pundit-controllers.md
    └── pundit-views.md
```

**Sub-topics** get single comprehensive files:

```
models/topics/
└── discard-soft-delete.md  # Comprehensive, no sub-directory
```

**NEVER create three-level hierarchies:**

```
❌ models/topics/soft-delete/
   ├── concept.md
   └── discard.md
```

---

## Quick Quality Checklist

Before finalizing any rules file, verify:

- [ ] No "why use X" or benefits sections
- [ ] No tool opinions (unless gem-specific file)
- [ ] No cross-references within same context
- [ ] Domain files don't teach cross-cutting tools
- [ ] Gem-specific files have gem name in filename
- [ ] No method signatures for specific modules
- [ ] No "what is X" education (just conventions)
- [ ] File works independently of other files
- [ ] Focus on WHEN/HOW, not WHAT/WHERE
