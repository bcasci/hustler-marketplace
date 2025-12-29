---
paths: "app/models/**/*.rb"
dependencies: [activestorage]
---

# ActiveStorage - File Attachments

File upload and attachment patterns using ActiveStorage.

---

## Basic Attachments

### Single File

```ruby
class Album < ApplicationRecord
  has_one_attached :cover_image
  has_one_attached :audio_preview
end
```

**Usage:**

```ruby
# Attach file
album.cover_image.attach(io: File.open("cover.jpg"), filename: "cover.jpg")

# Check if attached
album.cover_image.attached? # => true

# Access URL
album.cover_image.url

# Remove attachment
album.cover_image.purge
```

---

### Multiple Files

```ruby
class Album < ApplicationRecord
  has_many_attached :photos
end
```

**Usage:**

```ruby
# Attach multiple
album.photos.attach(
  io: File.open("photo1.jpg"), filename: "photo1.jpg"
)

# Check count
album.photos.count

# Iterate
album.photos.each do |photo|
  photo.url
end

# Remove all
album.photos.purge
```

---

## Image Variants

Process images on-the-fly:

```ruby
class Album < ApplicationRecord
  has_one_attached :cover_image

  def cover_image_thumb
    cover_image.variant(resize_to_limit: [300, 300])
  end

  def cover_image_medium
    cover_image.variant(resize_to_limit: [600, 600])
  end
end
```

**In views:**

```erb
<%= image_tag album.cover_image_thumb %>
```

**Common transformations:**

```ruby
# Resize to fit within dimensions
variant(resize_to_limit: [800, 600])

# Resize and crop to exact dimensions
variant(resize_to_fill: [400, 300])

# Convert format
variant(format: :jpg, quality: 80)
```

---

## Validations

Use `active_storage_validations` gem:

```ruby
class Album < ApplicationRecord
  has_one_attached :cover_image

  validates :cover_image,
    content_type: ["image/png", "image/jpg", "image/jpeg"],
    size: { less_than: 5.megabytes }
end
```

**Without gem (manual):**

```ruby
validate :cover_image_type

private

def cover_image_type
  return unless cover_image.attached?

  unless cover_image.content_type.in?(%w[image/jpeg image/png])
    errors.add(:cover_image, "must be JPEG or PNG")
  end
end
```

---

## Form Usage

### Basic Upload

```erb
<%= form_with model: @album do |f| %>
  <%= f.label :cover_image %>
  <%= f.file_field :cover_image, accept: "image/*" %>
<% end %>
```

### Direct Upload (S3/Cloud)

Upload directly to cloud storage without going through Rails server:

```erb
<%= form_with model: @album do |f| %>
  <%= f.file_field :cover_image,
      direct_upload: true,
      accept: "image/*" %>
<% end %>
```

**Requirements:**

- ActiveStorage configured for cloud storage (S3, GCS, Azure)
- JavaScript enabled for direct upload

---

## Strong Parameters

```ruby
# Rails 8
def album_params
  params.expect(album: [:title, :cover_image, photos: []])
end

# Rails 7 and earlier
def album_params
  params.require(:album).permit(:title, :cover_image, photos: [])
end
```

---

## Purging Attachments

```ruby
# Remove immediately
album.cover_image.purge

# Remove in background job
album.cover_image.purge_later

# Remove all (has_many_attached)
album.photos.purge
```

---

## Configuration

**Storage services:**

```yaml
# config/storage.yml
local:
  service: Disk
  root: <%= Rails.root.join("storage") %>

amazon:
  service: S3
  access_key_id: <%= ENV["AWS_ACCESS_KEY_ID"] %>
  secret_access_key: <%= ENV["AWS_SECRET_ACCESS_KEY"] %>
  region: us-east-1
  bucket: my-bucket
```

**Set active service:**

```ruby
# config/environments/production.rb
config.active_storage.service = :amazon

# config/environments/development.rb
config.active_storage.service = :local
```

---

## Discovery

**Find models with attachments:**

```
Grep "has_one_attached\|has_many_attached" app/models/**/*.rb
```

**Find storage configuration:**

```
Read config/storage.yml
```

**Find direct upload usage:**

```
Grep "direct_upload" app/views/**/*.erb
```
