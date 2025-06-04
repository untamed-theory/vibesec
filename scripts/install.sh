#!/bin/bash

# VibeSec Installation Script
# Part of the VibeSec project by Untamed Theory (https://untamed.cloud)

set -e

echo "🛡️ VibeSec - Security rules for AI code assistants"

# GitHub repository information
GITHUB_REPO="untamed-theory/vibesec"
GITHUB_BRANCH="main"
TEMP_DIR="$(mktemp -d)"
ENV_TYPE=0 # Default value, will be updated based on detection

# Clean up temporary directory on exit
cleanup() {
  echo "Cleaning up temporary files..."
  rm -rf "$TEMP_DIR"
}
trap cleanup EXIT

# Echo to stderr for easier debugging when piped
debug_echo() {
  echo "$@" >&2
}

# Function to detect which AI assistant is being used
detect_environment() {
  echo "Detecting your environment..."
  
  # Check for Cursor-specific files/folders
  if [ -d ".cursor" ] || [ -f ".cursor.config" ]; then
    echo "✅ Cursor environment detected"
    ENV_TYPE=1
    return 0
  fi

  # Check for Windsurf-specific files/folders
  if [ -d ".windsurf" ]; then
    echo "✅ Windsurf environment detected"
    ENV_TYPE=2
    return 0
  fi

  # If no automatic detection, use a default (Windsurf) for non-interactive environments
  # but provide instructions for manual installation
  echo "❓ Could not automatically detect your AI coding assistant."
  
  # Check if we can read from stdin in an interactive way
  if [ -t 0 ]; then
    # We're in an interactive terminal, ask the user
    echo "Which AI assistant are you using?"
    echo "1) Cursor"
    echo "2) Windsurf"
    read -p "Enter number (1/2) [Default: 2]: " choice
    
    # Validate that choice is a number (1 or 2)
    if [ "$choice" = "1" ]; then
      ENV_TYPE=1
    else
      # Default to Windsurf for anything other than explicit "1"
      ENV_TYPE=2
    fi
  else
    # We're not in an interactive terminal (e.g., piped from curl)
    echo "Non-interactive environment detected. Defaulting to Windsurf."
    echo "If you're using Cursor, please run: curl -sL https://raw.githubusercontent.com/untamed-theory/vibesec/main/scripts/install.sh | bash -s -- --cursor"
    ENV_TYPE=2
  fi
  
  return 0
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
    cd - > /dev/null # Return to original directory silently
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

# Process command line arguments
for arg in "$@"
do
  case $arg in
    --cursor)
      ENV_TYPE=1
      echo "Cursor installation specified via command line"
      shift
      ;;
    --windsurf)
      ENV_TYPE=2
      echo "Windsurf installation specified via command line"
      shift
      ;;
  esac
done

# Main script execution
download_rules

# Only detect environment if not explicitly set via command line
if [ "$ENV_TYPE" -eq 0 ]; then
  detect_environment
fi

# Install rules based on detected environment
install_rules $ENV_TYPE

echo ""
echo "🔒 VibeSec has been installed!"
echo "Your AI coding assistant will now follow these security rules."
echo ""
echo "Visit Untamed Theory (https://untamed.cloud) for additional details."
