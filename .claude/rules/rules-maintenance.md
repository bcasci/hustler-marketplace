---
conditions:
  paths: rails-plugin/skills/init-rules/assets/rules/**/*.md
---

# Plugin Rules Maintenance

When modifying files in `rails-plugin/skills/init-rules/assets/rules/`:

**Apply relevant conventions from project memory.**

## Critical Standards

**No sales pitches:**

- ❌ No "Benefits:", "Why:", or "Problems:" sections
- ✅ Teach WHEN/HOW, not WHY

**Generic examples only:**

- ❌ `@album`, `:manage`, `Album`, `manage_album_path`
- ✅ `@resource`, `:namespace`, `Resource`, `namespace_resource_path`

**Composability:**

- Files with same `paths:` frontmatter load together
- Must be complementary, not duplicative
- Check cross-file consistency

**Framework separation:**

- Universal files (`dependencies: []`) → No framework-specific content
- Framework files (`dependencies: [gem]`) → Framework content allowed

## Common Violations

```markdown
❌ **Benefits:** Cleaner code, easier to maintain
✅ **Pattern:** Let Rails infer routes from arrays

❌ <%= form_for [:manage, @album] do |f| %>
✅ <%= form_for [:namespace, @resource] do |f| %>
```
