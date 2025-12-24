---
paths: app/views/**/*.erb, app/models/view_models/**/*.rb
dependencies: []
---

# View Conventions

**Views are THIN.** Structure and layout only. Extract everything else.

---

## MANDATORY: Before Writing ANY View Code

**You MUST follow this process (not optional):**

1. **Find the most similar existing view**

   - Search existing views for similar patterns
   - Or use a scaffold from `templates/` directory

2. **Copy the entire structure**

3. **Modify only:**

   - Model names
   - Attribute names
   - Path helpers
   - Content text

4. **NEVER create view markup from scratch** - AI consistently fails at this

**If you cannot find a similar view, use a scaffold from `templates/`**

---

## What Belongs in Views (THIN Views)

**Views contain:**

- Structural markup (`<article>`, `<div>`, `<nav>`, `<section>`)
- Section comments (`<%# Related items - lazy loaded %>`)
- Helper method calls (`<%= render_resource(@resource, :style) %>`)
- Conditional rendering (if/unless for showing sections)
- Layout coordination (where sections appear on page)

**Views DO NOT contain:**

- Business logic
- Complex conditionals
- Data transformations
- Loops that build data structures
- Database queries
- Extensive markup (extract to partials/helpers)

---

## Extraction Decision Tree

### Extract to Helper (render\_\* method)

**When:**

- Rendering domain objects with multiple styles
- UI components with configuration logic
- Need polymorphic rendering (same object, different styles)
- Component appears across multiple controllers

**Pattern:**

```ruby
# app/helpers/resources_helper.rb
def render_resource(resource, style = :list_item, **options)
  method_name = "render_resource_#{style}"
  if respond_to?(method_name, true)
    send(method_name, resource, **options)
  else
    render_resource_list_item(resource, **options)
  end
end

def render_resource_card(resource, **options)
  render partial: 'shared/resource/card', locals: { resource:, **options }
end
```

**Search existing:** `Grep "def render_" app/helpers/**/*.rb`

---

### Extract to Shared Partial

**When:**

- Component used across multiple controllers/domains
- UI element with standard structure (avatar, flash, loading, chip)
- Need documentation of usage pattern
- Component accepts configuration via locals

**Location:** `app/views/shared/`

**Organization:**

- Single-file components: `shared/_component.html.erb`
- Domain subdirectories: `shared/[domain]/`

**Pattern:**

```erb
<%# Usage: render 'shared/component', required_param:, optional: 'default' %>
<%# Required: required_param %>
<%# Optional: optional (default: 'default') %>
<% optional ||= local_assigns.fetch(:optional, 'default') %>

<div class="component">
  <%= required_param %>
</div>
```

**Structure:**
- Usage comment shows how to call partial
- Document required vs optional locals
- Use `local_assigns.fetch` for defaults
- Keep markup implementation-agnostic

**CRITICAL:** Add usage comment at top of partial

**Search existing:** `Glob "app/views/shared/**/*.erb"`

---

### Extract to Local Partial (Same Directory)

**When:**

- Section of a page gets too large (>20 lines)
- Form markup (always extract to `_form.html.erb`)
- Repeated sections within same view
- Collection item rendering (Rails automatically looks for `_[singular].html.erb`)

**Location:** Same directory as view

**Common patterns:**

- `_form.html.erb` - Form markup
- `_section.html.erb` - Page section
- `_resource.html.erb` - Collection item (rendered by `<%= render @resources %>`)

**Search existing:** `find app/views/[controller] -name "_*.erb"`

---

### Extract to ViewModel

**When:**

- Presentation logic involves multiple models
- Complex conditionals for display
- Need to test presentation logic separately
- Data transformation for display

**See:** `models/topics/view-models.md` for ViewModel patterns

---

## Polymorphic Rendering Pattern

**Standard pattern for domain objects with multiple display styles:**

```ruby
# Helper provides meta method and specific style methods
def render_resource(resource, style = :list_item, **options)
  send("render_resource_#{style}", resource, **options)
end

def render_resource_card(resource, **options)
  render partial: 'shared/resource/card', locals: { resource:, **options }
end

def render_resource_tile(resource, **options)
  render partial: 'shared/resource/tile', locals: { resource:, **options }
end
```

**Usage in views:**

```erb
<%= render_resource(@resource, :card, show_actions: true) %>
<%= render_resource(@resource, :tile) %>
<%= render_resource(@resource, :list_item) %>
```

**Find examples:** `Grep "def render_.*style" app/helpers/**/*.rb`

---

## Partial Documentation

**ALWAYS add usage comment at top of shared partials:**

```erb
<%# Usage: render 'shared/component', required_param:, optional: 'value' %>
<%# Required: required_param %>
<%# Optional: optional (default: 'value') %>
```

**Shows:**

- How to call the partial
- Required vs optional locals
- Available options/values

**Bad:** No documentation - future developers can't discover usage

---

## Comments in Views

**Good comments explain SECTIONS, not code:**

```erb
<%# Item listing - lazy loaded %>
<article id="item-list">
  <%= render_content(@items) %>
</article>

<%# Related content - lazy loaded %>
<div id="related-content">
  <%= render_content(@related) %>
</div>
```

**Bad comments explain obvious code:**

```erb
<%# Render the resource %>  <%# Obvious %>
<%= render_resource(@resource) %>

<%# Check if attribute exists %>  <%# Obvious from if statement %>
<% if @resource.attribute.present? %>
```

---

## Discovery

**Find helpers:**

```bash
# Polymorphic rendering helpers
Grep "def render_.*style" app/helpers/**/*.rb

# All render helpers
Grep "def render_" app/helpers/**/*.rb
```

**Find partials:**

```bash
# Shared partials
ls app/views/shared/

# All shared partials
Glob "app/views/shared/**/*.erb"

# Local partials for a controller
find app/views/[controller] -name "_*.erb"
```

**Find usage:**

```bash
# How a helper is used
Grep "render_[helper]" app/views/**/*.erb

# How a partial is used
Grep "render.*'shared/[partial]'" app/views/**/*.erb
```

---

## Quick Reference

| Content                    | Extract To     | Location                  | Example                            |
| -------------------------- | -------------- | ------------------------- | ---------------------------------- |
| Domain object display      | Helper         | `app/helpers/`            | `render_resource(resource, :card)` |
| App-wide UI component      | Shared partial | `app/views/shared/`       | `render 'shared/component'`        |
| Page section               | Local partial  | Same directory            | `render 'section'`                 |
| Complex presentation logic | ViewModel      | `app/models/view_models/` | `ResourceViewModel.new(resource)`  |
| Form                       | Local partial  | `_form.html.erb`          | `render 'form'`                    |
| Collection item            | Local partial  | `_resource.html.erb`      | `render @resources`                |

---

## Template Library

**Structural scaffolds:** `templates/` for copyable patterns:

- Index pages
- Show pages
- Forms
- Dialogs
- Turbo frames
- Empty states
