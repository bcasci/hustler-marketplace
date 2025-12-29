---
paths: "test/controllers/**/*.rb, test/integration/**/*.rb"
dependencies: [pundit]
---

# Pundit - Controller Testing

Testing authorization in controllers.

---

## Testing Authorization

Test that controllers enforce authorization:

```ruby
# test/controllers/albums_controller_test.rb
class AlbumsControllerTest < ActionDispatch::IntegrationTest
  test "update requires authorization" do
    sign_in_as(users(:artist))
    album = albums(:other_users_album)

    patch album_path(album), params: { album: { title: 'Hacked' } }

    assert_redirected_to root_path
    assert_equal "not authorized", flash[:alert]
  end

  test "authorized user can update" do
    user = users(:artist)
    sign_in_as(user)
    album = user.albums.first

    patch album_path(album), params: { album: { title: 'New Title' } }

    assert_redirected_to album_path(album)
    assert_equal 'New Title', album.reload.title
  end
end
```

---

## Testing Policy Scopes in Index

```ruby
test "index only shows authorized albums" do
  user = users(:artist)
  sign_in_as(user)

  user_album = user.albums.first
  other_album = albums(:other_users_album)

  get albums_path

  assert_response :success
  assert_select "h2", text: user_album.title
  assert_select "h2", text: other_album.title, count: 0
end

test "admin sees all albums" do
  sign_in_as(users(:admin))

  get albums_path

  assert_response :success
  assert_equal Album.count, assigns(:albums).count
end
```

---

## Testing Custom Actions

```ruby
test "publish requires authorization" do
  sign_in_as(users(:artist))
  album = albums(:other_users_draft)

  post publish_album_path(album)

  assert_redirected_to root_path
  assert_equal "not authorized", flash[:alert]
end

test "authorized user can publish their draft" do
  user = users(:artist)
  sign_in_as(user)
  album = user.albums.draft.first

  post publish_album_path(album)

  assert_redirected_to album_path(album)
  assert album.reload.published?
end
```

---

## Testing Pundit Rescue

Test that unauthorized access is handled:

```ruby
test "unauthorized access redirects with message" do
  sign_in_as(users(:basic_user))
  album = albums(:private_album)

  get edit_album_path(album)

  assert_redirected_to root_path
  assert_match /not authorized/, flash[:alert]
end
```

---

## Testing Guest Access

```ruby
test "guests cannot access protected actions" do
  album = albums(:published)

  patch album_path(album), params: { album: { title: 'Hacked' } }

  assert_redirected_to sign_in_path
end

test "guests can view public content" do
  album = albums(:published)

  get album_path(album)

  assert_response :success
end
```
