#!/bin/bash
#
# Install script for specialist-roster-query Cortex Code skill
#

set -e

SKILL_NAME="specialist-roster-query"
SKILL_DIR="$HOME/.cortex/skills/$SKILL_NAME"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "Installing $SKILL_NAME skill..."

# Create skills directory if it doesn't exist
mkdir -p "$SKILL_DIR"

# Copy the skill file
cp "$SCRIPT_DIR/SKILL.md" "$SKILL_DIR/SKILL.md"

echo "Installed to: $SKILL_DIR/SKILL.md"
echo ""
echo "Installation complete! Restart Cortex Code to use the skill."
echo "Try asking: \"who supports USMajors\""
