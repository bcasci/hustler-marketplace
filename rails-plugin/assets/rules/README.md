# Rules Assets

Portable, reusable rule files for seeding `.claude/rules/` directories in Rails projects.

---

## What This Is

**Source of truth** for Rails conventions organized by domain with composable, gem-specific topics.

**Organization:**
- Universal conventions and topics (always copied)
- Gem-specific topic folders (only copied when gem detected)

---

## How It Works

### Bootstrap (One Time - This Project)

This project has battle-tested conventions from 500+ commits organized into portable assets:

```bash
# Existing rules → Organized assets
.claude/rules/ → .claude/rules-assets/
```

### Reuse (Future Projects)

Copy this `rules-assets/` folder to a new Rails project, then run `/init-rules`:

```bash
# 1. Copy assets
cp -r path/to/this/project/.claude/rules-assets new-project/.claude/

# 2. In new project
cd new-project
# Run /init-rules command

# 3. Result: Tailored rules based on new project's gems
```

---

## Structure

```
rules-assets/
├── models/
│   ├── conventions.md              # Universal
│   └── topics/
│       ├── associations.md         # Universal
│       ├── concerns.md            # Universal
│       └── discard/               # Gem-specific (Discard gem)
│           └── discard-soft-delete.md
├── views/
│   ├── conventions.md              # Universal
│   ├── topics/
│   │   └── template-library.md    # Universal
│   └── examples/
│       ├── beercss/               # Universal (CSS framework)
│       ├── simple_form/           # Gem-specific
│       └── turbo/                 # Gem-specific
├── controllers/
│   └── conventions.md              # Universal
├── testing/
│   ├── conventions.md              # Universal
│   └── topics/
│       ├── anti-patterns.md       # Universal
│       ├── minitest/              # Gem-specific
│       ├── vcr/                   # Gem-specific
│       └── capybara/              # Gem-specific
├── authorization/
│   └── topics/
│       └── pundit/                # Gem-specific
│           ├── pundit-policies.md
│           ├── pundit-controllers.md
│           └── pundit-views.md
├── locales/
│   ├── conventions.md              # Universal
│   └── topics/
│       └── simple_form/           # Gem-specific
└── ...
```

**Key principles:**
- All files organized by Rails domain (models/, views/, testing/, etc.)
- Topic folders named after gems they support
- Topic folder name = gem name detection key
- Composable files (reference only what exists in project)

---

## The `/init-rules` Command

**What it does:**

1. Copies base structure (conventions + universal topics + universal examples)
2. Reads `Gemfile.lock` to detect gems
3. For each detected gem, copies matching topic folders AND examples
4. Reports what was created

**Example:**

```
User: /init-rules

Claude:
✓ Copied universal conventions + topics + examples
✓ Detected gems: pundit, simple_form, minitest, vcr
✓ Copied gem content:
  - authorization/topics/pundit
  - locales/topics/simple_form
  - views/topics/simple_form
  - views/examples/simple_form
  - ...

📦 hustler-rails rules initialized! 40 files created.
```

---

## Adding Support for a New Gem

**Example: Adding Devise support**

1. Create topic folder in appropriate domain:

```bash
mkdir -p models/topics/devise
mkdir -p controllers/topics/devise
```

2. Write convention files:

```bash
# models/topics/devise/devise-models.md
# controllers/topics/devise/devise-controllers.md
```

3. Done! Next `/init-rules` will copy these if Devise detected.

---

## Supported Gems

Current gems with topic folders:

- **Authorization:** pundit
- **Forms:** simple_form
- **Models:** discard
- **Views:** turbo (from turbo-rails)
- **Testing:** minitest, vcr, capybara, shoulda-matchers

Add more by creating `[domain]/topics/[gem-name]/` folders.

---

## File Organization

**Universal files (always copied):**
- conventions.md (domain-level patterns)
- Individual .md files in topics/ (not in subdirectories)
- examples/beercss/ (CSS framework, not a gem)
- examples/README.md

**Gem-specific files (only copied when gem detected):**
- Topic subdirectories: `topics/[gem-name]/`
- Example subdirectories: `examples/[gem-name]/`
- Files are composable (only reference what exists)

---

## Topic Folder Naming

**Convention:** Folder name matches gem name

**Mappings:**
- `turbo-rails` gem → `turbo/` topic folder
- `simple_form` gem → `simple_form/` topic folder
- Most gems → use gem name as-is

**Detection:** Command searches for topic folders matching detected gem names.

---

## Maintenance

**Adding files:**
- Universal → Add to domain root or topics/ as individual file
- Gem-specific → Add to topics/[gem-name]/ folder

**Updating files:**
- Edit files in rules-assets/
- Changes propagate to new projects via `/init-rules`
- Existing projects don't auto-update (by design)

**Removing gems:**
- Delete topics/[gem-name]/ folder
- Future `/init-rules` won't copy it

---

## Design Principles

1. **KISS** - Simple cp commands, no complex rsync excludes
2. **Folder-based organization** - Gem-specific content in `topics/[gem-name]/` folders, NOT gem prefixes in filenames
3. **Composable** - Files reference only what EXISTS in project
4. **Portable** - Copy assets folder, run /init-rules, done
5. **Self-documenting** - Folder names show gem relationship
6. **Battle-tested** - Conventions from real production use
7. **Deterministic** - Same gems = same folders copied
8. **Human-maintainable** - Domain-organized (models/, views/, testing/, etc.)

---

## See Also

- **Command:** `.claude/commands/init-rules.md` - `/init-rules` documentation
- **Plan:** `/tmp/phase-7-pure-llm-plan.md` - Implementation plan
- **Settings:** `.claude/settings.json` - Bash permissions required
