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

# Detect if there's a main OpenCode installation or config directory
opencode_home="$HOME/.opencode"
opencode_config="$HOME/.config/opencode"
main_installation_exists=false
config_exists=false

if [[ -d "$opencode_home" && -f "$opencode_home/package.json" ]]; then
    main_installation_exists=true
    print_status "Detected main OpenCode installation at: $opencode_home"
fi

if [[ -d "$opencode_config" ]]; then
    config_exists=true
    print_status "Detected OpenCode config directory at: $opencode_config"
fi

# Ask for installation mode
echo
print_status "Choose installation mode:"
echo "  1. System-wide (global) - Available to all OpenCode sessions (Recommended)"
echo "  2. Legacy - Install to ~/.opencode for backward compatibility"
echo "  3. Custom - Specify a custom directory"
echo

read -r -p "Select option [1/2/3] (default: 1): " install_mode

case "${install_mode:-1}" in
    1)
        # System-wide installation to ~/.config/opencode
        target_dir="$opencode_config"
        install_type="global"
        print_status "Installing system-wide to: $target_dir"
        ;;
    2)
        # Legacy installation to ~/.opencode
        target_dir="$opencode_home"
        install_type="legacy"
        print_status "Installing to legacy location: $target_dir"
        ;;
    3)
        # Custom installation
        read -r -p "Enter the directory path where you want to create .opencode folder: " target_dir_input
        if [[ -z "$target_dir_input" ]]; then
            print_error "No directory specified. Installation cancelled."
            exit 1
        fi
        # Expand ~ to home directory and resolve relative paths
        target_dir="${target_dir_input/#\~/$HOME}"
        target_dir="$(realpath -m "$target_dir" 2>/dev/null || echo "$target_dir")"
        install_type="custom"
        ;;
    *)
        print_error "Invalid option. Installation cancelled."
        exit 1
        ;;
esac

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

# Define the installation path based on installation type
if [[ "$install_type" == "global" ]]; then
    # For global installation, install directly to ~/.config/opencode (no .opencode subfolder)
    install_dir="$target_dir"
    is_main_installation=false
elif [[ "$install_type" == "legacy" ]]; then
    # For legacy installation, check if it's the main OpenCode installation
    install_dir="$target_dir"
    is_main_installation=false
    if [[ "$target_dir" == "$HOME/.opencode" && -f "$target_dir/package.json" ]]; then
        is_main_installation=true
    fi
else
    # For custom installation, create .opencode subfolder
    install_dir="$target_dir/.opencode"
    is_main_installation=false
fi

# Check if installation directory already exists
if [[ -d "$install_dir" ]]; then
    if [[ "$install_type" == "global" ]]; then
        print_warning "OpenCode config directory already exists at: $install_dir"
        print_status "D&D agents and templates will be added/updated."
        if [[ -d "$install_dir/agent" ]] || [[ -d "$install_dir/template" ]]; then
            print_warning "Existing agent/ and/or template/ folders found."
            print_status "D&D agents will be merged with existing content."
        fi
        read -r -p "Continue? (Y/n): " continue_install
        if [[ "$continue_install" =~ ^[Nn]$ ]]; then
            print_error "Installation cancelled."
            exit 1
        fi
    elif [[ "$is_main_installation" == true ]]; then
        print_warning "This is the main OpenCode installation directory."
        print_status "Only agent/ and template/ folders will be updated."
        read -r -p "Continue? (Y/n): " continue_install
        if [[ "$continue_install" =~ ^[Nn]$ ]]; then
            print_error "Installation cancelled."
            exit 1
        fi
    else
        print_warning "Directory already exists at: $install_dir"
        read -r -p "Do you want to update it? (y/N): " overwrite
        if [[ ! "$overwrite" =~ ^[Yy]$ ]]; then
            print_error "Installation cancelled."
            exit 1
        fi
        # For custom installations, we can safely remove and recreate
        if [[ "$install_type" == "custom" ]]; then
            print_status "Removing existing directory..."
            rm -rf "$install_dir"
        fi
        mkdir -p "$install_dir"
    fi
else
    # Create the installation directory
    print_status "Creating directory at: $install_dir"
    mkdir -p "$install_dir"
fi

