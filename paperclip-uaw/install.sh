#!/usr/bin/env bash
set -euo pipefail

# Paperclip-UAW v1 Template Installer
# Copies UAW workflow files into a project directory and fills in placeholders.
#
# Usage:
#   ./paperclip-uaw/install.sh /path/to/project [project-name]
#
# If project-name is omitted, the directory basename is used.

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
TEMPLATES_DIR="$SCRIPT_DIR/templates"

if [ $# -lt 1 ]; then
  echo "Usage: $0 <target-directory> [project-name]"
  echo ""
  echo "Installs Paperclip-UAW v1 workflow files into a project directory."
  echo "Creates: CLAUDE.md, AGENTS.md, resume.md, decisions.md, specs/, archive/"
  echo ""
  echo "Examples:"
  echo "  $0 /path/to/my-project"
  echo "  $0 /path/to/my-project \"My Project\""
  exit 1
fi

TARGET_DIR="$1"
PROJECT_NAME="${2:-$(basename "$TARGET_DIR")}"

if [ ! -d "$TARGET_DIR" ]; then
  echo "Error: Target directory does not exist: $TARGET_DIR"
  exit 1
fi

# Check for existing UAW files
EXISTING=()
for f in CLAUDE.md AGENTS.md resume.md decisions.md; do
  [ -f "$TARGET_DIR/$f" ] && EXISTING+=("$f")
done

if [ ${#EXISTING[@]} -gt 0 ]; then
  echo "Warning: These UAW files already exist in $TARGET_DIR:"
  printf "  %s\n" "${EXISTING[@]}"
  echo ""
  read -p "Overwrite? [y/N] " -r
  if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Aborted."
    exit 0
  fi
fi

# Copy template files
echo "Installing Paperclip-UAW v1 into: $TARGET_DIR"
echo "Project name: $PROJECT_NAME"
echo ""

# Core files
for f in CLAUDE.md AGENTS.md resume.md decisions.md; do
  cp "$TEMPLATES_DIR/$f" "$TARGET_DIR/$f"
  echo "  copied $f"
done

# Specs directory with template
mkdir -p "$TARGET_DIR/specs"
cp "$TEMPLATES_DIR/specs/spec-template.md" "$TARGET_DIR/specs/spec-template.md"
echo "  created specs/spec-template.md"

# Archive directory
mkdir -p "$TARGET_DIR/archive"
echo "  created archive/"

# Replace {{PROJECT_NAME}} placeholders
if [[ "$OSTYPE" == "darwin"* ]]; then
  # macOS sed requires '' after -i
  sed -i '' "s/{{PROJECT_NAME}}/$PROJECT_NAME/g" "$TARGET_DIR/resume.md"
  sed -i '' "s/{{PROJECT_NAME}}/$PROJECT_NAME/g" "$TARGET_DIR/decisions.md"
else
  sed -i "s/{{PROJECT_NAME}}/$PROJECT_NAME/g" "$TARGET_DIR/resume.md"
  sed -i "s/{{PROJECT_NAME}}/$PROJECT_NAME/g" "$TARGET_DIR/decisions.md"
fi
echo "  replaced {{PROJECT_NAME}} → $PROJECT_NAME"

echo ""
echo "Done. Next steps:"
echo "  1. Fill in resume.md with current project state"
echo "  2. Agents will read CLAUDE.md on startup and follow the UAW protocol"
echo "  3. Record architectural decisions in decisions.md as they happen"
