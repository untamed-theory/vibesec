#!/bin/bash

# VibeSec Build Rules Script
# Part of the VibeSec project by Untamed Theory (https://untamed.cloud)

set -e

echo "🛠️ VibeSec - Building rules from definitions"

DEFINITIONS_DIR="definitions"
RULES_DIR="rules"
WINDSURF_DIR="${RULES_DIR}/windsurf"
CURSOR_DIR="${RULES_DIR}/cursor"

# Get current date in YYYY-MM-DD format
CURRENT_DATE=$(date +"%Y-%m-%d")

# Create Windsurf front matter for a rule
create_windsurf_frontmatter() {
  local rule_name="$1"
  local rule_file="$2"
  
  # Extract the first heading to use as the title
  local title=$(grep -m 1 "^# " "$rule_file" | sed 's/^# //')
  if [ -z "$title" ]; then
    title="$rule_name"
  fi
  
  # Create front matter
  echo "---"
  echo "trigger: manual"
  echo "title: $title"
  echo "description: Security rule for $rule_name"
  echo "author: Untamed Theory"
  echo "date: $CURRENT_DATE"
  echo "version: 1.0"
  echo "---"
}

# Create Cursor front matter for a rule
create_cursor_frontmatter() {
  local rule_name="$1"
  local component_type="$2"
  
  # Determine appropriate globs based on component type
  local globs="[]"
  case "$component_type" in
    frontend)
      globs="[\"**/*.js\", \"**/*.jsx\", \"**/*.ts\", \"**/*.tsx\", \"**/*.html\", \"**/*.css\"]"
      ;;
    backend)
      globs="[\"**/*.js\", \"**/*.ts\", \"**/*.py\", \"**/*.go\", \"**/*.rb\", \"**/*.php\"]"
      ;;
    database)
      globs="[\"**/*.sql\", \"**/*db*\", \"**/schema.*\", \"**/migration*\"]"
      ;;
    ai)
      globs="[\"**/*.py\", \"**/*.ipynb\", \"**/prompt*\", \"**/*llm*\", \"**/*ai*\"]"  
      ;;
    *)
      globs="[\"**/*\"]"
      ;;
  esac
  
  # Create front matter
  echo "---"
  echo "description: Security rule for $rule_name"
  echo "globs: $globs"
  echo "alwaysApply: false"
  echo "---"
}

# Function to extract content without front matter
extract_content_without_frontmatter() {
  local file="$1"
  
  # Check if file starts with front matter
  if grep -q "^---" "$file"; then
    # Extract content after the front matter
    sed -n '/^---$/,/^---$/d;p' "$file"
  else
    # File has no front matter, return all content
    cat "$file"
  fi
}

# Function to process a definition file
process_definition() {
  local definition_file="$1"
  local component_dir="$2"
  local filename="$(basename "$definition_file")"
  local rule_name="${filename%.md}"
  
  # Extract component type from path
  local component_type="$(basename "$(dirname "$definition_file")")"
  
  echo "Processing: $filename in $component_type"
  
  # Extract content without any existing front matter
  local content_file="$(mktemp)"
  extract_content_without_frontmatter "$definition_file" > "$content_file"
  
  # Create Windsurf version (.md)
  local windsurf_file="${WINDSURF_DIR}/${component_type}/${filename}"
  mkdir -p "$(dirname "$windsurf_file")"
  create_windsurf_frontmatter "$rule_name" "$definition_file" > "$windsurf_file"
  cat "$content_file" >> "$windsurf_file"
  
  # Create Cursor version (.mdc)
  local cursor_file="${CURSOR_DIR}/${component_type}/${rule_name}.mdc"
  mkdir -p "$(dirname "$cursor_file")"
  create_cursor_frontmatter "$rule_name" "$component_type" > "$cursor_file"
  cat "$content_file" >> "$cursor_file"
  
  # Cleanup
  rm "$content_file"
}

# Ensure output directories exist
mkdir -p "$WINDSURF_DIR" "$CURSOR_DIR"

# Process all definition files
echo "Building rules from definitions..."
find "$DEFINITIONS_DIR" -type f -name "security-*.md" | while read file; do
  component_dir="$(dirname "$file" | sed "s|${DEFINITIONS_DIR}/||")"
  process_definition "$file" "$component_dir"
done

echo "✅ All rules built successfully!"
echo "Visit Untamed Theory (https://untamed.cloud) for additional details."
