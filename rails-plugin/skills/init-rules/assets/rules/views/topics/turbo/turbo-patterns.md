---
paths: "app/views/**/*.erb"
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
<%= turbo_stream.replace "action_button" do %>
  <%= render partial: "shared/button", locals: { resource: @resource } %>
<% end %>

<%# GOOD - Render full template %>
<%= turbo_stream.replace dom_id(@resource) do %>
  <%= render template: 'resources/show' %>
<% end %>

<%# GOOD - Update with partial %>
<%= turbo_stream.update 'header_counter' do %>
  <%= render partial: 'layouts/navigation/counter', locals: { count: @count } %>
<% end %>

<%# ACCEPTABLE - Minimal inline markup (empty div, script tag) %>
<%= turbo_stream.replace 'container' do %>
  <div id="container"></div>
<% end %>

<%# BAD - Duplicating partial markup inline %>
<%= turbo_stream.replace "avatar" do %>
  <i>  <%# DON'T - this markup exists in shared/avatar partial %>
    <%= image_tag @user.avatar %>
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
<%= turbo_frame_tag dom_id(@resource, 'items'),
                    src: namespace_resource_items_path(@resource) do %>
  <p>Loading...</p>
<% end %>

<%# Target (separate controller action) %>
<%= turbo_frame_tag dom_id(@resource, 'items') do %>
  <article>
    <%# content %>
  </article>
<% end %>
```

**Routes setup:**

```ruby
resources :resources do
  resources :items, controller: 'namespace/items'
  resources :variants, controller: 'namespace/resource_variants'
  resources :categories, controller: 'namespace/categories'
end
```

---

### Loading Strategies

**Immediate (default):**

```erb
<%= turbo_frame_tag 'content', src: path do %>
  <p>Loading...</p>
<% end %>
```

Loads on page render.

**Lazy (viewport):**

```erb
<%= turbo_frame_tag 'content', src: path, loading: :lazy do %>
  <p>Loading...</p>
<% end %>
```

Loads when scrolled into viewport. Use for below-the-fold content.

**Eager (async):**

```erb
<%= turbo_frame_tag 'content', src: path, loading: :eager do %>
  <p>Loading...</p>
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
turbo_frame_tag dom_id(@resource, 'items'), src: path
turbo_frame_tag dom_id(@resource, Category.model_name.plural), src: path
```

Use when multiple parents might have same child type. `dom_id` generates unique IDs like `resource_123_items`.

---

## List Partial + Turbo Frame Coordination

**Pattern:** Index page defines static wrapper ONCE, list partial contains ONLY dynamic content. Turbo Streams replace only the nested frame.

**Why:** Zero duplication of wrapper markup, smaller Turbo Stream payloads, single source of truth.

**Structure:**

1. Index page: Static wrapper (nav, header, buttons) + turbo_frame
2. List partial: ONLY list content (users.any? → render items, else empty state)
3. Turbo Stream: Replace ONLY the nested frame

**Example:**

```erb
<%# index.html.erb - Static wrapper stays in place %>
<nav>
  <h4>Users</h4>
  <button data-controller="dialog">Add User</button>
</nav>

<article>
  <%= turbo_frame_tag "users_list" do %>
    <%= render "user_list", users: @users, empty_state: @empty_state %>
  <% end %>
</article>
```

```erb
<%# _user_list.html.erb - ONLY list content, NO wrapper %>
<% if users.any? %>
  <ul>
    <%= render users %>  <%# Renders _user.html.erb for each %>
  </ul>
<% else %>
  <%= render_empty_state(empty_state) %>
<% end %>
```

```erb
<%# create.turbo_stream.erb - Replace ONLY the list %>
<%= turbo_stream.replace "users_list" do %>
  <%= turbo_frame_tag "users_list" do %>
    <%= render partial: "user_list", locals: { users: @users, empty_state: @empty_state } %>
  <% end %>
<% end %>
```

---

### Loading Placeholders

Turbo frames display fallback content while loading from `src:`.

**Prevent layout shift:** Match placeholder height to expected content so the page doesn't jump when frame loads.

```erb
<%= turbo_frame_tag 'content', src: path, loading: :lazy do %>
  <%# Fallback content - shows until frame loads %>
  <%# Use loading state markup from project conventions %>
<% end %>
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

## Turbo Confirmations

**Use `turbo_confirm` for pre-action dialogs** (BEFORE destructive action).

**Pattern:**

```erb
<%= button_to resource_path(@resource),
              method: :delete,
              data: { turbo_confirm: t('.delete_confirm') } do %>
  <%= t('actions.delete') %>
<% end %>

<%# Or with link_to %>
<%= link_to t('actions.delete'),
            resource_path(@resource),
            data: { turbo_method: :delete, turbo_confirm: t('.delete_confirm') } %>
```

**i18n structure (view-scoped):**

Location: `config/locales/views/{controller}.en.yml`

```yaml
en:
  resources:
    show:
      delete_confirm: "Delete this resource? This cannot be undone."
```

**When to use:**

- BEFORE destructive actions (delete, archive)
- User confirmation needed before proceeding
- Turbo-native dialogs (not JavaScript confirm())

**Don't use for:**

- Post-action notifications (use flash messages)
- Form validation errors (render with errors)
- Multi-step workflows (use Turbo Frames/dialogs)

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

**Find turbo confirmations:**

```bash
Grep "turbo_confirm" app/views/**/*.erb
```
