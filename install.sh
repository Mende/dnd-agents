#!/bin/bash

# OpenCode Installation Script
# This script adds D&D agents and templates to an existing OpenCode installation
# or creates a standalone .opencode folder in a designated directory.

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

print_status "OpenCode D&D Agents Installation Script"
print_status "This will add D&D agents and templates to your OpenCode installation"

echo

# Detect if there's a main OpenCode installation
opencode_home="$HOME/.opencode"
main_installation_exists=false

if [[ -d "$opencode_home" && -f "$opencode_home/package.json" ]]; then
    main_installation_exists=true
    print_status "Detected main OpenCode installation at: $opencode_home"
fi

# Ask for target directory
echo
if [[ "$main_installation_exists" == true ]]; then
    read -r -p "Enter the directory path where you want to install agents (default: $opencode_home): " target_dir_input
else
    read -r -p "Enter the directory path where you want to create .opencode folder (default: $HOME): " target_dir_input
fi

# Set default if empty
if [[ -z "$target_dir_input" ]]; then
    if [[ "$main_installation_exists" == true ]]; then
        target_dir="$opencode_home"
    else
        target_dir="$HOME"
    fi
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

# Check if this is the main OpenCode installation
is_main_installation=false
if [[ "$target_dir" == "$HOME" && -f "$opencode_dir/package.json" ]]; then
    is_main_installation=true
fi

# Check if .opencode already exists
if [[ -d "$opencode_dir" ]]; then
    if [[ "$is_main_installation" == true ]]; then
        print_warning "This is the main OpenCode installation directory."
        print_status "Only agent/ and template/ folders will be updated."
        read -r -p "Continue? (Y/n): " continue_install
        if [[ "$continue_install" =~ ^[Nn]$ ]]; then
            print_error "Installation cancelled."
            exit 1
        fi
    else
        print_warning ".opencode folder already exists at: $opencode_dir"
        read -r -p "Do you want to update it? (y/N): " overwrite
        if [[ ! "$overwrite" =~ ^[Yy]$ ]]; then
            print_error "Installation cancelled."
            exit 1
        fi
        # For non-main installations, we can safely remove and recreate
        print_status "Removing existing .opencode folder..."
        rm -rf "$opencode_dir"
        mkdir -p "$opencode_dir"
    fi
else
    # Create the .opencode directory
    print_status "Creating .opencode folder at: $opencode_dir"
    mkdir -p "$opencode_dir"
fi

# Handle agent folder
if [[ "$is_main_installation" == true ]]; then
    # For main installation, only update/add agents without deleting other files
    print_status "Installing agents to main OpenCode installation..."
    
    # Create agent directory if it doesn't exist
    mkdir -p "$opencode_dir/agent"
    
    # Copy each agent file, overwriting if exists
    for agent_file in "$SCRIPT_DIR/agent"/*.md; do
        if [[ -f "$agent_file" ]]; then
            filename=$(basename "$agent_file")
            cp -f "$agent_file" "$opencode_dir/agent/"
            print_success "Installed/updated agent: $filename"
        fi
    done
    
    # Handle template folder similarly
    print_status "Installing templates to main OpenCode installation..."
    mkdir -p "$opencode_dir/template"
    
    for template_file in "$SCRIPT_DIR/template"/*; do
        if [[ -f "$template_file" ]]; then
            filename=$(basename "$template_file")
            cp -f "$template_file" "$opencode_dir/template/"
            print_success "Installed/updated template: $filename"
        fi
    done
else
    # For standalone installation, copy entire folders
    print_status "Copying agents..."
    if cp -r "$SCRIPT_DIR/agent" "$opencode_dir/"; then
        print_success "Agents copied successfully"
    else
        print_error "Failed to copy agents"
        exit 1
    fi

    print_status "Copying templates..."
    if cp -r "$SCRIPT_DIR/template" "$opencode_dir/"; then
        print_success "Templates copied successfully"
    else
        print_error "Failed to copy templates"
        exit 1
    fi
fi

# Set appropriate permissions
print_status "Setting permissions..."
chmod -R 755 "$opencode_dir/agent" 2>/dev/null || true
chmod -R 755 "$opencode_dir/template" 2>/dev/null || true

print_success "Installation completed successfully!"
echo

if [[ "$is_main_installation" == true ]]; then
    print_status "D&D agents and templates have been added to your main OpenCode installation at: $opencode_dir"
else
    print_status "D&D agents and templates have been installed to: $opencode_dir"
fi

print_status "Structure:"
echo "  $opencode_dir/"
echo "  ├── agent/          # D&D Agent definitions"
echo "  └── template/       # D&D Template files"
echo
print_status "How to use your D&D agents:"
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
