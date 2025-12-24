---
paths: app/views/**/*.erb
dependencies: [turbo-rails]
examples: [turbo]
---

# Turbo Patterns

Turbo Frames for lazy loading, Turbo Streams for partial page updates.

---

## Turbo Stream Core Principle

**Turbo Streams render existing partials/templates - NEVER duplicate view markup.**

```erb
<%# GOOD - Render existing partial %>
<%= turbo_stream.replace "pin_button_form" do %>
  <%= render partial: "shared/pin_icon", locals: { product_pin: @product_pin } %>
<% end %>

<%# GOOD - Render full template %>
<%= turbo_stream.replace dom_id(current_cart) do %>
  <%= render template: 'carts/show' %>
<% end %>

<%# GOOD - Update with partial %>
<%= turbo_stream.update 'shopping_cart_button' do %>
  <%= render partial: 'layouts/navigation/shopping_cart_icon', locals: { items_count: current_cart_items_count } %>
<% end %>

<%# ACCEPTABLE - Minimal inline markup (empty div, script tag) %>
<%= turbo_stream.replace 'recommend_button_container' do %>
  <div id="recommend_button_container"></div>
<% end %>

<%# BAD - Duplicating partial markup inline %>
<%= turbo_stream.replace "user_avatar" do %>
  <i class="small circle">  <%# DON'T - this markup exists in shared/avatar partial %>
    <%= image_tag @user.avatar.variant(:thumb) %>
  </i>
<% end %>
```

**Pattern:** Turbo Streams specify WHERE to update and WHICH partial to render. Markup lives in partials.

---

## Turbo Frame Lazy Loading

### Separate Resource Pattern (Preferred)

**When to use separate resource:**

- Resource has its own CRUD operations (Tracks, Variants, Genres)
- Resource can be managed independently
- Multiple related resources on same parent (Album has Tracks, Variants, Genres)
- Resource has significant complexity

**Pattern:** Frame with `src` triggers async load, target responds with matching frame ID.

**Complete scaffold:** See `views/examples/turbo/turbo-frame-lazy.html.erb`

**Pattern snippet:**

```erb
<%# Trigger (parent view) %>
<%= turbo_frame_tag dom_id(@album, 'tracks'),
                    src: manage_album_tracks_path(@album) do %>
  <div class="fill medium-height middle-align center-align"></div>
<% end %>

<%# Target (separate controller action) %>
<%= turbo_frame_tag dom_id(@album, 'tracks') do %>
  <article class="no-elevate card">
    <%# content %>
  </article>
<% end %>
```

**Routes setup:**

```ruby
resources :albums do
  resources :tracks, controller: 'manage/tracks'
  resources :variants, controller: 'manage/album_variants'
  resources :genres, controller: 'manage/genres'
end
```

**Benefits:**

- Each resource controller handles its own logic
- Independent testing
- Clear separation of concerns
- Can navigate directly to resource URL

---

### Loading Strategies

**Immediate (default):**

```erb
<%= turbo_frame_tag 'content', src: path do %>
  <div class="fill medium-height middle-align center-align"></div>
<% end %>
```

Loads on page render.

**Lazy (viewport):**

```erb
<%= turbo_frame_tag 'content', src: path, loading: :lazy do %>
  <div class="fill medium-height middle-align center-align"></div>
<% end %>
```

Loads when scrolled into viewport. Use for below-the-fold content.

**Eager (async):**

```erb
<%= turbo_frame_tag 'content', src: path, loading: :eager do %>
  <div class="fill medium-height middle-align center-align"></div>
<% end %>
```

Loads immediately but asynchronously. Use for important above-the-fold content.

---

### Frame ID Patterns

**Simple string:**

```erb
turbo_frame_tag 'album_tracks', src: path
```

Use when only one frame of this type per page.

**Scoped with dom_id:**

