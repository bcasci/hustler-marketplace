---
paths: "config/locales/**/*.yml"
dependencies: [simple_form]
---

# Simple Form I18n Integration

---

## Auto-Fetch Behavior

Don't specify translations in views - Simple Form looks them up automatically:

```erb
<%# ✅ GOOD %>
<%= f.input :title %>

<%# ❌ BAD - Hardcoded %>
<%= f.input :title, label: 'Album Title' %>
```

---

## Key Structure

### Basic Pattern

```yaml
en:
  simple_form:
    labels:
      album:
        title: "Album Title"
    placeholders:
      album:
        description: "Describe your album..."
    hints:
      album:
        metadata_credits: "Optional credits"
```

**File:** `config/locales/simple_form.en.yml`

### Defaults (DRY)

```yaml
en:
  simple_form:
    labels:
      defaults:
        email: "Email Address"      # All models
      user:
        email: "Login Email"         # Overrides for User
```

**Lookup order:** Model-specific → Defaults → `human_attribute_name`

### Action-Specific

```yaml
en:
  simple_form:
    labels:
      album:
        new:
          title: "Album Title"
        edit:
          title: "Edit Album Title"
```

---

## Namespaced Models

Use underscored format (not slashed):

```yaml
en:
  simple_form:
    labels:
      admin_user:        # ✅ CORRECT
        name: "Admin Name"
      # NOT admin/user   # ❌ WRONG
```

**Note:** ActiveRecord translations use slashed format (`admin/user`). Simple Form translations use underscored (`admin_user`).

---

## Collection Options

Translate select/radio/checkbox options:

```yaml
en:
  simple_form:
    options:
      album:
        status:
          draft: "Draft"
          published: "Published"
```

```erb
<%= f.input :status, collection: [:draft, :published] %>
```

**Critical:** Only works with symbol collections. String arrays bypass i18n.

---

## Prompts and Include Blank

Requires `:translate` option to enable i18n lookup:

```yaml
en:
  simple_form:
    prompts:
      album:
        genre: "Choose a genre..."
    include_blanks:
      album:
        category: "No category"
```

```erb
<%= f.input :genre, prompt: :translate %>
<%= f.input :category, include_blank: :translate %>
```

---

## Buttons

Uses Rails `helpers.submit`:

```yaml
en:
  helpers:
    submit:
      album:
        create: "Create Album"
        update: "Update Album"
```

```erb
<%= f.button :submit %>  # Auto-detects create/update
```

---

## Fallback Behavior

1. `simple_form.labels.album.title`
2. `activerecord.attributes.album.title`
3. `Album.human_attribute_name(:title)`

ActiveRecord translations work as fallbacks.

---

## Override in Views

Override when i18n lookup won't work:

```erb
<%# Context-specific %>
<%= f.input :email, label: "Recovery Email" %>

<%# Dynamic %>
<%= f.input :price, label: "Price in #{currency}" %>
```

---

## simple_fields_for

Use the name passed to `simple_fields_for`:

```yaml
en:
  simple_form:
    labels:
      posts:          # ✅ Use :posts (as passed)
        title: "Post title"
      # NOT post      # ❌ Don't singularize
```

```erb
<%= f.simple_fields_for :posts do |p| %>
  <%= p.input :title %>
<% end %>
```

---

## Discovery

**Find Simple Form translations:**

```
Grep "simple_form:" config/locales/**/*.yml
```

**Find hardcoded labels (anti-pattern):**

```
Grep "f.input.*label:" app/views/**/*.erb
```
