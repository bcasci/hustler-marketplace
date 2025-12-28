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

Every domain uses ONE of these patterns:

**Single file:**

```
domain/conventions.md
```

**Multiple topics (universal domain):**

```
domain/
├── conventions.md
└── topics/*.md
```

**Topics only (optional domain):**

```
domain/
└── topics/
    ├── [gem]-[feature].md
    └── [gem]-[feature].md
```

**When to use each:**
- **Single file**: Domain has < 200 lines of conventions
- **Multiple topics with conventions.md**: Domain has universal conventions that apply regardless of gem choice
- **Topics only**: Domain represents optional feature where implementation is delegated to gems (no universal conventions exist)

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

---

## Domain Organization Guidelines

### Optional vs Universal Domains

**Universal domains** have conventions that apply regardless of implementation choice:
- `models/` - ActiveRecord patterns apply to all Rails apps
- `controllers/` - ActionController patterns apply to all Rails apps
- `views/` - ActionView patterns apply to all Rails apps
- `architecture/` - Design principles apply regardless of framework choices
- `code-style/` - Ruby idioms apply regardless of gems used

**Optional domains** represent features where implementation is delegated to gem choices:
- `authentication/` - Passwordless, Devise, Clearance, etc.
- `authorization/` - Pundit, CanCanCan, ActionPolicy, etc.

**Rule for optional domains:**
- Include `conventions.md` ONLY if genuine cross-gem conventions exist (e.g., `current_user` naming)
- Otherwise use topics-only structure with gem-specific files

**Examples:**
```
# Has universal conventions
authentication/
├── conventions.md  # current_user, authenticate_user! naming
└── topics/
    └── passwordless/
        ├── passwordless-user.md
        └── passwordless-session.md

# No universal conventions
authorization/
└── topics/
    └── pundit/
        ├── pundit-policies.md
        └── pundit-controllers.md
```

### Architecture vs Code-Style Boundary

**architecture/** - Macro/strategic decisions at file and class level:
- "Should I extract this logic into a Command?"
- "When do I create a Value Object?"
- "Do I need a Service Layer here?"
- Object-oriented design principles (Tell, Don't Ask)
- Pattern selection (Command, Builder, Query Object)

**code-style/** - Micro/tactical decisions at line and method level:
- "How do I write this conditional?"
- "Should this be a one-liner guard clause?"
- "Can I simplify this string concatenation?"
- Ruby idioms and syntax patterns
- Method-level refactoring patterns

**Test:** If it affects which file code goes in or whether you create a new class → architecture/. If it affects how you write a specific line of code → code-style/.

### Testing Separation for Gem-Specific Features

**Gem-specific features use parallel testing structure:**

Implementation files go in feature domain:
```
authentication/topics/passwordless/
├── passwordless-user.md
├── passwordless-session.md
└── passwordless-routes.md
```

Testing files go in testing domain:
```
testing/topics/passwordless/
├── passwordless-models.md
├── passwordless-controllers.md
├── passwordless-system.md
└── passwordless-mailers.md
```

**Why separate:**
- Testing and implementation are different concerns
- Test files cover multiple test types (models, controllers, system)
- Keeps implementation files focused on patterns, not testing
- Testing domain can load all relevant test patterns together

**Naming:** Use same `[gem]-[aspect]` prefix in both locations for discoverability.

---

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
- `authentication/topics/passwordless/passwordless-user.md` - Only if using Passwordless
- `authorization/topics/pundit/pundit-policies.md` - Only if using Pundit

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
# passwordless-user.md

## What is Passwordless

Brief explanation (2-3 sentences max)

## Usage

Passwordless gem API patterns

## Project Rules

When and how to use passwordless authentication

## Integration Patterns

Session helpers, email flow, multi-tenancy
```

**DON'T split into:**

- `passwordless.md` (concept)
- `passwordless-user.md` (implementation)

**Note:** Testing goes in separate parallel structure (`testing/topics/passwordless/`), not in implementation files.

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
authentication/
├── conventions.md
└── topics/
    └── passwordless/
        ├── passwordless-user.md
        ├── passwordless-session.md
        └── passwordless-routes.md
```

**Sub-topics** get single comprehensive files within topics/:

```
authentication/topics/passwordless/
└── passwordless-user.md  # Comprehensive, includes concept + usage
```

**Testing follows parallel structure:**

```
testing/topics/
└── passwordless/
    ├── passwordless-models.md
    ├── passwordless-controllers.md
    └── passwordless-system.md
```

**NEVER create three-level hierarchies:**

```
❌ authentication/topics/passwordless/implementation/
   ├── user.md
   └── session.md
```

---

## Generic Examples

**Rules must use generic, framework-agnostic examples** - not project-specific implementations.

### Standard Placeholders

**Models:**
- ✅ `@resource`, `@item`, `@related_item`
- ✅ `Resource`, `Item`, `Category`
- ✅ Generic domain models: `Order`, `Customer`, `User`, `Product`
- ❌ `@album`, `@track`, `@variant`, `@listing`
- ❌ Project models: `Album`, `Track`, `Variant`, `Listing`

**Namespaces:**
- ✅ `:namespace`, `:scope`
- ❌ `:manage`, `:admin`, `:seller`, `:buyer`

**Paths:**
- ✅ `namespace_resource_path`, `resource_items_path`
- ❌ `manage_album_path`, `seller_listing_path`

**Attributes:**
- ✅ `name`, `title`, `description`, `published_at`
- ❌ `release_date`, `cover_image`, `listing_state`

**Why:** Examples teach patterns, not specific implementations. Generic examples work for any project.

### Exception: Domain Models

Acceptable to use recognizable domain models when teaching database/business patterns:

```ruby
# ✅ GOOD - Generic e-commerce domain
Order.joins(:customer).where(customers: { active: true })

# ✅ GOOD - Generic HR domain
User.where(department_id: Department.active.select(:id))

# ❌ BAD - Project-specific
Album.joins(:organization).where(organizations: { status: 'active' })
```

Use `Order`, `Customer`, `User`, `Department` for database examples - they're universally understood.

Avoid `Album`, `Track`, `Listing`, `Variant` - these are project-specific.

---

## Quick Quality Checklist

Before finalizing any rules file, verify:

- [ ] No "why use X" or benefits sections
- [ ] No "Benefits:", "Why:", or "Problems:" sections
- [ ] Examples use generic placeholders (@resource, :namespace, not @album, :manage)
- [ ] No tool opinions (unless gem-specific file)
- [ ] No cross-references within same context
- [ ] Domain files don't teach cross-cutting tools
- [ ] Gem-specific files have gem name in filename
- [ ] No method signatures for specific modules
- [ ] No "what is X" education (just conventions)
- [ ] File works independently of other files
- [ ] Focus on WHEN/HOW, not WHAT/WHERE
- [ ] Optional domains only have conventions.md if cross-gem conventions exist
- [ ] Architecture/ placement for macro decisions, code-style/ for micro decisions
- [ ] Testing separated into testing/topics/[feature]/ for gem-specific features
- [ ] Frontmatter paths: and dependencies: accurately reflect scope and requirements
