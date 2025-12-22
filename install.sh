#!/bin/bash

# OpenCode Installation Script
# This script creates a .opencode folder in a designated directory
# and copies the agents and templates into that folder.

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Check if we're in the opencode directory
if [[ ! -d "$SCRIPT_DIR/agent" || ! -d "$SCRIPT_DIR/template" ]]; then
    print_error "This script must be run from the opencode directory containing 'agent' and 'template' folders"
    exit 1
fi

print_status "OpenCode Installation Script"
print_status "This will install OpenCode agents and templates to a .opencode folder"

# Ask for target directory
echo
read -r -p "Enter the directory path where you want to create .opencode folder (default: $HOME): " target_dir_input

# Set default if empty
if [[ -z "$target_dir_input" ]]; then
    target_dir="$HOME"
else
    # Expand ~ to home directory and resolve relative paths
    target_dir="${target_dir_input/#\~/$HOME}"
    target_dir="$(realpath -m "$target_dir" 2>/dev/null || echo "$target_dir")"
fi

# Check if target directory exists
if [[ ! -d "$target_dir" ]]; then
    print_warning "Directory '$target_dir' does not exist."
    read -r -p "Would you like to create it? (y/N): " create_dir
    if [[ "$create_dir" =~ ^[Yy]$ ]]; then
        mkdir -p "$target_dir"
        print_success "Created directory: $target_dir"
    else
        print_error "Installation cancelled."
        exit 1
    fi
fi

# Define the .opencode folder path
opencode_dir="$target_dir/.opencode"

# Check if .opencode already exists
if [[ -d "$opencode_dir" ]]; then
    print_warning ".opencode folder already exists at: $opencode_dir"
    read -r -p "Do you want to overwrite it? (y/N): " overwrite
    if [[ ! "$overwrite" =~ ^[Yy]$ ]]; then
        print_error "Installation cancelled."
        exit 1
    fi
    print_status "Removing existing .opencode folder..."
    rm -rf "$opencode_dir"
fi

# Create the .opencode directory
print_status "Creating .opencode folder at: $opencode_dir"
mkdir -p "$opencode_dir"

# Copy agent folder
print_status "Copying agents..."
if cp -r "$SCRIPT_DIR/agent" "$opencode_dir/"; then
    print_success "Agents copied successfully"
else
    print_error "Failed to copy agents"
    exit 1
fi

# Copy template folder
print_status "Copying templates..."
if cp -r "$SCRIPT_DIR/template" "$opencode_dir/"; then
    print_success "Templates copied successfully"
else
    print_error "Failed to copy templates"
    exit 1
fi



# Set appropriate permissions
print_status "Setting permissions..."
chmod -R 755 "$opencode_dir"
chmod +x "$opencode_dir/agent"/*.md 2>/dev/null || true

print_success "Installation completed successfully!"
echo
print_status "OpenCode has been installed to: $opencode_dir"
print_status "Structure:"
echo "  $opencode_dir/"
echo "  ├── agent/          # Agent definitions"
echo "  └── template/       # Template files"
echo
print_status "How to use your new OpenCode setup:"
echo "  • Agent files in 'agent/' contain specialized AI agents for D&D tasks"
echo "  • Template files in 'template/' provide structured formats for campaigns"
echo "  • Use agents to create NPCs, locations, organizations, and adventure hooks"
echo "  • Templates ensure consistency across your campaign materials"
echo
print_status "RECOMMENDED WORKFLOW:"
echo "  1. First use @agent/CampaignStarter.md to set up your new campaign"
echo "     - Creates campaign folder structure and initial content"
echo "     - Guides you through campaign configuration questions"
echo "     - Sets up locations, NPCs, and organizations"
echo
echo "  2. Then use @agent/DungeonMaster.md to run your campaign"
echo "     - Manages ongoing gameplay and sessions"
echo "     - Tracks time, inventory, XP, and NPC relationships"
echo "     - Creates session notes and updates campaign files"
echo
print_status "Start with @agent/CampaignStarter.md to begin your campaign!"