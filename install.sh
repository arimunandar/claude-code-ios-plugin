#!/bin/bash

# iOS Development Plugin Installer for Claude Code
# Installs VIP+W Clean Architecture, UIKit horizontal-first layouting, and pure UIKit patterns

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Get the directory where this script is located (plugin root)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLUGIN_PATH="$SCRIPT_DIR"

# Claude settings paths
CLAUDE_DIR="$HOME/.claude"
SETTINGS_FILE="$CLAUDE_DIR/settings.json"

echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}       iOS Development Plugin Installer for Claude Code     ${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
echo ""
echo -e "Plugin features:"
echo -e "  • ${GREEN}VIP+W Clean Architecture${NC} (View-Interactor-Presenter-Worker)"
echo -e "  • ${GREEN}UIKit Horizontal-First Layouting${NC} with ASCII previews"
echo -e "  • ${GREEN}Pure UIKit Patterns${NC} (no SwiftUI bridging)"
echo -e "  • ${GREEN}5 Specialized Agents${NC} for iOS development"
echo -e "  • ${GREEN}6 Commands${NC} for build, test, deploy workflows"
echo ""

# Check if plugin directory exists
if [ ! -d "$PLUGIN_PATH" ]; then
    echo -e "${RED}Error: Plugin directory not found at $PLUGIN_PATH${NC}"
    exit 1
fi

# Check for required files
if [ ! -f "$PLUGIN_PATH/.claude-plugin/plugin.json" ]; then
    echo -e "${RED}Error: plugin.json not found. Invalid plugin structure.${NC}"
    exit 1
fi

echo -e "${YELLOW}Plugin path:${NC} $PLUGIN_PATH"
echo ""

# Function to install globally (user-level)
install_global() {
    echo -e "${BLUE}Installing globally to ~/.claude/settings.json...${NC}"

    # Create .claude directory if it doesn't exist
    if [ ! -d "$CLAUDE_DIR" ]; then
        echo -e "Creating $CLAUDE_DIR directory..."
        mkdir -p "$CLAUDE_DIR"
    fi

    # Create or update settings.json
    if [ -f "$SETTINGS_FILE" ]; then
        # Check if plugin is already installed
        if grep -q "$PLUGIN_PATH" "$SETTINGS_FILE" 2>/dev/null; then
            echo -e "${YELLOW}Plugin is already installed globally.${NC}"
            return 0
        fi

        # Backup existing settings
        cp "$SETTINGS_FILE" "$SETTINGS_FILE.backup"
        echo -e "Backed up existing settings to ${SETTINGS_FILE}.backup"

        # Add plugin to existing settings using Python (more reliable JSON handling)
        python3 << EOF
import json
import sys

settings_file = "$SETTINGS_FILE"
plugin_path = "$PLUGIN_PATH"

try:
    with open(settings_file, 'r') as f:
        settings = json.load(f)
except json.JSONDecodeError:
    settings = {}

if 'plugins' not in settings:
    settings['plugins'] = []

if plugin_path not in settings['plugins']:
    settings['plugins'].append(plugin_path)

with open(settings_file, 'w') as f:
    json.dump(settings, f, indent=2)

print(f"Added plugin to {settings_file}")
EOF
    else
        # Create new settings.json
        echo -e "Creating new settings.json..."
        cat > "$SETTINGS_FILE" << EOF
{
  "plugins": [
    "$PLUGIN_PATH"
  ]
}
EOF
    fi

    echo -e "${GREEN}✓ Plugin installed globally!${NC}"
}

# Function to install to a specific project
install_project() {
    local project_dir="$1"

    if [ -z "$project_dir" ]; then
        echo -e "${RED}Error: Project directory required${NC}"
        echo "Usage: $0 --project /path/to/your/ios/project"
        exit 1
    fi

    if [ ! -d "$project_dir" ]; then
        echo -e "${RED}Error: Directory not found: $project_dir${NC}"
        exit 1
    fi

    local project_claude_dir="$project_dir/.claude"
    local project_settings="$project_claude_dir/settings.json"

    echo -e "${BLUE}Installing to project: $project_dir${NC}"

    # Create .claude directory if needed
    if [ ! -d "$project_claude_dir" ]; then
        mkdir -p "$project_claude_dir"
        echo -e "Created $project_claude_dir"
    fi

    # Create or update project settings.json
    if [ -f "$project_settings" ]; then
        if grep -q "$PLUGIN_PATH" "$project_settings" 2>/dev/null; then
            echo -e "${YELLOW}Plugin is already installed in this project.${NC}"
            return 0
        fi

        cp "$project_settings" "$project_settings.backup"

        python3 << EOF
import json

settings_file = "$project_settings"
plugin_path = "$PLUGIN_PATH"

try:
    with open(settings_file, 'r') as f:
        settings = json.load(f)
except:
    settings = {}

if 'plugins' not in settings:
    settings['plugins'] = []

if plugin_path not in settings['plugins']:
    settings['plugins'].append(plugin_path)

with open(settings_file, 'w') as f:
    json.dump(settings, f, indent=2)
EOF
    else
        cat > "$project_settings" << EOF
{
  "plugins": [
    "$PLUGIN_PATH"
  ]
}
EOF
    fi

    echo -e "${GREEN}✓ Plugin installed to project!${NC}"
}

# Function to uninstall
uninstall() {
    echo -e "${BLUE}Uninstalling plugin...${NC}"

    if [ -f "$SETTINGS_FILE" ]; then
        python3 << EOF
import json

settings_file = "$SETTINGS_FILE"
plugin_path = "$PLUGIN_PATH"

try:
    with open(settings_file, 'r') as f:
        settings = json.load(f)

    if 'plugins' in settings and plugin_path in settings['plugins']:
        settings['plugins'].remove(plugin_path)

        with open(settings_file, 'w') as f:
            json.dump(settings, f, indent=2)
        print("Plugin removed from settings")
    else:
        print("Plugin was not found in settings")
except Exception as e:
    print(f"Error: {e}")
EOF
    fi

    echo -e "${GREEN}✓ Plugin uninstalled${NC}"
}

# Function to show status
show_status() {
    echo -e "${BLUE}Plugin Status:${NC}"
    echo ""

    # Check global installation
    if [ -f "$SETTINGS_FILE" ] && grep -q "$PLUGIN_PATH" "$SETTINGS_FILE" 2>/dev/null; then
        echo -e "  Global (~/.claude): ${GREEN}Installed${NC}"
    else
        echo -e "  Global (~/.claude): ${YELLOW}Not installed${NC}"
    fi

    # Check current directory
    if [ -f ".claude/settings.json" ] && grep -q "$PLUGIN_PATH" ".claude/settings.json" 2>/dev/null; then
        echo -e "  Current project:    ${GREEN}Installed${NC}"
    else
        echo -e "  Current project:    ${YELLOW}Not installed${NC}"
    fi

    echo ""
    echo -e "${BLUE}Plugin Contents:${NC}"
    echo "  Agents:   $(ls -1 "$PLUGIN_PATH/agents"/*.md 2>/dev/null | wc -l | tr -d ' ') files"
    echo "  Commands: $(ls -1 "$PLUGIN_PATH/commands"/*.md 2>/dev/null | wc -l | tr -d ' ') files"
    echo "  Skills:   $(ls -1d "$PLUGIN_PATH/skills"/*/ 2>/dev/null | wc -l | tr -d ' ') skills"
}

# Parse arguments
case "${1:-}" in
    --global|-g)
        install_global
        ;;
    --project|-p)
        install_project "$2"
        ;;
    --uninstall|-u)
        uninstall
        ;;
    --status|-s)
        show_status
        ;;
    --help|-h)
        echo "Usage: $0 [OPTION]"
        echo ""
        echo "Options:"
        echo "  --global, -g              Install globally to ~/.claude/settings.json"
        echo "  --project, -p <path>      Install to a specific project"
        echo "  --uninstall, -u           Uninstall from global settings"
        echo "  --status, -s              Show installation status"
        echo "  --help, -h                Show this help message"
        echo ""
        echo "Examples:"
        echo "  $0 --global                          # Install for all projects"
        echo "  $0 --project ~/MyiOSApp              # Install for specific project"
        echo "  $0 --status                          # Check installation status"
        ;;
    *)
        # Default: interactive mode
        echo -e "${YELLOW}Choose installation type:${NC}"
        echo ""
        echo "  1) Global (all projects) - Recommended"
        echo "  2) Current directory only"
        echo "  3) Specific project"
        echo "  4) Show status"
        echo "  5) Cancel"
        echo ""
        read -p "Enter choice [1-5]: " choice

        case $choice in
            1)
                install_global
                ;;
            2)
                install_project "$(pwd)"
                ;;
            3)
                read -p "Enter project path: " project_path
                install_project "$project_path"
                ;;
            4)
                show_status
                ;;
            5)
                echo "Installation cancelled."
                exit 0
                ;;
            *)
                echo -e "${RED}Invalid choice${NC}"
                exit 1
                ;;
        esac
        ;;
esac

echo ""
echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}Next steps:${NC}"
echo -e "  1. Navigate to your iOS project"
echo -e "  2. Run ${YELLOW}claude${NC}"
echo -e "  3. Try: ${YELLOW}\"What architecture should I use?\"${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
