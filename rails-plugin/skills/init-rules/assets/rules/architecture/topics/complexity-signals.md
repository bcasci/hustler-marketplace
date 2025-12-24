---
paths: app/**/*.rb
dependencies: []
---

# Complexity Signals

---

## Quick Test

Try describing the method/file in one sentence:

- **Multiple 'and' clauses** → Extract regardless of size
- **Single clear purpose** → Size doesn't matter

---

## Use-Case Driven Extraction

Pattern choice based on use-case, not size:

- **Multi-model operation** → Command
- **External API integration** → Service
- **Complex object construction** → Builder
- **Stateless calculation** → Pure Function

---

## Qualitative Signals

Extract when:

- Scrolling to find methods
- Tests hard to organize
- Extensive test setup required
- Multiple developers confused

---

## Quantitative Observations

**Consider extraction around:**

- ~40+ lines of coordinated logic → Command
- ~200+ lines in model → Concern
- ~100+ lines in controller action → Command

**Typical file sizes in this codebase:**

- Models: 100-155 lines
- Commands: 50-150 lines
- Controllers: <100 lines
- Concerns: 3+ models need behavior OR model >200 lines

---

## KISS

**Start simple:**

- Model method or controller action first
- Extract on fourth duplication
- Three instances of duplication acceptable

**Don't create:**

- Commands for single-model saves
- Services for simple API calls
- Builders for simple construction
- Concerns for single-model behavior

---

## YAGNI

**Extract when:**

- 3+ models currently need same behavior
- Pain is real, not anticipated
- Duplication hurts now, not hypothetically

**Avoid:**

- "We might need this someday" abstractions
- Configurable systems for unchanging requirements
- Generic solutions for specific problems
- Premature optimization

---

## Decision Framework

1. **Use-case match?** → Extract regardless of size
2. **Hard to work with?** → Extract for clarity
3. **Just large?** → Leave it alone
