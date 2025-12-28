---
paths: config/locales/**/*.yml, app/views/**/*.erb
dependencies: []
---

# Locales and Internationalization

**NEVER hardcode text.** Rails i18n has multiple layers - use the right one for each situation.

---

## Decision Tree: Which Translation Method?

### For Model Names

```erb
<%# Always use Rails helpers %>
<%= Album.model_name.human %>           # "Release" (singular)
<%= Album.model_name.human(count: 2) %> # "Releases" (plural)
```

**Where:** `config/locales/models/album.en.yml` under `activerecord.models.album`

---

### For Attribute Names

```erb
<%# Use human_attribute_name %>
<%= Album.human_attribute_name(:product_inclusions) %> # "Included Products"
```

**Where:** `config/locales/models/album.en.yml` under `activerecord.attributes.album`

---

### For Attribute Values (Enums, Status, etc.)

**Rails enum translation pattern:**

`config/locales/models/article.en.yml`:

```yaml
en:
  activerecord:
    attributes:
      article/status:          # model/enum_name (slash notation in YAML)
        draft: "Draft"
        published: "Published"
        hidden: "Hidden"
```

**Access in views:**

```erb
<%# Use human_attribute_name with enum.value %>
<%= Article.human_attribute_name("status.#{article.status}") %>
# OR with full path
<%= Article.human_attribute_name("article/status.#{article.status}") %>
```

---

### For View-Specific Text (Headers, Descriptions, Instructions)

```erb
<%# Use lazy lookup - automatically scoped to view path %>
<%= t('.title') %>        # Looks up: manage.albums.index.title
<%= t('.description') %>  # Looks up: manage.albums.index.description
```

**Where:** `config/locales/views/manage/albums.yml`

**Structure:**

```yaml
en:
  manage:
    albums:
      index:
        title: "Your Albums"
        description: "Manage your releases"
```

**Critical:** The dot prefix (`.title`) makes it view-scoped. Without the dot, it's global.

---

### For Reusable UI Elements (Buttons, Card Titles, Common Text)

```erb
<%# Global translations %>
<%= t('buttons.add') %>  # "Add"
<%= t('card_titles.new', subject: Album.model_name.human) %> # "New Release"
```

**Where:** `config/locales/en.yml` under top-level keys

**Common examples:**

- `buttons.save`, `buttons.cancel`, `buttons.delete` - Button labels
- `actions.edit`, `actions.delete` - Action labels
- `file_types.image`, `file_types.video` - File type labels
- `messages.success`, `messages.error` - Generic messages

---

## Directory Organization

| Content Type           | File Location                   | Example                         |
| ---------------------- | ------------------------------- | ------------------------------- |
| Model names/attributes | `models/{model}.en.yml`         | `models/album.en.yml`           |
| Attribute values       | `models/{model}.en.yml`         | Under `attributes.model/attr` (slash) |
| View-specific text     | `views/{controller}/{view}.yml` | `views/manage/albums.yml`       |
| Global buttons/UI      | `en.yml`                        | Top-level file                  |
| Command messages       | `commands/{command}.en.yml`     | `commands/publish_album.en.yml` |
| Helper text            | `helpers.en.yml`                | Top-level file                  |

**Nested models:**

```yaml
# models/album_variant.en.yml
en:
  activerecord:
    models:
      album_variant:
        one: Variant
        other: Variants
    attributes:
      album_variant:
        price: "Price"
```

---

## View-Scoped Lazy Lookup

In view `app/views/manage/albums/show.html.erb`:

```erb
<%= t('.title') %>  # Looks up: manage.albums.show.title
<%= t('.description') %> # Looks up: manage.albums.show.description
```

File: `config/locales/views/manage/albums.yml`:

```yaml
en:
  manage:
    albums:
      show:
        title: "Album Details"
        description: "View and edit album information"
```

---

## Pluralization

```erb
<%# Model names %>
<%= Album.model_name.human(count: @albums.count) %>

<%# Custom translations %>
<%= t('albums.show.includes_bonus_items', count: @items.count) %>
```

Translation file:

```yaml
en:
  albums:
    show:
      includes_bonus_items:
        one: "Includes %{count} Bonus Item"
        other: "Includes %{count} Bonus Items"
```

---

## Interpolation

```erb
<%= t('card_titles.edit', subject: @album.model_name.human) %>
<%= t('descriptors.recommended', resource: Album.model_name.human(count: 2)) %>
```

Translation:

```yaml
card_titles:
  edit: "Edit %{subject}"
descriptors:
  recommended: "Recommended %{resource}"
```

---

## Common Mistakes

### ❌ Hardcoding Text

```erb
<h6>Albums</h6>  # WRONG
<label>Title</label>  # WRONG
```

### ✅ Use i18n

```erb
<h6><%= Album.model_name.human(count: 2) %></h6>
<label><%= Album.human_attribute_name(:title) %></label>
```

### ❌ Wrong Translation Method

```erb
<%= t('album') %>  # WRONG - use model_name.human
<%= t('title') %>  # WRONG - use human_attribute_name
```

### ❌ Attribute VALUES in Wrong Location

```yaml
# ❌ WRONG - Values in models section
en:
  activerecord:
    models:
      status:
        draft: "Draft"

# ✅ CORRECT - Rails standard enum i18n pattern
en:
  activerecord:
    attributes:
      article/status:       # Slash notation (singular, not plural)
        draft: "Draft"
        published: "Published"
```

**Access:** `Article.human_attribute_name("status.#{value}")`

### ❌ Missing Lazy Lookup Dot

```erb
<%= t('title') %>  # Looks for global 'title'
<%= t('.title') %> # ✅ Looks for view-scoped 'manage.albums.index.title'
```

---

## Discovery

**Find translation usage:**

```bash
# Model name usage
Grep "\.model_name\.human" app/views/**/*.erb

# Attribute name usage
Grep "\.human_attribute_name" app/views/**/*.erb

# View-scoped translations
Grep "t\(\'\." app/views/**/*.erb

# Global translations
Grep "t\(['\"]\\w" app/views/**/*.erb
```

**Find translation files:**

```bash
# All locale files
Glob "config/locales/**/*.yml"

# Model translations
Glob "config/locales/models/*.yml"

# View translations
Glob "config/locales/views/**/*.yml"
```

---

## Quick Reference

| Need                | Method                              | File Location                        |
| ------------------- | ----------------------------------- | ------------------------------------ |
| Model name          | `Model.model_name.human`            | `models/{model}.en.yml`              |
| Attribute name      | `Model.human_attribute_name(:attr)` | `models/{model}.en.yml`              |
| Attribute value     | `Model.human_attribute_name("attr.val")` | `models/{model}.en.yml` (model/attr) |
| View text           | `t('.key')`                         | `views/{controller}.yml`             |
| Button label        | `t('buttons.key')`                  | `en.yml`                             |
| Enum value (status) | `t("descriptors.#{val}.label")`     | `en.yml` under `descriptors`         |
