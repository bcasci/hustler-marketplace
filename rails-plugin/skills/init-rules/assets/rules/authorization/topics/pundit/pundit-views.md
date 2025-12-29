---
paths: "app/views/**/*.erb, app/views/**/*.rb"
dependencies: [pundit]
---

# Pundit - View Helpers

---

## Basic View Helper

Use `policy(@resource).action?` to check permissions in views:

```erb
<% if policy(@album).edit? %>
  <%= link_to "Edit", edit_album_path(@album), class: "button" %>
<% end %>

<% if policy(@album).destroy? %>
  <%= button_to "Delete", album_path(@album), method: :delete,
                class: "button danger" %>
<% end %>
```

---

## Multiple Permission Checks

```erb
<% if policy(@album).update? %>
  <div class="admin-actions">
    <%= link_to "Edit", edit_album_path(@album) %>

    <% if policy(@album).publish? %>
      <%= button_to "Publish", publish_album_path(@album), method: :post %>
    <% end %>

    <% if policy(@album).archive? %>
      <%= button_to "Archive", archive_album_path(@album), method: :post %>
    <% end %>
  </div>
<% end %>
```

---

## Custom UI Methods

Define custom predicates for UI-specific authorization:

**In policy:**
```ruby
class AlbumPolicy < ApplicationPolicy
  def show?
    true  # Everyone can view
  end

  def manage?
    user_is_owner?  # Custom for showing management UI
  end

  def show_stats?
    user_is_owner? || user.admin?
  end
end
```

**In view:**
```erb
<% if policy(@album).manage? %>
  <%= render "albums/management_panel", album: @album %>
<% end %>

<% if policy(@album).show_stats? %>
  <%= render "albums/statistics", album: @album %>
<% end %>
```

---

## Collection Authorization

Check if user can create new resources:

```erb
<% if policy(Album).new? %>
  <%= link_to "New Album", new_album_path, class: "button primary" %>
<% end %>
```

**Note:** Pass the class, not an instance, for `new?` and `create?`

---

## Conditional Sections

```erb
<div class="album-header">
  <h1><%= @album.title %></h1>

  <% if policy(@album).manage? %>
    <div class="album-actions">
      <%= link_to "Edit", edit_album_path(@album) %>
      <%= link_to "Manage Tracks", album_tracks_path(@album) %>
      <%= link_to "View Analytics", album_analytics_path(@album) %>
    </div>
  <% end %>
</div>
```

---

## Form Field Authorization

```erb
<%= form_with model: @album do |f| %>
  <%= f.text_field :title %>
  <%= f.text_area :description %>

  <% if policy(@album).update_pricing? %>
    <div class="pricing-fields">
      <%= f.number_field :price_cents %>
      <%= f.select :currency, currencies_for_select %>
    </div>
  <% end %>

  <%= f.submit %>
<% end %>
```

---

## Loops with Authorization

```erb
<% @albums.each do |album| %>
  <div class="album-card">
    <h3><%= link_to album.title, album_path(album) %></h3>

    <div class="actions">
      <%= link_to "View", album_path(album) %>

      <% if policy(album).edit? %>
        <%= link_to "Edit", edit_album_path(album) %>
      <% end %>

      <% if policy(album).destroy? %>
        <%= button_to "Delete", album_path(album), method: :delete %>
      <% end %>
    </div>
  </div>
<% end %>
```

---

## Permitted Attributes Helper

For complex forms, use `permitted_attributes`:

```erb
<%= form_with model: @album do |f| %>
  <% policy(@album).permitted_attributes.each do |attr| %>
    <%= f.text_field attr %>
  <% end %>
<% end %>
```

**In policy:**
```ruby
def permitted_attributes
  if user.admin?
    [:title, :description, :price_cents, :featured, :published_at]
  else
    [:title, :description]
  end
end
```

---

## View Model Integration

```ruby
# app/models/view_models/album_card.rb
class ViewModels::AlbumCard
  def initialize(album:, policy:)
    @album = album
    @policy = policy
  end

  def show_edit_button?
    @policy.edit?
  end

  def show_stats?
    @policy.show_stats?
  end
end
```

```erb
<%# In view %>
<% card = ViewModels::AlbumCard.new(album: @album, policy: policy(@album)) %>
<% if card.show_edit_button? %>
  <%= link_to "Edit", edit_album_path(@album) %>
<% end %>
```

---

## View vs Controller Authorization

**View-level (`policy().action?`):**
- Conditional UI elements (buttons, links, sections)
- Optional features users might not see

**Controller-level (`authorize`):**
- Protecting actions (always required)
- Security boundaries

**Both together:**
```ruby
# Controller - security boundary
def edit
  @album = Album.find(params[:id])
  authorize @album  # MUST pass to access action
  # ...
end
```

```erb
<%# View - UI optimization %>
<% if policy(@album).edit? %>
  <%= link_to "Edit", edit_album_path(@album) %>
<% end %>
```

---

## Turbo Frame Authorization

```erb
<%= turbo_frame_tag "album_actions" do %>
  <% if policy(@album).manage? %>
    <%= render "albums/admin_panel", album: @album %>
  <% else %>
    <p>Limited view</p>
  <% end %>
<% end %>
```
