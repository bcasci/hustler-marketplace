---
paths: app/controllers/**/*.rb
dependencies: [pundit]
---

# Pundit - Controller Authorization

---

## Basic Authorization

Authorize every controller action that accesses or modifies resources:

```ruby
def show
  @album = Album.find(params[:id])
  authorize @album  # Raises Pundit::NotAuthorizedError if denied
end

def create
  @album = current_organization.albums.build(album_params)
  authorize @album

  if @album.save
    # ...
  end
end

def update
  @album = Album.find(params[:id])
  authorize @album

  if @album.update(album_params)
    # ...
  end
end
```

---

## Index Actions with Policy Scopes

Use `policy_scope` to filter collections based on user permissions:

```ruby
def index
  @albums = policy_scope(Album)  # Filters by permissions
  authorize Album                # Still authorize the action
end
```

**Pattern:**

1. `policy_scope(Model)` - Filters WHAT user can see
2. `authorize Model` - Checks IF user can access index

---

## Complete CRUD Example

```ruby
class AlbumsController < ApplicationController
  def index
    @albums = policy_scope(Album)
    authorize Album
  end

  def show
    @album = Album.find(params[:id])
    authorize @album
  end

  def new
    @album = current_organization.albums.build
    authorize @album
  end

  def create
    @album = current_organization.albums.build(album_params)
    authorize @album

    if @album.save
      redirect_to @album
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @album = Album.find(params[:id])
    authorize @album
  end

  def update
    @album = Album.find(params[:id])
    authorize @album

    if @album.update(album_params)
      redirect_to @album
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @album = Album.find(params[:id])
    authorize @album
    @album.destroy

    redirect_to albums_path
  end
end
```

---

## Authorization with Commands

Authorize BEFORE running commands:

```ruby
def update
  @album = current_organization.albums.find(params[:id])
  authorize @album  # ← Authorize FIRST

  command = Albums::Update.new(context, album: @album, params: album_params)
  if command.run
    redirect_to @album
  else
    render :edit, status: :unprocessable_entity
  end
end
```

---

## When to Skip Authorization

Only skip when there's NO resource ownership to check:

```ruby
def dashboard
  @dashboard = current_user.dashboard_data
  # Personal to current_user, authentication handles it
  skip_authorization
end

def health_check
  # Public endpoint, no authorization needed
  skip_authorization
  render json: { status: 'ok' }
end
```

### Skip Authorization Rules

**ALWAYS skip when:**

- Data is personal to `current_user` (no ownership check needed)
- Public endpoints with no resources
- Health checks, status pages

**ALWAYS document WHY:**

```ruby
# Good - explains reasoning
skip_authorization  # Personal data, current_user verified by authentication

# Bad - no explanation
skip_authorization
```

**NEVER skip when:**

- Action involves resources owned by users/organizations
- Action modifies data
- Action accesses shared resources

---

## Common Patterns

### Scoped Resource Loading

```ruby
def show
  @album = current_organization.albums.find(params[:id])
  authorize @album
end
```

Using `current_organization.albums` pre-filters by ownership, but still authorize for explicit checks.

### Nested Resources

```ruby
def create
  @album = current_organization.albums.find(params[:album_id])
  @track = @album.tracks.build(track_params)
  authorize @track

  if @track.save
    # ...
  end
end
```

---

## Error Handling

Pundit raises `Pundit::NotAuthorizedError` when authorization fails.

Handle in `ApplicationController`:

```ruby
rescue_from Pundit::NotAuthorizedError do |exception|
  redirect_to root_path, alert: "You are not authorized to perform this action."
end
```

---

## Discovery

**Find authorization patterns:**

```
Grep "authorize " app/controllers/**/*.rb
```

**Find skipped authorization:**

```
Grep "skip_authorization" app/controllers/**/*.rb
```

**Find policy scopes:**

```
Grep "policy_scope" app/controllers/**/*.rb
```
