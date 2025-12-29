---
paths: "app/controllers/**/*.rb"
dependencies: []
---

# Flash Messages

Post-action notifications set in controllers.

---

## When to Use Flash

**After action completes:**
- Save/create/update succeeded
- Delete completed
- Action completed with warnings
- User needs confirmation of result

**Don't use flash for:**
- Pre-action confirmations (use `turbo_confirm` in views)
- Form validation errors (render with errors)
- Inline status updates (use Turbo Streams)

---

## Flash Message Pattern

```ruby
# In controller action
def create
  @album = current_organization.albums.build(album_params)

  if @album.save
    flash[:notice] = t('flash.created', resource: Album.model_name.human)
    redirect_to @album
  else
    render :new, status: :unprocessable_entity
  end
end

def destroy
  @album.destroy
  flash[:notice] = t('flash.deleted', resource: Album.model_name.human)
  redirect_to albums_path
end
```

---

## i18n Structure

**Location:** `config/locales/en.yml` (global translations)

```yaml
en:
  flash:
    created: "%{resource} was successfully created."
    updated: "%{resource} was successfully updated."
    deleted: "%{resource} was successfully deleted."
    published: "%{resource} was published."
```

**Pattern:** Use interpolation with `Model.model_name.human` for generic messages.

---

## Flash Types

```ruby
flash[:notice]  # Success/info (green)
flash[:alert]   # Warning/error (red/orange)
```

**Most apps:** Use `:notice` for success, `:alert` for errors.

---

## Flash with Redirect

```ruby
# Standard pattern
flash[:notice] = t('flash.updated', resource: Model.model_name.human)
redirect_to @resource

# Shorthand (same result)
redirect_to @resource, notice: t('flash.updated', resource: Model.model_name.human)
```

---

## Flash vs Turbo Streams

**Use flash + redirect when:**
- Action is complete and user needs confirmation
- Navigating to different page
- Following standard CRUD pattern

**Use Turbo Streams when:**
- Updating part of current page
- Real-time updates without navigation
- Multiple simultaneous updates

```ruby
# Flash: Navigate away
def destroy
  @item.destroy
  flash[:notice] = "Item deleted"
  redirect_to items_path
end

# Turbo Stream: Update in place
def destroy
  @item.destroy
  # Renders destroy.turbo_stream.erb
  # No flash, no redirect
end
```

---

## Quick Reference

| Scenario | Flash Type | After | i18n Location |
|----------|-----------|--------|---------------|
| Create success | `:notice` | Redirect to show | `en.yml` |
| Update success | `:notice` | Redirect to show | `en.yml` |
| Delete success | `:notice` | Redirect to index | `en.yml` |
| Authorization error | `:alert` | Redirect to root | `en.yml` |
| Not found | `:alert` | Redirect to index | `en.yml` |
