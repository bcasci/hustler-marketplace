---
paths: app/views/**/*.erb
dependencies: [simple_form]
examples: [simple_form]
---

# Simple Form Patterns

Simple Form gem conventions for this project.

---

## Critical Rules

**NEVER add wrapper divs around inputs** - Simple Form auto-generates them:

```erb
<%# ❌ BAD - Extra wrapper %>
<div class="field">
  <%= f.input :name %>
</div>

<%# ✅ GOOD - Let Simple Form generate wrapper %>
<%= f.input :name %>
```

**Why**: Simple Form automatically wraps inputs with proper markup. Adding extra divs breaks styling and structure.

---

## I18n Integration

**Always use i18n for labels/placeholders.**

Simple Form automatically fetches translations from:

- `simple_form.labels.[model].[attribute]`
- `simple_form.placeholders.[model].[attribute]`
- `simple_form.hints.[model].[attribute]`

**See locales rules** for Simple Form i18n patterns (defaults, action-specific, namespaced models).

**Never hardcode labels:**

```erb
<%# ❌ BAD - Hardcoded label %>
<%= f.input :title, label: 'Album Title' %>

<%# ✅ GOOD - Auto-fetched from i18n %>
<%= f.input :title %>
```

---

## Custom Inputs

**Check for existing custom inputs before implementing:**

```bash
ls app/inputs/
```

**Common custom inputs in this project:**

- `image_upload_input.rb` - Image file upload with preview
- `tag_select_input.rb` - Tag selection interface
- Others discoverable in `app/inputs/`

**Usage:**

```erb
<%= f.input :cover_image, as: :image_upload %>
<%= f.input :tags, as: :tag_select %>
```

**When to create custom input:**

- Complex input logic (file upload, multi-select, date picker)
- Reused across 3+ forms
- Significant markup/JavaScript required

**When NOT to create:**

- One-off custom markup (use HTML in form)
- Simple styling changes (use CSS)

---

## Standard Form Pattern

```erb
<%= simple_form_for [:manage, @album] do |f| %>
  <%= f.input :name %>
  <%= f.input :description %>
  <%= f.input :release_date, as: :string, input_html: { type: 'date' } %>
  <%= f.input :cover_image, as: :image_upload %>
  <%= f.button :submit %>
<% end %>
```

**Pattern:**

- Namespace in form target: `[:manage, @album]`
- Minimal attributes (let i18n handle labels)
- Custom inputs when available
- Submit button at end

---

## Nested Forms

**Use `simple_fields_for` for associations:**

```erb
<%= simple_form_for @album do |f| %>
  <%= f.input :name %>

  <%= f.simple_fields_for :tracks do |track_form| %>
    <%= track_form.input :title %>
    <%= track_form.input :duration %>
  <% end %>

  <%= f.button :submit %>
<% end %>
```

**I18n for nested forms:** Use the association name you pass to `simple_fields_for` (e.g., `:posts` not `:post`).

---

## Discovery

**Find existing forms:**

```bash
# All Simple Form usage
Grep "simple_form_for" app/views/**/*.erb

# Custom input usage
Grep "as: :" app/views/**/*.erb

# Fields for nested forms
Grep "simple_fields_for" app/views/**/*.erb
```

**Find custom inputs:**

```bash
# List all custom inputs
ls app/inputs/

# See custom input implementation
Read app/inputs/image_upload_input.rb
```

**Find form examples:**

```bash
# Forms in manage namespace
Glob "app/views/manage/**/_form.html.erb"

# All form partials
Glob "app/views/**/_form.html.erb"
```
