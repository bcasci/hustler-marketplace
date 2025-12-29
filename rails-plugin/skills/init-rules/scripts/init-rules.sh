#!/bin/bash
set -e

# Get base directory
BASE_DIR="${1:-$(cd "$(dirname "$0")/.." && pwd)}"
RULES_SOURCE="$BASE_DIR/assets/rules"
RULES_DEST=".claude/rules/hustler-rails"

echo "Detecting dependencies..."

# Collect all dependencies
DEPS=""

# Gems from Gemfile.lock
DEPS="$DEPS $(grep "^    " Gemfile.lock 2>/dev/null | awk '{print $1}' | tr '\n' ' ')"

# Database adapter
ADAPTER=$(grep "adapter:" config/database.yml 2>/dev/null | head -1 | awk '{print $2}')
if [[ -n "$ADAPTER" ]]; then
  DEPS="$DEPS $ADAPTER"
  # Handle aliases
  [[ "$ADAPTER" =~ sqlite ]] && DEPS="$DEPS sqlite3"
  [[ "$ADAPTER" =~ pg ]] && DEPS="$DEPS postgresql"
  [[ "$ADAPTER" =~ mysql ]] && DEPS="$DEPS mysql2"
fi

# JS/UI from importmap
DEPS="$DEPS $(grep 'pin "' config/importmap.rb 2>/dev/null | awk -F'"' '{print $2}' | tr '\n' ' ')"

# JS/UI from CDN
DEPS="$DEPS $(grep -rh "cdn\|unpkg\|jsdelivr" app/views/ 2>/dev/null | grep -oE "(beercss|tailwind|bootstrap|alpinejs|htmx)" | tr '\n' ' ')"

# JS/UI from vendor
DEPS="$DEPS $(find vendor/javascript vendor/assets app/assets -type f 2>/dev/null | grep -oE "(beercss|turbo|stimulus|tailwind|bootstrap)" | tr '\n' ' ')"

# Normalize: lowercase, dedupe, trim
DEPS=$(echo "$DEPS" | tr ' ' '\n' | tr '[:upper:]' '[:lower:]' | sort -u | grep -v '^$' | tr '\n' ' ')

echo "Found dependencies: $DEPS"

# Find all rule files
echo -e "\nProcessing rule files..."
COPIED=0
SKIPPED=0
SKIPPED_LIST=""

while IFS= read -r source_file; do
  # Extract front matter between first two --- markers
  front_matter=$(awk '/^---$/ {f++; next} f==1' "$source_file")

  # Parse dependencies array
  file_deps=$(echo "$front_matter" | grep "^dependencies:" | sed 's/dependencies: \[//; s/\]//' | tr ',' '\n' | tr -d ' ' | grep -v '^$' || true)

  # Parse examples array
  file_examples=$(echo "$front_matter" | grep "^examples:" | sed 's/examples: \[//; s/\]//' | tr ',' '\n' | tr -d ' ' | grep -v '^$' || true)

  # Check if dependencies are met
  deps_met=true
  missing=""

  if [[ -n "$file_deps" ]]; then
    for dep in $file_deps; do
      dep_lower=$(echo "$dep" | tr '[:upper:]' '[:lower:]')
      if ! echo "$DEPS" | grep -qw "$dep_lower"; then
        deps_met=false
        missing="$missing $dep"
      fi
    done
  fi

  # Copy if dependencies satisfied
  rel_path="${source_file#$RULES_SOURCE/}"

  if [[ "$deps_met" == "true" ]]; then
    dest_file="$RULES_DEST/$rel_path"
    mkdir -p "$(dirname "$dest_file")"
    cp "$source_file" "$dest_file"
    ((COPIED++))

    # Copy examples if present
    if [[ -n "$file_examples" ]]; then
      for example in $file_examples; do
        example_source="$RULES_SOURCE/views/examples/$example"
        example_dest="$RULES_DEST/views/examples/$example"
        if [[ -d "$example_source" ]]; then
          mkdir -p "$(dirname "$example_dest")"
          cp -r "$example_source" "$example_dest"
        fi
      done
    fi
  else
    ((SKIPPED++))
    SKIPPED_LIST="$SKIPPED_LIST\n  - $rel_path (requires:$missing)"
  fi

done < <(find "$RULES_SOURCE" -name "*.md" -type f | grep -v README.md)

# Report results
echo -e "\n✅ hustler-rails rules initialized"
echo -e "\n📊 Results:"
echo "   Rules: $COPIED copied, $SKIPPED skipped"
echo -e "\n📍 Destination: $RULES_DEST/"

echo -e "\nMatched dependencies:"
for dep in $DEPS; do
  echo "  - $dep"
done

if [[ $SKIPPED -gt 0 ]]; then
  echo -e "\nSkipped rules (missing dependencies):$SKIPPED_LIST"
fi
