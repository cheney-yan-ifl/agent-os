#!/bin/bash

# Agent OS Base Installation Script
# This script installs Agent OS to the current directory

set -e  # Exit on error

# Initialize flags
OVERWRITE_INSTRUCTIONS=false
OVERWRITE_STANDARDS=false
OVERWRITE_CONFIG=false

CLAUDE_CODE=false
CURSOR=false
GITHUB_COPILOT=false

# Base URL for raw GitHub content
BASE_URL="https://raw.githubusercontent.com/buildermethods/agent-os/main"

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --overwrite-instructions)
            OVERWRITE_INSTRUCTIONS=true
            shift
            ;;
        --overwrite-standards)
            OVERWRITE_STANDARDS=true
            shift
            ;;
        --overwrite-config)
            OVERWRITE_CONFIG=true
            shift
            ;;
        --claude-code|--claude|--claude_code)
            CLAUDE_CODE=true
            shift
            ;;
        --cursor|--cursor-cli)
            CURSOR=true
            shift
            ;;
        --github-copilot)
            GITHUB_COPILOT=true
            shift
            ;;
        -h|--help)
            echo "Usage: $0 [OPTIONS]"
            echo ""
            echo "Options:"
            echo "  --overwrite-instructions    Overwrite existing instruction files"
            echo "  --overwrite-standards       Overwrite existing standards files"
            echo "  --overwrite-config          Overwrite existing config.yml"
            echo "  --claude-code               Add Claude Code support"
            echo "  --cursor                    Add Cursor support"
            echo "  --github-copilot            Add GitHub Copilot support"
            echo "  -h, --help                  Show this help message"
            echo ""
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            echo "Use --help for usage information"
            exit 1
            ;;
    esac
done

echo ""
echo "🚀 Agent OS Base Installation"
echo "============================="
echo ""

# Set installation directory to current directory
CURRENT_DIR=$(pwd)
INSTALL_DIR="$CURRENT_DIR/.agent-os"

echo "📍 The Agent OS base installation will be installed in the current directory ($CURRENT_DIR)"
echo ""

echo "📁 Creating base directories..."
echo ""
mkdir -p "$INSTALL_DIR"
mkdir -p "$INSTALL_DIR/setup"

# Download functions.sh to its permanent location and source it
echo "📥 Downloading setup functions..."
curl -sSL "${BASE_URL}/setup/functions.sh" -o "$INSTALL_DIR/setup/functions.sh"
source "$INSTALL_DIR/setup/functions.sh"

echo ""
echo "📦 Installing the latest version of Agent OS from the Agent OS GitHub repository..."

# Install /instructions, /standards, and /commands folders and files from GitHub
install_from_github "$INSTALL_DIR" "$OVERWRITE_INSTRUCTIONS" "$OVERWRITE_STANDARDS"

# Download config.yml
echo ""
echo "📥 Downloading configuration..."
download_file "${BASE_URL}/config.yml" \
    "$INSTALL_DIR/config.yml" \
    "$OVERWRITE_CONFIG" \
    "config.yml"

# Download setup/project.sh
echo ""
echo "📥 Downloading project setup script..."
download_file "${BASE_URL}/setup/project.sh" \
    "$INSTALL_DIR/setup/project.sh" \
    "true" \
    "setup/project.sh"
chmod +x "$INSTALL_DIR/setup/project.sh"

## Handle Claude Code installation
if [ "$CLAUDE_CODE" = true ]; then
    echo ""
    echo "📥 Downloading Claude Code agent templates..."
    mkdir -p "$INSTALL_DIR/claude-code/agents"

    # Download agents to base installation for project use
    echo "  📂 Agent templates:"
    for agent in context-fetcher date-checker file-creator git-workflow project-manager test-runner; do
        download_file "${BASE_URL}/claude-code/agents/${agent}.md" \
            "$INSTALL_DIR/claude-code/agents/${agent}.md" \
            "false" \
            "claude-code/agents/${agent}.md"
    done

    # Update config to enable claude_code
    if [ -f "$INSTALL_DIR/config.yml" ]; then
        sed -i.bak '/claude_code:/,/enabled:/ s/enabled: false/enabled: true/' "$INSTALL_DIR/config.yml" && rm "$INSTALL_DIR/config.yml.bak"
    fi
fi

## Handle GitHub Copilot installation
if [ "$GITHUB_COPILOT" = true ]; then
    echo ""
    echo "📥 Enabling GitHub Copilot support..."
    mkdir -p "$INSTALL_DIR/github-copilot-prompts"

    # Download all .github/prompts/* files and rename to <command>.prompt.md
    PROMPT_LIST_URL="${BASE_URL}/.github/prompts/"
    # List of commands to support (update as needed)
    for cmd in analyze-product create-spec create-tasks execute-tasks plan-product; do
        download_file "${BASE_URL}/.github/prompts/${cmd}.md" \
            "$INSTALL_DIR/github-copilot-prompts/${cmd}.prompt.md" \
            "false" \
            "github-copilot-prompts/${cmd}.prompt.md"
    done

    # Update config to enable github_copilot
    if [ -f "$INSTALL_DIR/config.yml" ]; then
        sed -i.bak '/github_copilot:/,/enabled:/ s/enabled: false/enabled: true/' "$INSTALL_DIR/config.yml" && rm "$INSTALL_DIR/config.yml.bak"
        echo "  ✓ GitHub Copilot enabled in configuration"
    fi
fi

## Handle Cursor installation
if [ "$CURSOR" = true ]; then
    echo ""
    echo "📥 Enabling Cursor support..."

    # Only update config to enable cursor
    if [ -f "$INSTALL_DIR/config.yml" ]; then
        sed -i.bak '/cursor:/,/enabled:/ s/enabled: false/enabled: true/' "$INSTALL_DIR/config.yml" && rm "$INSTALL_DIR/config.yml.bak"
        echo "  ✓ Cursor enabled in configuration"
    fi
fi

# Success message
echo ""
echo "✅ Agent OS base installation has been completed."
echo ""

# Dynamic project installation command
PROJECT_SCRIPT="$INSTALL_DIR/setup/project.sh"
echo "--------------------------------"
echo ""
echo "To install Agent OS in a project, run:"
echo ""
echo "   cd <project-directory>"
echo "   $PROJECT_SCRIPT"
echo ""
echo "--------------------------------"
echo ""
echo "📍 Base installation files installed to:"
echo "   $INSTALL_DIR/instructions/      - Agent OS instructions"
echo "   $INSTALL_DIR/standards/         - Development standards"
echo "   $INSTALL_DIR/commands/          - Command templates"
echo "   $INSTALL_DIR/config.yml         - Configuration"
echo "   $INSTALL_DIR/setup/project.sh   - Project installation script"

if [ "$CLAUDE_CODE" = true ]; then
    echo "   $INSTALL_DIR/claude-code/agents/ - Claude Code agent templates"
fi
if [ "$GITHUB_COPILOT" = true ]; then
    echo "   $INSTALL_DIR/github-copilot-prompts/ - GitHub Copilot prompt templates"
fi

echo ""
echo "--------------------------------"
echo ""
echo "Next steps:"
echo ""
echo "1. Customize your standards in $INSTALL_DIR/standards/"
echo ""
echo "2. Configure project types in $INSTALL_DIR/config.yml"
echo ""
echo "3. Navigate to a project directory and run: $PROJECT_SCRIPT"
echo ""
echo "--------------------------------"
echo ""
echo "Refer to the official Agent OS docs at:"
echo "https://buildermethods.com/agent-os"
echo ""
echo "Keep building! 🚀"
echo ""
echo
