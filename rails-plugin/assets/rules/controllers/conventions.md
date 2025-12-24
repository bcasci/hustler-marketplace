---
paths: app/controllers/**/*.rb
dependencies: []
---

# Controller Patterns

Controllers: authenticate → authorize → operate → respond.

**Note:** For authorization implementation patterns, see authorization rules that load with this file.

---

## Core Pattern

```ruby
class AlbumsController < ApplicationController
  def create
    @album = current_organization.albums.build(album_params)
    # Authorization - see authorization rules

    if @album.save
      # Rails auto-renders:
      # - create.html.erb for HTML requests
      # - create.turbo_stream.erb for Turbo Stream requests
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def album_params
    params.require(:album).permit(:title, :description, :release_date)
  end
end
```

---

## Complex Operations

Use commands when operation involves multiple models, external services, or 3+ database operations:

```ruby
def publish
  # Authorization - see authorization rules
  command = Albums::Publish.new(context, album: @album)

  if command.run
    # Renders publish.html.erb or publish.turbo_stream.erb
  else
    @errors = command.errors
    render :show, status: :unprocessable_entity
  end
end
```

---

## Turbo Streams

Rails automatically renders format-specific templates:

- `create.html.erb` for HTML
- `create.turbo_stream.erb` for Turbo Stream

No `respond_to` needed in most cases.

### When respond_to IS Needed

Only when HTML and Turbo Stream need different behavior:

```ruby
if @product_pin.save
  respond_to do |format|
    format.turbo_stream  # Renders template
    format.html { redirect_to @product_pin.product, notice: 'Pinned!' }
  end
end
```

---

## Discovery

**Command usage:**

```
Grep "\.new(context" app/controllers/**/*.rb
```

**Turbo Stream templates:**

```
Glob "app/views/**/*.turbo_stream.erb"
```

---

## Context Helpers

Available in all controllers:

- `current_user`
- `current_organization`
- `context`

See ApplicationController.
