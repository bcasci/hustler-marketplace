---
paths: "app/views/**/*.erb"
dependencies: []
---

# Form Helper Patterns

Rails form helper conventions.

---

## Form Object Patterns

### Default: Polymorphic Arrays

**Rails can infer routes from object arrays:**

```erb
<%# Namespaced resource - Rails infers namespace_resource_path %>
<%= form_for [:namespace, @resource] do |f| %>

<%# Nested resource - Rails infers parent_child_path %>
<%= form_for [@parent, @child] do |f| %>

<%# Simple resource - Rails uses model conventions %>
<%= form_for @resource do |f| %>
```

**Works with:**
- `form_for` (Rails form builder)
- `simple_form_for` (SimpleForm gem)
- `form_with` (Rails 5.1+)

---

### Use Explicit URL When Polymorphic Is Burdensome

**When Rails cannot infer the route:**

```erb
<%# Non-standard routing (settings, dashboards, non-RESTful routes) %>
<%= form_for @resource, url: settings_path, method: :patch do |f| %>

<%# Command objects with dynamic URLs %>
<%= form_for command, as: :allowed_tag, url: @form_url, method: :patch do |f| %>

<%# Forms requiring multiple parameters in route %>
<%= form_for @resource,
             url: namespace_resource_path(param1, param2),
             method: :patch do |f| %>

<%# Inline forms with special behavior %>
<%= form_for @resource,
             url: resource_path(@resource),
             method: :patch,
             html: { data: { controller: "auto-submit" } } do |f| %>
```

**When polymorphic is burdensome:**

- Non-RESTful routes
- Routes requiring multiple parameters
- Command objects without model-backed routing
- Forms with dynamic target URLs
- Special form behavior (auto-submit, etc.)

---

## Decision Framework

**Start with polymorphic array** (default):
- Let Rails infer the route
- Cleaner, more conventional code
- Works for 80% of forms

**Use explicit URL when**:
- Route doesn't follow REST conventions
- Multiple parameters needed in route
- Command/form objects without model routing
- Dynamic URLs based on state

---

## Discovery

**Find form patterns:**

```bash
# Polymorphic form usage
Grep "form_for \[" app/views/**/*.erb

# Explicit URL usage
Grep "url:" app/views/**/*.erb | grep "form_for\|simple_form_for"

# Namespaced forms
Grep "form_for \[:" app/views/**/*.erb
```
