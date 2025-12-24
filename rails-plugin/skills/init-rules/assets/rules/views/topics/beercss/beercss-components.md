---
paths: app/views/**/*.erb
dependencies: [beercss]
examples: [beercss]
---

# BeerCSS Components

Component patterns using BeerCSS framework.

## Buttons & Actions

### Button Classes

```erb
<%# Primary action %>
class="button small-round"

<%# Secondary/Border button %>
class="button border small-round"

<%# Destructive action %>
class="button red-text border small-round"

<%# Circle button (icon only) %>
class="button circle"

<%# Transparent/Ghost button %>
class="button circle transparent"

<%# Primary colored button %>
class="button primary small-round"
```

### Button Patterns

**Edit and Delete actions (together):**

```erb
<nav>
  <%= link_to 'Edit', edit_path, class: 'button small-round' %>
  <%= button_to 'Delete', path,
                method: :delete,
                data: { turbo_confirm: "Are you sure?" },
                class: 'button red-text border left-margin small-round' %>
</nav>
```

**Single edit button in header:**

```erb
<nav>
  <h6>Title</h6>
  <div class="max"></div>
  <%= link_to edit_path, class: 'button small-round' do %>
    <i>edit</i>
    <span>Edit</span>
  <% end %>
</nav>
```

**Action button with icon:**

```erb
<button class="button primary small-round">
  <i>add</i>
  <span>Add Product</span>
</button>
```

**Floating action button:**

```erb
<%= link_to path, class: 'small-margin fixed bottom right circle secondary' do %>
  <i>link</i>
  <div class="tooltip left">Public page</div>
<% end %>
```

---

## User Avatars

How to display user profile pictures in BeerCSS.

### Pattern

BeerCSS uses `<i>` elements as wrappers for circular images. Classes go on the `<i>` tag, NOT on the `<img>` tag:

```erb
<%# CORRECT - classes on <i> wrapper %>
<i class="small circle">
  <img src="<%= user.avatar_url %>">
</i>

<%# WRONG - classes on <img> %>
<img src="<%= user.avatar_url %>" class="small circle">
```

### Available Sizes

```erb
<i class="tiny circle"><img src="..."></i>    # Smallest
<i class="small circle"><img src="..."></i>   # Small (most common)
<i class="medium circle"><img src="..."></i>  # Medium
<i class="large circle"><img src="..."></i>   # Large
<i class="extra circle"><img src="..."></i>   # Extra large
```

### When to Use

- User profile displays in headers
- Comment/post author indicators
- User lists and directories
- Activity feeds
- Chat interfaces

### With Fallback

Handle missing avatars with fallback image:

```erb
<i class="small circle">
  <% if user.avatar.attached? %>
    <img src="<%= url_for(user.avatar.variant(:thumb)) %>">
  <% else %>
    <img src="/favicon.png">
  <% end %>
</i>
```

### Reusable Partial

Use existing avatar partial when available:

```erb
<%= render 'shared/avatar', user: user, size: 'small' %>
```

Check `app/views/shared/_avatar.html.erb` for project-specific avatar helper.

---

## Dialogs & Modals

### Dialog Structure

This project uses BeerCSS dialogs with Stimulus controllers, NOT lazy-loaded dialogs.

**Pattern: Dialog with controller wrapper**

```erb
<%# index.html.erb - Dialog trigger and content %>
<section data-controller="dialog">
  <nav>
    <h6>Products</h6>
    <div class="max"></div>
    <button data-action="dialog#toggle" class="primary small-round">
      <i>add</i>
      <span>Add</span>
    </button>
  </nav>

  <div id="content_container">
    <%= render 'list' %>
  </div>

  <%= render 'modal' %>
</section>
```

**Dialog partial:**

```erb
<%# _modal.html.erb %>
<dialog data-dialog-target="dialog" class="modal large right">
  <header class="fixed front">
    <nav>
      <h5 class="max">Dialog Title</h5>
      <button class="circle transparent" data-action="dialog#toggle">
        <i>close</i>
      </button>
    </nav>
  </header>

  <article>
    <%= render 'form' %>
  </article>
</dialog>
```

### Dialog Sizes and Positions

```erb
class="modal large"           # Large dialog
class="modal large right"     # Large dialog, slides from right
class="modal max"             # Full-width dialog
```

