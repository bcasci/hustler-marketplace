# Hustler Studio

Claude Code plugins for shipping quality software.

## Plugins

### hustler-studio

**Status:** Coming soon

Disciplined development workflows: TDD, refactoring, planning, and quality gates.

- Project-agnostic (works in any codebase)
- Adapts to your conventions via project memory
- Lean and pragmatic (KISS, YAGNI)

### hustler-rails

Rails-specific composable rules that adapt to your dependencies.

- Opinionated conventions for Rails development
- Composable: Only copies rules for gems/libraries you actually use
- Smart detection: Gemfile.lock, database.yml, JS/UI libraries
- Helps bootstrap projects with conventions quickly

### prompting

Prompt writing and optimization using documented techniques.

- Generate, analyze, and optimize prompts
- Applies decision framework and best practices
- Removes bloat, improves clarity

## Future Tech Stack Plugins

The composable rules pattern can extend to other stacks:

- **Django** - Python web framework conventions
- **Laravel** - PHP framework patterns
- **Next.js** - React framework best practices
- **NestJS** - Node.js framework structure
- **Phoenix** - Elixir web patterns
- **Spring Boot** - Java enterprise conventions
- **FastAPI** - Modern Python API patterns

Each provides opinionated, composable rules that bootstrap conventions quickly.

## Installation

Add this marketplace to Claude Code:

```bash
/plugin marketplace add bcasci/hustle-marketplace
```

Then browse and install plugins using the `/plugin` menu, or install directly:

```bash
/plugin install hustler-studio
/plugin install hustler-rails
/plugin install prompting
```

## Philosophy

**Lean and pragmatic.** Simple workflows that work. No over-engineering.

- KISS - Keep it simple
- YAGNI - Build what's useful, skip what's clever
- Pragmatic - Solve real problems, ship quality code

## License

MIT
