---
paths: test/system/**/*.rb, test/views/**/*.rb
dependencies: [pundit]
---

# Pundit - View Testing

Testing conditional UI based on authorization.

---

## System Tests for Conditional UI

Test that UI elements are shown/hidden based on permissions:

```ruby
# test/system/albums_test.rb
class AlbumsTest < ApplicationSystemTestCase
  test "owner sees edit and delete links" do
    user = users(:artist)
    album = user.albums.first
    sign_in_as(user)

    visit album_path(album)

    assert_link "Edit"
    assert_button "Delete"
  end

  test "non-owner does not see edit and delete links" do
    user = users(:artist)
    other_album = albums(:other_users_album)
    sign_in_as(user)

    visit album_path(other_album)

    assert_no_link "Edit"
    assert_no_button "Delete"
  end

  test "guest does not see protected actions" do
    album = albums(:published)

    visit album_path(album)

    assert_no_link "Edit"
    assert_no_link "Publish"
    assert_no_button "Delete"
  end
end
```

---

## Testing Admin-Only UI

```ruby
test "admin sees admin panel" do
  sign_in_as(users(:admin))

  visit dashboard_path

  assert_text "Admin Panel"
  assert_link "Manage Users"
end

test "regular user does not see admin panel" do
  sign_in_as(users(:artist))

  visit dashboard_path

  assert_no_text "Admin Panel"
  assert_no_link "Manage Users"
end
```

---

## Testing Custom Action Links

```ruby
test "shows publish link for drafts" do
  user = users(:artist)
  draft = user.albums.draft.first
  sign_in_as(user)

  visit album_path(draft)

  assert_link "Publish"
  assert_no_link "Archive"
end

test "shows archive link for published albums" do
  user = users(:artist)
  published = user.albums.published.first
  sign_in_as(user)

  visit album_path(published)

  assert_link "Archive"
  assert_no_link "Publish"
end
```

---

## Testing Navigation Based on Permissions

```ruby
test "shows different navigation for different roles" do
  admin = users(:admin)
  artist = users(:artist)

  sign_in_as(admin)
  visit root_path
  assert_link "All Albums"

  click_link "Sign out"

  sign_in_as(artist)
  visit root_path
  assert_link "My Albums"
  assert_no_link "All Albums"
end
```

---

## Testing Policy Checks in Partials

```ruby
test "album card shows actions based on policy" do
  user = users(:artist)
  user_album = user.albums.first
  other_album = albums(:other_users_album)
  sign_in_as(user)

  visit albums_path

  # User's album shows actions
  within "#album_#{user_album.id}" do
    assert_link "Edit"
    assert_button "Delete"
  end

  # Other user's album does not
  within "#album_#{other_album.id}" do
    assert_no_link "Edit"
    assert_no_button "Delete"
  end
end
```