### Closing Dialogs

**Close button in header:**

```erb
<button class="circle transparent" data-action="dialog#toggle">
  <i>close</i>
</button>
```

**Dialog closes automatically on successful form submission** (via Stimulus controller `handleFormSubmitEnd`).

**Prevent auto-close on form submission:**

```erb
<%= simple_form_for @search,
      html: { 'data-no-close-on-success' => true } do |f| %>
  ...
<% end %>
```

### Dialog in Application Layout

Global dialog container in `layouts/application.html.erb`:

```erb
<dialog id="dialog" class="max" data-controller="dialog-closer" data-turbo-action="replace">
  <header class="fixed">
    <nav>
      <button class="button circle" data-action="click->dialog-closer#close">
        <i>close</i>
      </button>
    </nav>
  </header>
</dialog>
```

---

## Status Chips

### Chip Helper

Use `render_chip_for` helper to display status chips:

```erb
<%= render_chip_for(@variant, :listing_status, size: 'small') %>
```

### Chip Partial

Direct chip rendering with `shared/chip/chip` partial:

```erb
<%= render partial: 'shared/chip/chip', locals: {
  dom_id: dom_id(@object, 'status_chip'),
  text: 'Published',
  badge_color: 'green',
  css_classes: 'no-margin',
  tooltip: 'This product is live'
} %>
```

**Partial structure:**

```erb
<%# shared/chip/_chip.html.erb %>
<span id="<%= dom_id %>" class="chip no-border transparent <%= css_classes %>">
  <span><%= text %></span>
  <% if badge_color %>
    <span class="badge none <%= badge_color %>"></span>
  <% end %>
  <% if tooltip.present? %>
    <span class="tooltip no-space bottom left"><%= tooltip %></span>
  <% end %>
</span>
```

### Status Chip Colors

```erb
badge_color: 'green'     # Success/active
badge_color: 'red'       # Error/inactive
badge_color: 'orange'    # Warning
badge_color: 'blue'      # Info
```

---

## Empty States

### Empty State Helper

Use `render` with `shared/empty_state/base` partial:

```erb
<%= render partial: 'shared/empty_state/base',
           locals: { empty_state: @empty_state } %>
```

### Building Empty States

**In controller:**

```ruby
@empty_state = EmptyState.new(
  icon: 'label_off',
  title: 'No items yet',
  description: 'Add your first item to get started',
  action_label: 'Add Item',
  action_url: new_item_path,
  action_class: 'button small-round',
  action_data: { turbo_frame: '_top' }
)
```

### Empty State Partial

```erb
<%# shared/empty_state/_base.html.erb %>
<article class="<%= empty_state.container_class %>">
  <div>
    <% if empty_state.icon.present? %>
      <i class="extra"><%= empty_state.icon %></i>
    <% end %>

    <%= content_tag(empty_state.title_tag, empty_state.title,
                    class: empty_state.title_class) %>

    <% if empty_state.description.present? %>
      <p><%= empty_state.description %></p>
    <% end %>

    <% if empty_state.action_label.present? %>
      <div class="space"></div>
      <nav class="center-align">
        <%= link_to empty_state.action_label,
                   empty_state.action_url,
                   class: empty_state.action_class,
                   data: empty_state.action_data || {} %>
      </nav>
    <% end %>
  </div>
</article>
```

### Common Empty State Icons

```erb
icon: 'label_off'        # Tags/labels
icon: 'inbox'            # General empty
icon: 'folder_off'       # Files/folders
icon: 'music_off'        # Music/tracks
icon: 'image_off'        # Images
icon: 'cloud_off'        # Upload/cloud
```

---

## Best Practices

### Do's

✅ Use Stimulus controllers for interactive dialogs
✅ Use helpers for chips and empty states
✅ Use Turbo streams for dynamic updates

### Don'ts

❌ Don't lazy-load dialogs (use inline dialogs with Stimulus)
❌ Don't create custom chip HTML (use helper/partial)
❌ Don't forget to handle both first item and append cases in turbo streams

---

## Reference Implementations

Good examples to study:

- **Dialogs**: `app/views/manage/product_inclusions/`
- **Empty States**: `app/views/shared/empty_state/_base.html.erb`
- **Status Chips**: `app/helpers/manage/product_variants_helper.rb`
