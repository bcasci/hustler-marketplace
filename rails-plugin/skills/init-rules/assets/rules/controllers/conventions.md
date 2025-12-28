---
paths: app/controllers/**/*.rb
dependencies: []
---

# Controller Patterns

Controllers: authenticate → authorize → operate → respond.

**Note:** For authorization implementation patterns, see authorization rules that load with this file.

---

## Controller Responsibility Matrix

Controllers do EXACTLY 4 things. Everything else goes elsewhere.

### The 4 Controller Jobs

1. **Receive**: Extract data from HTTP request
   - `params.expect(album: [:title, :description])`
   - `params[:id]`, `request.headers`

2. **Authorize**: Check permissions
   - `authorize @resource`
   - `policy_scope(Model)`

3. **Delegate**: Call the object that does the work
   - `@command.run`
   - `@query.call`
   - `@query.to_csv` (delegation to data source)
   - Build instance variables by calling other objects

4. **Respond**: Return HTTP response
   - `redirect_to`, `render`
   - `send_data`, `response.headers[...]`
   - `flash[:notice]`

### Decision Matrix

For ANY method being added to controller:

**Is this method doing one of the 4 controller jobs?**

- **YES** → OK for controller
- **NO** → Extract it
  - Transforming data format? → Add to data source (Query/ViewModel)
  - Enforcing business rules? → Command
  - Retrieving from database? → Query object
  - Calculating values? → Model method or Value Object

### CSV Export Anti-Pattern

❌ **Wrong - transformation in controller:**

```ruby
format.csv do
  csv = CSV.generate do |csv|  # NOT one of the 4 jobs
    csv << headers
    @data.each { |row| csv << format_row(row) }
  end
  send_data csv  # This IS job #4 (Respond)
end

private

def format_row(row)  # NOT one of the 4 jobs
  # transformation logic
end
```

✅ **Right - delegation only:**

```ruby
format.csv do
  csv = @query.to_csv  # Job #3 (Delegate to data source)
  send_data csv        # Job #4 (Respond with HTTP)
end
```

**Add `to_csv` to the object that HAS the data:**
- Data from Query? → Add `to_csv` to Query
- Data from ViewModel? → Add `to_csv` to ViewModel

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
    params.expect(album: [:title, :description, :release_date])
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

## Context Helpers

Available in all controllers:

- `current_user`
- `current_organization`
- `context`

See ApplicationController.
