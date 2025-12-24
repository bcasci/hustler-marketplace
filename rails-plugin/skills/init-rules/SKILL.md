---
name: init-rules
description: Initialize Rails coding conventions for a project by detecting dependencies and copying matching rules with examples to .claude/rules/hustler-rails/. Use when setting up Rails conventions for a new project or updating existing rules. Trigger with phrases like "initialize rails rules", "setup rails conventions", "init hustler-rails".
---

## Your Task

You are the init-rules skill for the hustler-rails plugin. When invoked, copy Rails coding conventions from the plugin to the user's project, filtering by detected dependencies.

## Step 1: Set Paths

Set source and destination paths:

```bash
SRC="{baseDir}/assets/rules"
DEST="${CLAUDE_PROJECT_DIR:-$PWD}/.claude/rules/hustler-rails"

echo "✓ Source: $SRC"
echo "✓ Destination: $DEST"
```

## Step 2: Detect Project Dependencies

Build dependency list from multiple sources:

```bash
# Gems from Gemfile.lock
GEMS=$(grep "^    " Gemfile.lock 2>/dev/null | awk '{print $1}' | sort)

# Database adapter
DB_ADAPTER=$(grep "adapter:" config/database.yml 2>/dev/null | head -1 | awk '{print $2}')

# JS/UI from importmap
JS_IMPORTMAP=$(grep 'pin "' config/importmap.rb 2>/dev/null | awk -F'"' '{print $2}')

# JS/UI from CDN links in views
JS_CDN=$(grep -rh "cdn\|unpkg\|jsdelivr" app/views/ 2>/dev/null | grep -oE "(beercss|tailwind|bootstrap|alpinejs|htmx)" | sort -u)

# JS/UI from vendor assets
JS_VENDOR=$(find vendor/javascript vendor/assets app/assets/javascripts app/assets/stylesheets -type f 2>/dev/null | grep -oE "(beercss|turbo|stimulus|tailwind|bootstrap)" | sort -u)

# JS/UI from package.json
JS_NPM=$(grep -E '"(dependencies|devDependencies)"' package.json 2>/dev/null | grep -oE "(beercss|turbo|stimulus)" | sort -u)
```

Combine all sources into single dependency list (case-insensitive). Deduplicate entries.

## Step 3: Handle Existing Destination

Check if destination exists and has files:

```bash
if [ -d "$DEST" ] && [ -n "$(find "$DEST" -type f -print -quit 2>/dev/null)" ]; then
  HAS_EXISTING_FILES=true
else
  HAS_EXISTING_FILES=false
fi
```

If `HAS_EXISTING_FILES=true`, use AskUserQuestion tool:

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

Execute based on response:

- **Backup:** `mv "$DEST" "${DEST}.backup-$(date +%Y%m%d-%H%M%S)"`
- **Merge:** Skip existing files during copy
- **Cancel:** Exit

## Step 4: Filter and Copy Rules with Examples

For each `.md` file in `$SRC`:

1. Read front matter - Extract `dependencies: [...]` and `examples: [...]` arrays
2. Check dependencies:
   - If empty array → COPY (universal rule)
   - If all dependencies satisfied → COPY
   - Otherwise → SKIP
3. Copy rule file - Preserve relative path from `$SRC` to `$DEST`
4. Copy examples - If front matter has `examples: [...]`:
   - For each example name, copy `$SRC/views/examples/{name}/` to `$DEST/views/examples/{name}/`
   - Skip if example directory doesn't exist

Example filtering logic:

```yaml
dependencies: []              # Always copy
dependencies: [vcr]           # Copy if vcr in gems
dependencies: [beercss]       # Copy if beercss detected
examples: [beercss]           # Also copy views/examples/beercss/
dependencies: [turbo-rails]   # Copy if turbo-rails in gems
examples: [turbo]             # Also copy views/examples/turbo/
```

Track: `copied_rules`, `copied_examples`, `skipped_files`

## Step 5: Report Results

Report initialization results:

```
✅ hustler-rails rules initialized

📊 Results:
   Rules: [copied_count] copied, [skipped_count] skipped
   Examples: [example_count] directories copied
   Matched dependencies: [dependency list]
   Skipped dependencies: [dependency list with reasons]

📍 Destination: $DEST
```

List dependencies with detection source:

- pundit (Gemfile.lock)
- beercss (CDN link in app/views/layouts/application.html.erb)
- sqlite (database.yml)

List copied examples:

- beercss (referenced by views/topics/beercss/beercss-components.md)
- turbo (referenced by views/topics/turbo/turbo-patterns.md)
- simple_form (referenced by views/topics/simple_form/simple-form.md)
