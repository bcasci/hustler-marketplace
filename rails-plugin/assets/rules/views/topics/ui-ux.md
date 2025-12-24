---
paths: app/views/**/*.erb
dependencies: []
---

# UI/UX Patterns

Universal UI/UX decision framework. Framework-agnostic guidance for when to use each pattern.

---

## Pattern Selection

### Index/List Pattern

**When to use:**

- Displaying collections (multiple items)
- User needs to browse/scan options
- List can be empty (needs empty state)

**Key elements:**

- Header with collection title
- Action button (usually "Add" or "New")
- Collection rendering
- Empty state for zero items

**Examples:** Product lists, user directories, search results

---

### Show/Detail Pattern

**When to use:**

- Displaying single item details
- User navigated from a list or direct link
- Content can be organized into sections

**Key elements:**

- Main content area with item details
- Optional sidebar for metadata/related content
- Action buttons (Edit, Delete)
- Lazy-loaded related sections

**Examples:** Product details, user profiles, order details

---

### Form Pattern

**When to use:**

- Creating new items
- Editing existing items
- User input required

**Key elements:**

- Minimal markup (let form framework handle structure)
- All labels/hints from i18n
- Validation feedback
- Submit action

**Critical:** Use form framework defaults, don't add custom wrapper markup

---

### Modal/Dialog Pattern

**When to use:**

- Quick actions without navigation
- Creating items inline (stay on current page)
- Confirmations or lightweight forms

**Key elements:**

- Trigger button/link
- Overlay dialog
- Close mechanism
- Form or content inside

**When NOT to use:** Complex multi-step flows (use dedicated pages)

---

## Content Loading

### Eager Loading

**When to use:**

- Content above the fold
- Critical for initial page render
- Small amount of data

**Examples:** Page header, main content area

---

### Lazy Loading

**When to use:**

- Content below the fold
- Secondary/related information
- Expensive queries
- User might not need it

**Key elements:**

- Placeholder with loading indicator
- Async load when frame appears
- Fallback for load failures

**Examples:** Related products, comment sections, analytics

---

## Empty States

**When to use:**

- Collections can be empty (especially on first use)
- Search returns no results
- Filters exclude all items

**Key elements:**

- Descriptive icon
- Clear message about why empty
- Action to resolve (if applicable)

**Examples:** "No products yet - Add your first product", "No results found - Try different filters"

---

## Navigation Headers

### Collection Header

**Pattern:** Title + spacer + primary action

**When to use:**

- Top of index/list views
- Collection name as title
- Primary action is "Add" or "New"

---

### Detail Header

**Pattern:** Content + actions

**When to use:**

- Top of show/detail views
- Edit and Delete are common actions
- Actions relate to the item being shown

---

## Decision Framework

**Start here:**

1. **Multiple items?** → Index pattern
2. **Single item details?** → Show pattern
3. **User input needed?** → Form pattern
4. **Quick action inline?** → Modal pattern
5. **Can be empty?** → Add empty state
6. **Heavy/secondary content?** → Lazy load it

---

## Usage Rules

**MANDATORY:**

1. **Find similar view first** - Search existing views before creating
2. **Copy structure from examples** - Don't build from scratch
3. **Adapt names/content only** - Keep the structural pattern
4. **Use framework scaffolds** - Start from copyable examples in `views/examples/`

**Common searches:**

```bash
# Find index pages
grep -r "index" app/views/*/index.html.erb

# Find show pages
grep -r "show" app/views/*/show.html.erb

# Find forms
grep -r "form" app/views/**/_form.html.erb

# Find modals/dialogs
grep -r "dialog\|modal" app/views/**/*.erb
```