```erb
turbo_frame_tag dom_id(@album, 'tracks'), src: path
turbo_frame_tag dom_id(@album, Genre.model_name.plural), src: path
```

Use when multiple parents might have same child type.

**Benefits of dom_id:**

- Prevents ID collisions
- Automatically generates unique IDs
- Consistent naming: `album_123_tracks`

---

### Loading Placeholders

**Standard heights:**

```erb
<div class="fill small-height middle-align center-align"></div>    # ~100px
<div class="fill medium-height middle-align center-align"></div>   # ~200px
<div class="fill large-height middle-align center-align"></div>    # ~400px
```

**Custom with content:**

```erb
<div class="padding center-align grey-text">
  <i>hourglass_empty</i>
  <p>Loading...</p>
</div>
```

---

## Turbo Streams

### Multi-Action Pattern

**Standard pattern:** One `.turbo_stream.erb` file with multiple streams for coordinated updates.

**Complete scaffold:** See `views/examples/turbo/turbo-stream-multi.html.erb`

**Pattern:** Coordinate multiple DOM updates in a single response.

**Common sequence:**
1. Add/update item in list (prepend/append)
2. Update counts or related elements
3. Remove empty states
4. Close dialogs or show messages

---

### Common Action Combinations

**Create:**

- `prepend` or `append` - Add new item to list
- `replace` - Replace button/form with new state
- `remove` - Remove empty state
- `update` - Close dialog or show success message

**Destroy:**

- `append` - Add animation script
- `update` - Update count/button
- `remove` - Remove item (after animation)

**Update:**

- `replace` - Replace specific element
- `update` - Update container

---

### Turbo Stream Actions

**prepend** - Add to beginning of container:

```erb
<%= turbo_stream.prepend 'items_list' do %>
  <%= render @item %>
<% end %>
```

**append** - Add to end of container:

```erb
<%= turbo_stream.append 'items_list' do %>
  <%= render @item %>
<% end %>
```

**replace** - Replace entire element (including wrapper):

```erb
<%= turbo_stream.replace dom_id(@item) do %>
  <%= render @item %>
<% end %>
```

**update** - Replace element content (preserves wrapper):

```erb
<%= turbo_stream.update 'cart_count' do %>
  <%= @cart.items.count %>
<% end %>
```

**remove** - Delete element:

```erb
<%= turbo_stream.remove 'empty_state' %>
```

---

## When to Use Which

| Scenario                 | Use                               |
| ------------------------ | --------------------------------- |
| Load related resources   | Turbo Frame (separate resource)   |
| Add item to list         | Turbo Stream prepend/append       |
| Update item in list      | Turbo Stream replace              |
| Remove item from list    | Turbo Stream remove (or animated) |
| Update multiple elements | Turbo Stream (multi-action)       |
| Close dialog after save  | Turbo Stream update (with script) |
| Show/hide empty state    | Turbo Stream remove/append        |
| Update cart/counts       | Turbo Stream update               |

---

## Decision: Separate Resource vs Inline

**Separate resource when:**

- Resource has CRUD operations
- Can be managed independently
- Has its own index/show views
- Significant complexity (>50 lines)
- Multiple instances on different parent types

**Inline when:**

- Simple display-only content
- Tightly coupled to parent
- No independent management
- < 20 lines of markup

---

## Scaffolds

**Copy these complete patterns:**

- `views/examples/turbo/turbo-frame-lazy.html.erb` - Lazy loading frame pattern
- `views/examples/turbo/turbo-stream-multi.html.erb` - Multi-action stream pattern

**Adapt:** Change model names, paths, and content while preserving structure.

---

## Discovery

**Find lazy frames:**

```bash
Grep "turbo_frame_tag.*src:" app/views/**/*.erb
```

**Find turbo stream templates:**

```bash
Glob "app/views/**/*.turbo_stream.erb"
```

**Find multi-action streams:**

```bash
Grep -C 3 "turbo_stream\." app/views/**/*.turbo_stream.erb
```
