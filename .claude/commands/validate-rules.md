---
name: validate-rules
description: Comprehensive validation of rule files against CLAUDE.md guidelines
---

# Validate Rules

Validates all modified rule files for CLAUDE.md compliance, composability, and consistency.

**Apply standards from project memory.**

## Validation Workflow

### Phase 1: Inventory & Categorize

```bash
git status --short rails-plugin/skills/init-rules/assets/rules/
```

Categorize files:

- Just modified (this session) - Light validation
- Modified earlier - Full validation needed
- New files - Full validation + placement check

### Phase 2: Full Content Validation

**For each file needing validation, READ ENTIRE FILE and check:**

#### A. CLAUDE.md Compliance

- No "Benefits:", "Why:", "Problems:" sections
- Generic examples only (@resource, :namespace, not @album, :manage)
- Teaches WHEN/HOW, not WHAT/WHERE
- No method signatures for specific modules
- No comprehensive API documentation

#### B. Frontmatter Accuracy

```yaml
paths: app/models/**/*.rb # Matches actual scope
dependencies: [turbo-rails] # Lists required frameworks
examples: [turbo] # If examples directory exists
```

Verify:

- `paths:` matches file's actual scope
- `dependencies:` complete and minimal
- No conflicts with other files

#### C. Composability

Files with same `paths:` load together - verify they are:

- **Complementary** (not duplicative)
- **Independent** (work without each other)
- **Additive** (knowledge builds together)

Example: All `paths: app/views/**/*.erb` files load together - ensure no duplication.

#### D. Universal vs Framework Separation

- Universal files (`dependencies: []`) → Only Rails core patterns
- Framework files (`dependencies: [gem]`) → Framework content allowed

### Phase 3: Cross-File Consistency

**Check relationships between ALL modified files:**

#### 1. Topic Duplication Check

Use Grep to find patterns across files:

```bash
Grep "form_for|simple_form_for" rails-plugin/skills/init-rules/assets/rules/views/
Grep "turbo_frame|turbo_stream" rails-plugin/skills/init-rules/assets/rules/views/
```

Ask: Is any concept taught in multiple files?

- Different perspectives (WHEN in one, HOW in another)? ✅ OK
- Actual duplication? ❌ Fix it

#### 2. Auto-Loading Overlap

Group files by `paths:`:

- Models: `paths: app/models/**/*.rb`
- Views: `paths: app/views/**/*.erb`
- Controllers: `paths: app/controllers/**/*.rb`

For each group, verify:

- No topic duplication
- Files are complementary (different aspects)
- Knowledge builds together (additive)

#### 3. Terminology Consistency

```bash
Grep "eager load|preload|includes" rails-plugin/skills/init-rules/assets/rules/models/
Grep "when to use" rails-plugin/skills/init-rules/assets/rules/views/
```

Check:

- Same terms for same concepts?
- No contradictions in decision frameworks?

### Phase 4: Report & Fix

Generate report:

```markdown
## Validation Report

### Files Validated: X total

**Issues Found:**

1. file.md - Line X: Sales pitch ("Benefits:")
2. file.md - Line Y: Project-specific example (@album)
3. file.md - Duplication with other-file.md

**Cross-File Issues:**

- Topics A and B duplicated in files X and Y

**Fixes Applied:**

- Removed sales pitches (3 files)
- Genericized examples (2 files)
- Resolved duplication (moved content to correct file)

**Status:** ✅ All files pass validation
```

## Success Criteria

- [ ] All files pass CLAUDE.md compliance
- [ ] No sales pitches or project-specific examples
- [ ] No duplication across auto-loaded files
- [ ] Frontmatter accurate
- [ ] Cross-file consistency verified
- [ ] Report generated
