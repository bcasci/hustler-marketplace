---
paths: test/controllers/**/*_test.rb
dependencies: []
---

# Controller Testing Patterns

Controller tests verify HTTP response codes and basic side effects. Leave content testing to system tests.

## Basic Structure

```ruby
class AlbumsControllerTest < ActionDispatch::IntegrationTest
  describe '#show' do
    let(:album) { albums(:album_one) }

    it 'responds successfully' do
      get album_url(album)
      assert_response :success
    end
  end
end
```

**IMPORTANT**: Always organize tests by controller actions (e.g., `describe '#show'`), NOT by the controller itself. This ensures proper test inheritance and organization.

## Response Code Testing

```ruby
# Success responses
assert_response :success        # 200
assert_response :created        # 201

# Redirects
assert_response :redirect       # 3xx
assert_redirected_to album_path(@album)

# Client errors
assert_response :forbidden      # 403
assert_response :not_found      # 404
assert_response :unprocessable_entity  # 422
```

## Authentication Testing

Test authentication when the controller requires a logged-in user.

**How to know:** Make the request without signing in. If it works (200), it's public. If it redirects or returns 401, test both cases.

```ruby
# Test both cases when endpoint requires authentication
describe 'when user is authenticated' do
  before { passwordless_sign_in(users(:artist)) }

  it 'allows access' do
    get protected_path
    assert_response :success
  end
end

describe 'when user is not authenticated' do
  it 'redirects to login' do
    get protected_path
    assert_redirected_to auth_path
  end
end

# Skip authentication testing when endpoint is public
it 'allows public access' do
  get public_path
  assert_response :success
end
```

## Record Creation/Deletion

```ruby
describe '#create' do
  let(:user) { users(:artist) }
  let(:album_params) { { title: 'New Album', price_cents: 1000 } }

  before do
    passwordless_sign_in(user)
  end

  it 'creates album' do
    assert_difference 'Album.count' do
      post albums_path, params: { album: album_params }
    end

    assert_redirected_to album_path(Album.last)
  end
end

describe '#destroy' do
  let(:album) { albums(:published) }

  before do
    passwordless_sign_in(album.organization.owner)
  end

  it 'destroys album' do
    assert_difference 'Album.count', -1 do
      delete album_path(album)
    end
  end
end
```

## Format-Specific Requests

```ruby
# Turbo Stream
post cart_items_url,
     params: { cart_item: { product_variant_id: variant.id } },
     headers: { 'HTTP_ACCEPT' => 'text/vnd.turbo-stream.html' }
assert_response :success

# Or using :as
post recommendations_url, params: { recommendation: params }, as: :turbo_stream
assert_response :success

# JSON
get album_path(@album), as: :json
assert_response :success
```

## Job Enqueueing

```ruby
describe 'when creating successfully' do
  it 'enqueues SendNotificationJob' do
    assert_enqueued_with(job: SendNotificationJob) do
      post album_recommendations_url(album), params: { recommendation: params }
    end
  end
end
```

## View Variants

```ruby
describe 'with tiles view variant' do
  it 'returns a successful response' do
    get recommendations_url(view: :tiles, facet: :new)
    assert_response :success
  end
end
```

## What NOT to Test in Controllers

- Complex view rendering (use system tests)
- Detailed response body content (use system tests)
- Business logic details (test in commands/models)
- JavaScript behavior (use system tests)
- Which specific records appear in results (test in model scopes)

## When Response Content Checking IS Appropriate

**Exception: Test infrastructure/configuration concerns, not business logic.**

Response content checking is valid when verifying **app configuration** or **app-specific contracts**, NOT framework behavior:

### App Configuration Correctness

```ruby
# ✅ GOOD - Testing OUR app has all required translations
describe 'GET #show' do
  it 'has no missing translation keys' do
    get album_url(albums(:published))
    assert_response :success
    assert_no_match /translation.missing/, @response.body
  end
end
```

**Why valid:** Tests OUR app's i18n configuration, not whether Rails i18n works.

### API Contract Compliance

```ruby
# ✅ GOOD - Testing OUR API returns promised structure
describe 'GET #index.json' do
  it 'returns required API fields' do
    get albums_url(format: :json)

    json = JSON.parse(@response.body)
    assert json.key?('albums')
    assert json.key?('meta')
    assert json['albums'].first.key?('id')
    assert json['albums'].first.key?('title')
  end
end

# ❌ BAD - Testing which albums appear (business logic)
describe 'GET #index.json' do
  it 'returns only published albums' do
    get albums_url(format: :json)

    json = JSON.parse(@response.body)
    assert_equal 3, json['albums'].count  # Wrong layer!
    assert json['albums'].all? { |a| a['status'] == 'published' }  # Wrong layer!
  end
end
```

