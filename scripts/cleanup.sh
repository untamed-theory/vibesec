#!/bin/bash

# VibeSec Cleanup Script
# Part of the VibeSec project by Untamed Theory (https://untamed.cloud)

set -e

echo "🧹 VibeSec - Cleaning up old directory structure"

# Old directories to remove
OLD_WINDSURF_DIR="windsurf"
OLD_CURSOR_DIR="cursor"

# Function to safely remove a directory after confirmation
remove_dir() {
  local dir="$1"
  if [ -d "$dir" ]; then
    # List contents of directory before removing
    echo "Directory $dir will be removed. Contents:"
    find "$dir" -type f | sort
    
    echo "Removing $dir directory..."
    rm -rf "$dir"
    echo "✅ $dir removed successfully!"
  else
    echo "⏭️ $dir not found, skipping..."
  fi
}

# Remove the old directories
remove_dir "$OLD_WINDSURF_DIR"
remove_dir "$OLD_CURSOR_DIR"

echo "✅ Cleanup completed!"
echo "The vibesec directory structure now uses:"
echo "  - 'definitions/' for canonical rule definitions"
echo "  - 'rules/windsurf/' and 'rules/cursor/' for tool-specific formats"
echo "Visit Untamed Theory (https://untamed.cloud) for additional details."
