# Rails Plugin

Ruby on Rails development conventions and patterns for Claude Code.

## What This Does

Provides Rails-specific coding conventions that adapt to your project's dependencies. Rules are composable - only conventions for gems and libraries you actually use get copied to your project.

## How It Works

**Composable Rules:**

- Each rule file declares which dependencies it requires (`dependencies: [pundit, vcr, beercss]`)
- Rules with no dependencies are universal (models, controllers, testing structure)
- Rules with dependencies only apply if your project uses those gems/libraries
- Examples (ERB templates, code snippets) are bundled with their rules

**Smart Detection:**

- **Gems** - `Gemfile.lock`
- **Database** - `config/database.yml` adapter
- **JS/UI libraries** - Multiple sources:
  - Importmap (`config/importmap.rb`)
  - CDN links in views (beercss, tailwind, etc.)
  - Vendor assets (`vendor/javascript`, `vendor/assets`)
  - Downloaded assets (`app/assets`)
  - Package managers (`package.json`)
- Copies only matching rules and examples to `.claude/rules/hustler-rails/`

## Installation

Install from hustler-marketplace:

```bash
claude plugin install hustler-rails
```

## Commands

### `/init-rules`

Initialize Rails conventions for your project:

```bash
/init-rules
```

**What it does:**

1. Detects your project's dependencies (gems, JS packages, database)
2. Filters rule files by front matter dependencies
3. Copies matching rules to `.claude/rules/hustler-rails/`
4. Includes examples for matched dependencies (BeerCSS components, Turbo patterns, etc.)

**Example:** If you have `pundit` gem, you get authorization rules. If you have `beercss` (via importmap, CDN, or vendor), you get BeerCSS component patterns and ERB examples.

**Handles existing rules:**

- Backup and recreate
- Merge (keep existing, add new)
- Cancel

## Rule Categories

- **Models** - Associations, validations, scopes, query patterns
- **Views** - ERB patterns, component examples (BeerCSS, Turbo, SimpleForm)
- **Controllers** - RESTful patterns, parameter handling
- **Testing** - Minitest structure, VCR, Capybara, system tests
- **Authorization** - Pundit policies and patterns
- **Jobs** - Background job conventions
- **Database** - SQLite patterns, multi-db, FTS5 search
- **Business Logic** - Command pattern, service objects
- **Architecture** - Complexity signals, refactoring indicators

## License

MIT