**Why valid (first):** Tests OUR API contract structure.
**Why invalid (second):** Tests business logic (which records appear).

### App-Specific Framework Usage

```ruby
# ✅ GOOD - Testing OUR Turbo Stream response uses correct action
describe 'POST #create.turbo_stream' do
  it 'returns turbo stream with append action' do
    post cart_items_url,
         params: { cart_item: valid_params },
         as: :turbo_stream

    assert_match /<turbo-stream.*action="append"/, @response.body
    assert_match /target="cart-items"/, @response.body
  end
end

# ❌ BAD - Testing cart item data appears correctly
describe 'POST #create.turbo_stream' do
  it 'includes cart item details' do
    post cart_items_url,
         params: { cart_item: valid_params },
         as: :turbo_stream

    assert_match /#{album.title}/, @response.body  # Wrong layer!
  end
end
```

**Why valid (first):** Tests OUR app's Turbo Stream integration is wired correctly.
**Why invalid (second):** Tests what data appears (business logic/view concern).

### Error Response Format

```ruby
# ✅ GOOD - Testing OUR API error format is consistent
describe 'POST #create with invalid data' do
  it 'returns errors in API format' do
    post albums_url(format: :json), params: { album: { title: '' } }

    assert_response :unprocessable_entity
    json = JSON.parse(@response.body)
    assert json.key?('errors')
    assert json['errors'].is_a?(Hash)
  end
end
```

**Why valid:** Tests OUR API contract for error responses.

### The Distinction

**✅ Test these (app behavior/configuration):**
- OUR app's i18n configuration completeness
- OUR API contract compliance (structure, required fields)
- OUR Turbo Stream actions match intended behavior
- OUR error response format consistency
- OUR multi-format endpoints return correct format

**❌ Don't test these (framework or business logic):**
- Whether Rails i18n works
- Whether Rails renders JSON
- Whether Turbo Streams work
- Which specific records appear
- Data accuracy or calculations

**Simple rule**: If you're checking that YOUR app's infrastructure/contracts work correctly, it's valid. If you're checking WHAT data appears or WHETHER the framework works, it's the wrong layer.

### Recognizing Wrong-Layer Tests

Controller tests should ONLY verify HTTP-level behavior:

- ✅ Response codes (200, 404, 422, etc.)
- ✅ Redirects and their destinations
- ✅ Basic authentication/authorization (returns 403 or redirects)
- ✅ Format handling (JSON vs HTML vs Turbo Stream)

Controller tests should NEVER verify business logic:

- ❌ Which specific records appear in results
- ❌ Business rule validations
- ❌ Data transformations or calculations
- ❌ What a scope returns

**Simple rule**: If you're testing WHAT data appears rather than WHETHER the request succeeded, you're testing in the wrong place.

### Example: Wrong-Layer Testing

```ruby
# ❌ BAD - Testing model logic in controller test
describe 'GET #index' do
  it 'shows only genres with salable releases' do
    get genres_url
    assert_response :success

    # This tests Genre.with_salable_releases logic!
    assert_includes @response.body, genres(:rock).name
    assert_not_includes @response.body, genres(:empty_genre).name
  end
end

# ✅ GOOD - Test HTTP behavior only
describe 'GET #index' do
  it 'returns successful response' do
    get genres_url
    assert_response :success
  end
end

# ✅ Test the actual logic in the model test
class GenreTest < ActiveSupport::TestCase
  describe '.with_salable_releases' do
    it 'includes genres with salable albums' do
      genres = Genre.with_salable_releases
      assert_includes genres.map(&:name), genres(:rock).name
    end

    it 'excludes genres without salable albums' do
      genres = Genre.with_salable_releases
      assert_not_includes genres.map(&:name), genres(:empty_genre).name
    end
  end
end
```

### When Bugs Appear in Controllers

Just because you noticed a bug in a controller doesn't mean you test it there. Find where the logic actually lives:

- Logic in a model scope → Test it there
- Logic in a business command → Test it there
- Logic in a helper method → Test it there
- Logic in a service object → Test it there
- Logic missing entirely → Add it where it belongs, then test it there

**Controller tests are for HTTP plumbing, not business logic.**

## Best Practices

1. **Keep it simple** - Test response codes and basic outcomes
2. **Focus on integration** - Controllers are integration tests, not unit tests
3. **Minimal assertions** - Usually just response code and record changes
4. **Use fixtures** - Consistent test data
5. **Avoid complex assertions** - Leave detailed UI testing to system tests
6. **Test critical paths** - Authentication, authorization, record creation