# Handle agent and template installation
if [[ "$install_type" == "global" ]] || [[ "$is_main_installation" == true ]]; then
    # For global or main installation, only update/add agents without deleting other files
    print_status "Installing agents..."
    
    # Create agent directory if it doesn't exist (use 'agents' for global config per docs)
    if [[ "$install_type" == "global" ]]; then
        agent_dir="$install_dir/agents"
    else
        agent_dir="$install_dir/agent"
    fi
    mkdir -p "$agent_dir"
    
    # Copy each agent file, overwriting if exists
    for agent_file in "$SCRIPT_DIR/agent"/*.md; do
        if [[ -f "$agent_file" ]]; then
            filename=$(basename "$agent_file")
            cp -f "$agent_file" "$agent_dir/"
            print_success "Installed/updated agent: $filename"
        fi
    done
    
    # Handle template folder similarly
    print_status "Installing templates..."
    mkdir -p "$install_dir/template"
    
    for template_file in "$SCRIPT_DIR/template"/*; do
        if [[ -f "$template_file" ]]; then
            filename=$(basename "$template_file")
            cp -f "$template_file" "$install_dir/template/"
            print_success "Installed/updated template: $filename"
        fi
    done
else
    # For custom installation, copy entire folders
    print_status "Copying agents..."
    if cp -r "$SCRIPT_DIR/agent" "$install_dir/"; then
        print_success "Agents copied successfully"
    else
        print_error "Failed to copy agents"
        exit 1
    fi

    print_status "Copying templates..."
    if cp -r "$SCRIPT_DIR/template" "$install_dir/"; then
        print_success "Templates copied successfully"
    else
        print_error "Failed to copy templates"
        exit 1
    fi
fi

# Set appropriate permissions
print_status "Setting permissions..."
if [[ "$install_type" == "global" ]]; then
    chmod -R 755 "$install_dir/agents" 2>/dev/null || true
else
    chmod -R 755 "$install_dir/agent" 2>/dev/null || true
fi
chmod -R 755 "$install_dir/template" 2>/dev/null || true

print_success "Installation completed successfully!"
echo

if [[ "$install_type" == "global" ]]; then
    print_status "D&D agents and templates are now available system-wide!"
    print_status "Installed to: $install_dir"
    echo
    print_status "Structure:"
    echo "  $install_dir/"
    echo "  ├── agents/         # D&D Agent definitions (global)"
    echo "  └── template/       # D&D Template files"
    echo
    print_success "These agents and templates are now available in ALL OpenCode sessions!"
elif [[ "$is_main_installation" == true ]]; then
    print_status "D&D agents and templates have been added to your main OpenCode installation at: $install_dir"
    echo
    print_status "Structure:"
    echo "  $install_dir/"
    echo "  ├── agent/          # D&D Agent definitions"
    echo "  └── template/       # D&D Template files"
else
    print_status "D&D agents and templates have been installed to: $install_dir"
    echo
    print_status "Structure:"
    echo "  $install_dir/"
    echo "  ├── agent/          # D&D Agent definitions"
    echo "  └── template/       # D&D Template files"
fi
echo
print_status "How to use your D&D agents:"
if [[ "$install_type" == "global" ]]; then
    echo "  • Reference agents with @ in any OpenCode session: @CampaignStarter, @DungeonMaster, etc."
    echo "  • Templates are available in all projects for consistent campaign materials"
else
    echo "  • Agent files in 'agent/' contain specialized AI agents for D&D tasks"
    echo "  • Template files in 'template/' provide structured formats for campaigns"
fi
echo "  • Use agents to create NPCs, locations, organizations, and adventure hooks"
echo "  • Templates ensure consistency across your campaign materials"
echo
print_status "RECOMMENDED WORKFLOW:"
echo "  1. First use @CampaignStarter to set up your new campaign"
echo "     - Creates campaign folder structure and initial content"
echo "     - Guides you through campaign configuration questions"
echo "     - Sets up locations, NPCs, and organizations"
echo
echo "  2. Then use @DungeonMaster to run your campaign"
echo "     - Manages ongoing gameplay and sessions"
echo "     - Tracks time, inventory, XP, and NPC relationships"
echo "     - Creates session notes and updates campaign files"
echo
if [[ "$install_type" == "global" ]]; then
    print_success "Start with @CampaignStarter in any OpenCode session to begin!"
else
    print_status "Start with @agent/CampaignStarter.md to begin your campaign!"
fi
