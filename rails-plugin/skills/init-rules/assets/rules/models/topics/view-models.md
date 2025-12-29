---
paths: "app/models/view_models/**/*.rb, app/views/**/*.erb"
dependencies: []
---

# ViewModels (Presenters)

---

## When to Use ViewModels

Consider ViewModels when presentation logic involves:

- Multiple association traversals with formatting
- Same display logic repeated across 3+ views
- Complex conditionals with multiple fallbacks
- State-dependent display with business rules

**Start simple:**

1. Try controller instance variable first
2. Try helper method if reused
3. Refactor to ViewModel when complexity grows

**When NOT to use:**

- Simple traversals → Controller assignment: `@owner = @product.store.user`
- Single-use formatting → Helper method
- Core model properties → Model delegation
- Domain logic → Models or commands

---

## ViewModel Structure

```ruby
module ViewModels
  class DigitalMedia
    include ActiveModel::Model
    include ActiveModel::Attributes

    attribute :digital_media

    # Delegate stable properties
    delegate :id, :name, to: :digital_media

    # Computed presentation properties
    def file_info
      return unless variant&.file&.attached?
      "#{media_type} - #{formatted_file_size}"
    end

    private

    def helpers
      ApplicationController.helpers
    end
  end
end
```

---

## Key Principles

### No Defensive Defaults

Let nils be nils - don't add "Unknown" or "N/A" defaults:

```ruby
# BAD
def file_size
  variant&.file&.blob&.byte_size || "Unknown"
end

# GOOD - Let view decide how to handle nil
def file_size
  variant.file.blob.byte_size if variant&.file&.attached?
end
```

### Smart Safe Navigation

Use `&.` only for truly optional relationships:

```ruby
# Required relationship - fail if broken
def store_name
  store.name  # Error if missing = catches bugs
end

# Optional relationship - safe navigation appropriate
def album_name
  album&.name  # Track might not have album
end
```

### Single Responsibility

Each ViewModel has one job:

- `ViewModels::Player` - Player state and controls
- `ViewModels::DigitalMedia` - Digital media presentation
- `ViewModels::EmptyState` - Empty state configuration

---

## Usage Pattern

**CRITICAL:** ViewModels instantiated in controllers, NOT views.

```ruby
# CONTROLLER - Create ViewModels here
class DigitalMediaController < ApplicationController
  def show
    @digital_media_model = DigitalMedia.find(params[:id])
    @digital_media = ViewModels::DigitalMedia.new(
      digital_media: @digital_media_model
    )
  end
end
```

```erb
<%# VIEW - Use ViewModel from controller %>
<h1><%= @digital_media.name %></h1>
<p><%= @digital_media.file_info %></p>
```

**Collections:** Prepare in controller:

```ruby
@items = @store.digital_media.map do |dm|
  ViewModels::DigitalMedia.new(digital_media: dm)
end
```

---

## Discovery

**Existing ViewModels:** `Glob "app/models/view_models/**/*.rb"`

**Usage examples:** `Grep "ViewModels::" app/controllers/**/*.rb"`
