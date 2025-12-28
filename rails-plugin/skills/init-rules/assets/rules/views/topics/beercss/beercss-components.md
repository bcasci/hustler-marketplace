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

**Cancel button patterns:**

```erb
<%# Dialog cancel (close modal) %>
<button type="button" class="button border small-round"
        data-action="dialog#close">
  <%= t("cancel") %>
</button>

<%# Form cancel (return to resource) %>
<%= link_to t("cancel"), @resource, class: "button border small-round" %>
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

### Dialog Wrapper Partials

**Pattern:** Create reusable `_new.html.erb` and `_edit.html.erb` partials that wrap the shared `_form.html.erb` with dialog structure.

**When to use:**

- Dialog-based forms for new/edit actions
- Need consistent dialog structure across actions
- Shared form partial reused in different dialog contexts

**Location:** Same directory as controller views

---

**Structure:**

```erb
<%# _new.html.erb - Reusable dialog wrapper for create %>
<%= turbo_frame_tag "new_user_dialog_frame" do %>
  <header>
    <nav>
      <h6>New User</h6>
      <button data-controller="dialog" data-action="click->dialog#close">
        <i>close</i>
      </button>
    </nav>
  </header>
  <article>
    <%= render "form", user: user %>
  </article>
<% end %>
```

```erb
<%# _edit.html.erb - Reusable dialog wrapper for edit %>
<%= turbo_frame_tag dom_id(user, :edit_dialog) do %>
  <header>
    <nav>
      <h6>Edit User</h6>
      <button data-controller="dialog" data-action="click->dialog#close">
        <i>close</i>
      </button>
    </nav>
  </header>
  <article>
    <%= render "form", user: user %>
  </article>
<% end %>
```

**Benefits:**

- Consistent BeerCSS dialog structure
- Shared form partial reused (DRY)
- Turbo Frame targets are clear and distinct
- Easy to maintain dialog headers separately

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

### Status Chip i18n Pattern

Structure translations with color metadata for BeerCSS chips:

**Location:** `config/locales/en.yml`

```yaml
en:
  descriptors:
    listing_state:
      draft:
        label: "Draft"
        color: "grey"
      published:
        label: "Published"
        color: "green"
      hidden:
        label: "Hidden"
        color: "orange"
```

**Access in views:**

```erb
<%= t("descriptors.listing_state.#{record.listing_state}.label") %>
<%= t("descriptors.listing_state.#{record.listing_state}.color") %>
```

**With helper:**

```erb
<%= render_chip_for(@variant, :listing_status) %>
# Helper reads both label and color from descriptors
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

### Empty State i18n Pattern

Structure translations for EmptyState objects using model-scoped pattern:

**Location:** `config/locales/models/{model}.en.yml`

```yaml
en:
  activerecord:
    attributes:
      album/empty_state:
        icon: "sell"
        message: "Your store has no Albums."
        action_label: "Add an Album"
```

**Access in controller:**

```ruby
empty_state_key = "activerecord.attributes.#{model_name}/empty_state"

@empty_state = EmptyState.new(
  icon: t("#{empty_state_key}.icon"),
  title: t("#{empty_state_key}.message"),
  action_label: t("#{empty_state_key}.action_label"),
  action_url: new_album_path
)
```

**Pattern:** Use `{model}/empty_state` under `activerecord.attributes` so empty state text lives with model translations.

---

## Simple Form Integration

### Default Wrapper Auto-Applied

Projects typically configure `:beercss` as the default wrapper. Standard inputs use this automatically.

```erb
<%# GOOD - No wrapper needed, uses default :beercss %>
<%= f.input :name %>
<%= f.input :price, as: :decimal %>
<%= f.input :release_date, as: :date %>
<%= f.input :state, collection: States::US_STATES %>

<%# BAD - Redundant explicit wrapper %>
<%= f.input :name, wrapper: :beercss %>  <!-- Unnecessary! -->
```

**Check:** `config/initializers/simple_form_beercss.rb` for default wrapper configuration.

---

### Explicit Wrapper for Overrides

```erb
<%# GOOD - Explicit wrapper for non-default wrappers %>
<%= f.input :description, wrapper: :textarea %>
<%= f.input :active, wrapper: :switch %>
<%= f.input :role, wrapper: :beercss_without_label %>
```

---

### Collection Inputs Require Custom Classes

**CRITICAL:** BeerCSS radio/checkbox structure requires nested elements that Simple Form wrappers cannot create.

**Why Wrappers Don't Work:**

For collection inputs (`collection_radio_buttons`, `collection_check_boxes`), wrapper configuration options like `item_wrapper_tag`, `collection_wrapper_tag`, `wrap_with` **render as HTML ATTRIBUTES**, not DOM structure.

```ruby
# THIS DOES NOT WORK - renders as attributes, not structure
config.wrappers :my_wrapper do |b|
  b.use :input,
        item_wrapper_tag: 'label',           # Becomes HTML attribute
        collection_wrapper_tag: 'nav'        # Becomes HTML attribute
end

# Result: <input item_wrapper_tag="label" collection_wrapper_tag="nav" ...>
```

**BeerCSS Required Structure:**

```html
<label class="radio">
  <input type="radio" />
  <span>Label Text</span>
</label>
```

---

### Solution: Custom Input Classes

Create custom input classes for BeerCSS radio/checkbox patterns:

```ruby
# app/inputs/vertical_radio_buttons_input.rb
class VerticalRadioButtonsInput < SimpleForm::Inputs::CollectionRadioButtonsInput
  def input(wrapper_options = nil)
    label_method, value_method = detect_collection_methods

    template.content_tag(:nav, class: "vertical") do
      collection.map do |item|
        value = item.send(value_method)
        text = item.send(label_method)

        template.content_tag(:label, class: "radio") do
          template.radio_button_tag(
            "#{object_name}[#{attribute_name}]",
            value,
            selected?(value)
          ) + template.content_tag(:span, text)
        end
      end.join.html_safe
    end
  end

  private

  def selected?(value)
    current_value = @builder.object.send(attribute_name)
    current_value == value || current_value.to_s == value.to_s
  end

  def object_name
    @builder.object_name
  end
end
```

**Usage:**

```erb
<%= f.input :size,
            as: :vertical_radio_buttons,
            collection: sizes,
            wrapper: :vertical_radio_buttons %>
```

**Check:** `app/inputs/` directory for existing custom inputs before creating new ones.

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
