---
paths: app/**/*.rb
dependencies: []
---

# Architecture

**Pragmatists, not purists.** Use different architectural patterns based on complexity and use case.

---

## Philosophy

**KISS: Start simple, extract when complexity demands.**

Logic begins in obvious place (model/controller). Add structure only when warranted. Three lines of duplication beats premature abstraction.

**YAGNI: Build for today's needs, not hypothetical futures.**

Extract when 3+ models need same behavior, not when 1 might. Add patterns when pain is real, not anticipated.

**No single architecture fits all use cases.**

- Simple operations stay simple (models, controllers)
- Complex operations get structure (commands, services)
- Pattern choice driven by problem complexity, not dogma

---

## Where Does Code Go?

- **Multi-model operation?** → Command Pattern (`app/business_logic/commands/`)
- **External API integration?** → Service Layer (`app/services/`)
- **Complex object construction?** → Builder Pattern (`app/business_logic/builders/`)
- **Pure calculation (no side effects)?** → Pure Functions (`app/business_logic/calculations/`)
- **Complex logic on model data?** → Value Objects (`app/models/[domain]/`)
- **Single-model domain logic?** → Active Record (`app/models/`)
- **Simple CRUD (build/save)?** → Transaction Script (Controllers)
- **Complex query composition?** → Query Objects (`app/queries/`)
- **Presentation logic (multiple models)?** → View Models (`app/models/view_models/`)

---

## Pragmatic Principles

1. **Start simple** - Logic begins in obvious place (model/controller)
2. **Extract when warranted** - Complexity drives pattern choice
3. **Avoid premature abstraction** - Wait until need is clear
4. **Use-case driven** - Pattern fits the problem, not vice versa
5. **Threshold-based** - Complexity metrics guide extraction
6. **Context over ceremony** - Simple context hash vs complex Result objects
