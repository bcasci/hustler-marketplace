---
name: init-rules
description: Initialize Rails coding conventions for a project by detecting dependencies and copying matching rules with examples to .claude/rules/hustler-rails/. Use when setting up Rails conventions for a new project or updating existing rules. Trigger with phrases like "initialize rails rules", "setup rails conventions", "init hustler-rails".
---

## Your Task

You are the init-rules skill for the hustler-rails plugin. When invoked, copy Rails coding conventions from the plugin to the user's project, filtering by detected dependencies.

## Step 1: Detect Project Dependencies

Build comprehensive dependency list:

```bash
# Gems from Gemfile.lock
grep "^    " Gemfile.lock 2>/dev/null | awk '{print $1}' | sort

# Database adapter
grep "adapter:" config/database.yml 2>/dev/null | head -1 | awk '{print $2}'

# JS/UI from importmap
grep 'pin "' config/importmap.rb 2>/dev/null | awk -F'"' '{print $2}'

# JS/UI from CDN links in views
grep -rh "cdn\|unpkg\|jsdelivr" app/views/ 2>/dev/null | grep -oE "(beercss|tailwind|bootstrap|alpinejs|htmx)" | sort -u

# JS/UI from vendor assets
find vendor/javascript vendor/assets app/assets -type f 2>/dev/null | grep -oE "(beercss|turbo|stimulus|tailwind|bootstrap)" | sort -u

# JS/UI from package.json
grep -E '"(dependencies|devDependencies)"' package.json 2>/dev/null | grep -oE "(beercss|turbo|stimulus)" | sort -u
```

Normalize detected dependencies to lowercase. Build a single master list of all detected dependencies.

## Step 2: Check for Existing Rules

Check if `.claude/rules/hustler-rails/` exists and has files.

If existing rules found, use AskUserQuestion tool:

```json
{
  "questions": [
    {
      "question": "hustler-rails rules already exist. How should I proceed?",
      "header": "Existing rules",
      "multiSelect": false,
      "options": [
        {
          "label": "Backup and recreate",
          "description": "Renames existing to .backup-[timestamp]"
        },
        {
          "label": "Merge new files",
          "description": "Keep existing, add new only"
        },
        { "label": "Cancel", "description": "Exit without changes" }
      ]
    }
  ]
}
```

Handle response:

- **Backup and recreate**: `mv .claude/rules/hustler-rails .claude/rules/hustler-rails.backup-$(date +%Y%m%d-%H%M%S)`
- **Merge new files**: Skip files that already exist
- **Cancel**: Exit without changes

## Step 3: Find All Rule Files

Get list of all rule markdown files:

```bash
find {baseDir}/assets/rules -name "*.md" -type f | grep -v README.md
```

## Step 4: Process Each Rule File

For each rule file found:

1. **Read the file** using Read tool
2. **Parse front matter** - Extract `dependencies: [...]` and `examples: [...]` arrays
3. **Check dependencies**:
   - If `dependencies: []` (empty) → Rule is universal, COPY
   - If all dependencies in list are detected → COPY
   - If any dependency missing → SKIP
4. **Copy rule file** if dependencies satisfied:
   ```bash
   mkdir -p "$(dirname .claude/rules/hustler-rails/[relative-path])"
   cp [source-path] .claude/rules/hustler-rails/[relative-path]
   ```
5. **Copy examples** if front matter has `examples: [...]`:
   - For each example name in array:
     ```bash
     mkdir -p .claude/rules/hustler-rails/views/examples
     cp -r {baseDir}/assets/rules/views/examples/[name] .claude/rules/hustler-rails/views/examples/
     ```

**Dependency matching notes:**

- Match case-insensitively
- Handle database adapter aliases:
  - `sqlite` or `sqlite3` → matches sqlite3 adapter
  - `pg` or `postgresql` → matches postgresql adapter
  - `mysql` or `mysql2` → matches mysql2 adapter

Track:

- Rules copied count
- Rules skipped count
- Examples copied count
- List of matched dependencies
- List of skipped dependencies with reasons

## Step 5: Report Results

Report detailed summary:

```
✅ hustler-rails rules initialized

📊 Results:
   Rules: [X] copied, [Y] skipped
   Examples: [Z] directories copied

📍 Destination: .claude/rules/hustler-rails/

Matched dependencies:
- pundit (Gemfile.lock)
- beercss (CDN in app/views/layouts/application.html.erb)
- sqlite3 (database.yml)

Skipped rules (missing dependencies):
- views/topics/tailwind/tailwind-components.md (requires: tailwind)
- authorization/topics/cancancan/cancancan-abilities.md (requires: cancancan)
```

List each copied example with the rule that referenced it.
