#!/bin/bash

# VibeSec Installation Script
# Part of the VibeSec project by Untamed Theory (https://untamed.cloud)

set -e

echo "🛡️ VibeSec - Security rules for AI code assistants"
echo "Detecting your environment..."

# GitHub repository information
GITHUB_REPO="untamed-theory/vibesec"
GITHUB_BRANCH="main"
TEMP_DIR="$(mktemp -d)"

# Clean up temporary directory on exit
cleanup() {
  echo "Cleaning up temporary files..."
  rm -rf "$TEMP_DIR"
}
trap cleanup EXIT

# Function to detect which AI assistant is being used
detect_environment() {
  # Check for Cursor-specific files/folders
  if [ -d ".cursor" ] || [ -f ".cursor.config" ]; then
    echo "✅ Cursor environment detected"
    return 1
  fi

  # Check for Windsurf-specific files/folders
  if [ -d ".windsurf" ]; then
    echo "✅ Windsurf environment detected"
    return 2
  fi

  # If no specific environment detected, ask user
  echo "❓ Could not automatically detect your AI coding assistant."
  echo "Which AI assistant are you using?"
  echo "1) Cursor"
  echo "2) Windsurf"
  read -p "Enter number (1/2): " choice
  
  # Validate that choice is a number (1 or 2)
  if [ "$choice" = "1" ]; then
    return 1
  elif [ "$choice" = "2" ]; then
    return 2
  else
    echo "❌ Invalid selection. Defaulting to Windsurf."
    return 2
  fi
}

# Download rules from GitHub
download_rules() {
  echo "📥 Downloading VibeSec rules from GitHub..."
  
  # Check if we can use git
  if command -v git &> /dev/null; then
    echo "Using git to clone the repository..."
    git clone --depth 1 --filter=blob:none --sparse https://github.com/${GITHUB_REPO}.git "$TEMP_DIR/vibesec"
    cd "$TEMP_DIR/vibesec"
    git sparse-checkout set windsurf cursor
  else
    echo "Git not found, using curl to download..."
    # Download and extract specific directories using GitHub API
    curl -sL "https://github.com/${GITHUB_REPO}/archive/${GITHUB_BRANCH}.zip" -o "$TEMP_DIR/vibesec.zip"
    
    # Check if unzip is available
    if command -v unzip &> /dev/null; then
      unzip -q "$TEMP_DIR/vibesec.zip" -d "$TEMP_DIR"
      mv "$TEMP_DIR/vibesec-${GITHUB_BRANCH}" "$TEMP_DIR/vibesec"
    else
      echo "❌ Error: Neither git nor unzip found. Please install either git or unzip and try again."
      exit 1
    fi
  fi
}

# Install rules for the specified environment
install_rules() {
  local env=$1
  local source_dir=""
  local target_dir=""
  
  if [ "$env" -eq 1 ]; then
    echo "🔄 Installing security rules for Cursor..."
    source_dir="$TEMP_DIR/vibesec/cursor"
    target_dir=".cursor/rules"
  else
    echo "🔄 Installing security rules for Windsurf..."
    source_dir="$TEMP_DIR/vibesec/windsurf"
    target_dir=".windsurf/rules"
  fi
  
  # Create target directory if it doesn't exist
  mkdir -p "$target_dir"
  
  # Copy all security rules to the target directory
  if [ -d "$source_dir" ]; then
    # Search in all vibesec-* directories for security rules
    find "$source_dir/vibesec-"* -type f -name "security-*.md*" -exec cp {} "$target_dir/" \;
    echo "✅ Security rules installed successfully!"
  else
    echo "❌ Error: Could not find rules directory: $source_dir"
    exit 1
  fi
}

# Main script execution
download_rules
detect_environment
env_type=$?

# Install rules based on detected environment
install_rules $env_type

echo ""
echo "🔒 VibeSec has been installed!"
echo "Your AI coding assistant will now follow these security rules."
echo ""
echo "Visit Untamed Theory (https://untamed.cloud) for additional details."
