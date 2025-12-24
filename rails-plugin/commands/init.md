---
description: Initialize .claude/rules/hustler-rails/ with Rails conventions tailored to this project's dependencies
---

# Initialize Project Rules

Copy Rails conventions from hustler-rails plugin to `.claude/rules/hustler-rails/`, filtering by project dependencies.

---

## Step 1: Locate Plugin and Project Paths

Discover plugin installation and set paths:

```bash
# Project root
PROJECT_ROOT="${CLAUDE_PROJECT_DIR:-$PWD}"

# Find plugin (cache for installed, marketplace for local dev)
PLUGIN_ROOT=$(find ~/.claude/plugins/cache/hustler-marketplace -type d -name "hustler-rails" 2>/dev/null | head -1)
if [ -z "$PLUGIN_ROOT" ]; then
  PLUGIN_ROOT=$(find ~/.claude/plugins/marketplaces/hustler-marketplace -type d -name "rails-plugin" 2>/dev/null | head -1)
fi

# Validate
if [ -z "$PLUGIN_ROOT" ]; then
  echo "ERROR: hustler-rails plugin not found"
  exit 1
fi

SRC="$PLUGIN_ROOT/assets/rules"
DEST="$PROJECT_ROOT/.claude/rules/hustler-rails"

if [ ! -d "$SRC" ]; then
  echo "ERROR: Plugin assets not found at: $SRC"
  exit 1
fi

echo "✓ Source: $SRC"
echo "✓ Destination: $DEST"
```

---

## Step 2: Detect Project Dependencies

Build list of available dependencies:

```bash
# Gems from Gemfile.lock
GEMS=$(grep "^    " Gemfile.lock 2>/dev/null | awk '{print $1}' | sort)

# JS packages from importmap
JS_PACKAGES=$(grep 'pin "' config/importmap.rb 2>/dev/null | awk -F'"' '{print $2}')

# Database adapter
DB_ADAPTER=$(grep "adapter:" config/database.yml 2>/dev/null | head -1 | awk '{print $2}')
```

Combine into single dependency list (case-insensitive matching).

---

## Step 3: Handle Existing Destination

Check if `.claude/rules/hustler-rails/` exists:

```bash
FILE_COUNT=$(find "$DEST" -type f 2>/dev/null | wc -l)
```

If count > 0, use AskUserQuestion tool:

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
- **Cancel:** Exit without changes

---

## Step 4: Filter and Copy Rules with Examples

For each `.md` file in `$SRC`:

1. **Read front matter** - Extract `dependencies: [...]` and `examples: [...]` arrays
2. **Check dependencies:**
   - If empty array → COPY (universal rule)
   - If all dependencies satisfied → COPY
   - Otherwise → SKIP
3. **Copy rule file** - Preserve relative path from `$SRC` to `$DEST`
4. **Copy examples** - If front matter has `examples: [...]`, copy those example directories:
   - For each example name in array, copy `$SRC/views/examples/{name}/` to `$DEST/views/examples/{name}/`
   - Skip if example directory doesn't exist

Example filtering:

```yaml
dependencies: []                    # Always copy (universal)
dependencies: [vcr]                 # Copy if vcr in gems
dependencies: [beercss]             # Copy if beercss in JS packages
examples: [beercss]                 # Also copy views/examples/beercss/
dependencies: [turbo-rails]         # Copy if turbo-rails gem available
examples: [turbo]                   # Also copy views/examples/turbo/
```

Track: `copied_rules`, `copied_examples`, `skipped_files`

---

## Step 5: Report Results

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
- beercss (importmap.rb)
- sqlite (database.yml)

List copied examples:

- beercss (referenced by views/topics/beercss/beercss-components.md)
- turbo (referenced by views/topics/turbo/turbo-patterns.md)
- simple_form (referenced by views/topics/simple_form/simple-form.md)
