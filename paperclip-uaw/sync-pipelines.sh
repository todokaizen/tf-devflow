#!/usr/bin/env bash
set -euo pipefail

# Sync pipeline configs from repo to ~/.paperclip/pipelines/
#
# Usage:
#   ./paperclip-uaw/sync-pipelines.sh
#
# Copies all .yaml files from pipelines/ to ~/.paperclip/pipelines/.
# Changes take effect on the next VentureLead heartbeat.

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
SOURCE_DIR="$REPO_DIR/pipelines"
TARGET_DIR="$HOME/.paperclip/pipelines"

if [ ! -d "$SOURCE_DIR" ]; then
  echo "Error: No pipelines/ directory found in repo at $SOURCE_DIR"
  exit 1
fi

mkdir -p "$TARGET_DIR"

COUNT=0
for f in "$SOURCE_DIR"/*.yaml; do
  [ -f "$f" ] || continue
  BASENAME="$(basename "$f")"
  cp "$f" "$TARGET_DIR/$BASENAME"
  echo "  synced $BASENAME"
  COUNT=$((COUNT + 1))
done

if [ "$COUNT" -eq 0 ]; then
  echo "No .yaml files found in $SOURCE_DIR"
else
  echo ""
  echo "Synced $COUNT pipeline config(s) to $TARGET_DIR"
  echo "Changes take effect on next VentureLead heartbeat."
fi
