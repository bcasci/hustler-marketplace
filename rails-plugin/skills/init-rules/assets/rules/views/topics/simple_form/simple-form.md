---
paths: app/views/**/*.erb
dependencies: [simple_form]
examples: [simple_form]
---

# Simple Form Patterns

Simple Form gem conventions.

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
<%= simple_form_for [:namespace, @resource] do |f| %>
  <%= f.input :name %>
  <%= f.input :description %>
  <%= f.input :published_at, as: :string, input_html: { type: 'date' } %>
  <%= f.input :image, as: :file %>
  <%= f.button :submit %>
<% end %>
```

**Pattern:**

- Namespace in form target: `[:namespace, @resource]`
- Minimal attributes (let i18n handle labels)
- Custom inputs when available
- Submit button at end

---

## Submit Button Patterns

### Default: Simple Form Helper

**Rails automatically labels the button:**

```erb
<%= f.button :submit %>
```

Provides "Create [Model]" or "Update [Model]" based on object state.

---

### With Block Form (Custom Content)

**Pass custom content to button:**

```erb
<%= f.button :submit do %>
  Custom content here
<% end %>
```

---

### Manual Button (Last Resort)

**Only when Simple Form helper doesn't work:**

```erb
<button type="submit">Submit</button>
```

**Rule:** Use Simple Form helper when possible - manual buttons sparingly.

---

## Nested Forms

**Use `simple_fields_for` for associations:**

```erb
<%= simple_form_for @resource do |f| %>
  <%= f.input :name %>

  <%= f.simple_fields_for :items do |item_form| %>
    <%= item_form.input :title %>
    <%= item_form.input :quantity %>
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
