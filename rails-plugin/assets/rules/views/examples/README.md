# View Examples

**Purpose:** Reference implementations organized by topic/dependency. Copy and adapt these structures - don't create markup from scratch.

**Organization:**

Examples are organized by the framework or library they use:

- `beercss/` - BeerCSS component patterns (CSS framework)
- For gem-specific examples, see `_gems/[gem-name]/views/examples/`:
  - `simple_form/` - Form patterns using SimpleForm gem
  - `turbo-rails/` - Turbo Frame and Stream patterns

**How to use:**

1. Find example matching your use case
2. Copy entire structure
3. Adapt: Change model names, paths, content
4. Never create view markup from scratch

**BeerCSS Examples:**

- `index-pattern.html.erb` - Collection list with CRUD
- `show-pattern.html.erb` - Detail page with lazy sections
- `dialog-pattern.html.erb` - Stimulus dialog modal
- `nav-header.html.erb` - Nav with title and actions
- `empty-state.html.erb` - Empty state pattern

**Gem-Specific Examples:**

See `_gems/simple_form/views/examples/` for SimpleForm patterns
See `_gems/turbo-rails/views/examples/` for Turbo patterns

**Decision framework:** See views/conventions.md for WHEN to use which example.
