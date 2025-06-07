#!/bin/bash

# VibeSec Clean Definitions Script
# Part of the VibeSec project by Untamed Theory (https://untamed.cloud)

set -e

echo "🧹 VibeSec - Cleaning front matter from definition files"

# Function to remove front matter from a markdown file
remove_frontmatter() {
  local file="$1"
  local tmp_file="$(mktemp)"
  
  echo "Processing: $file"
  
  # Check if file starts with front matter
  if grep -q "^---" "$file"; then
    # Extract everything after the front matter
    sed -n '/^---$/,/^---$/d;p' "$file" > "$tmp_file"
    # Copy back to original file
    cat "$tmp_file" > "$file"
    echo "  ✅ Front matter removed"
  else
    echo "  ✓ No front matter found"
  fi
  
  # Cleanup
  rm "$tmp_file"
}

# Find all security rule definition files and process them
find "definitions" -type f -name "security-*.md" | while read file; do
  remove_frontmatter "$file"
done

echo "✅ All definition files cleaned!"
echo "Visit Untamed Theory (https://untamed.cloud) for additional details."
