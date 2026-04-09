#!/usr/bin/env bash
set -euo pipefail

# Paperclip-UAW Recovery Script
# Rebuilds ~/.paperclip state from version-controlled repo files.
#
# Usage:
#   ./paperclip-uaw/recover.sh
#
# What this does:
#   1. Starts Paperclip (creates fresh DB, runs all migrations)
#   2. Imports all company packages from companies/
#   3. Syncs pipeline configs from pipelines/ to ~/.paperclip/pipelines/
#
# What this does NOT recover:
#   - Run history (agent logs, token counts, costs)
#   - Issue state (tasks, comments, approvals)
#   - Workspace attachments (must be re-attached manually per project)
#
# Prerequisites:
#   - Paperclip repo at the working directory
#   - pnpm installed, dependencies installed (pnpm install)

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

echo "Paperclip-UAW Recovery"
echo "Repo: $REPO_DIR"
echo ""

# ─── Step 1: Check prerequisites ─────────────────────────────

echo "Step 1: Checking prerequisites..."

if [ ! -f "$REPO_DIR/package.json" ]; then
  echo "Error: Not in the paperclip repo. Run from the repo root."
  exit 1
fi

if ! command -v pnpm &>/dev/null; then
  echo "Error: pnpm not found. Install it first."
  exit 1
fi

echo "  OK"
echo ""

# ─── Step 2: Start Paperclip (fresh DB + migrations) ─────────

echo "Step 2: Starting Paperclip to initialize fresh database..."
echo "  (This applies all migrations and starts the server)"
echo ""

# Start in background, wait for health
cd "$REPO_DIR"
pnpm dev &
DEV_PID=$!

# Wait for server to be healthy (up to 60 seconds)
ATTEMPTS=0
MAX_ATTEMPTS=30
while [ $ATTEMPTS -lt $MAX_ATTEMPTS ]; do
  if curl -s -o /dev/null "http://localhost:3100/api/health" 2>/dev/null; then
    echo "  Paperclip is running."
    break
  fi
  ATTEMPTS=$((ATTEMPTS + 1))
  sleep 2
done

if [ $ATTEMPTS -eq $MAX_ATTEMPTS ]; then
  echo "Error: Paperclip did not start within 60 seconds."
  kill $DEV_PID 2>/dev/null || true
  exit 1
fi

echo ""

# ─── Step 3: Import company packages ─────────────────────────

echo "Step 3: Importing company packages..."

COMPANIES_DIR="$REPO_DIR/companies"
if [ -d "$COMPANIES_DIR" ]; then
  for company_dir in "$COMPANIES_DIR"/*/; do
    [ -d "$company_dir" ] || continue
    COMPANY_NAME="$(basename "$company_dir")"
    if [ -f "$company_dir/.paperclip.yaml" ]; then
      echo "  Importing $COMPANY_NAME..."
      pnpm paperclipai company import "$company_dir" --yes 2>&1 | grep -E '(Company|Agents|Projects|Warnings|URL)' | sed 's/^/    /'
      echo ""
    fi
  done
else
  echo "  No companies/ directory found — skipping."
fi

echo ""

# ─── Step 4: Sync pipeline configs ───────────────────────────

echo "Step 4: Syncing pipeline configs..."

"$SCRIPT_DIR/sync-pipelines.sh" | sed 's/^/  /'

echo ""

# ─── Step 5: Summary ─────────────────────────────────────────

echo "Recovery complete."
echo ""
echo "What was restored:"
echo "  - Fresh database with all migrations applied"
echo "  - Company packages imported (agents + projects created)"
echo "  - Pipeline configs synced to ~/.paperclip/pipelines/"
echo ""
echo "What still needs manual setup:"
echo "  - Workspace attachments for each project (see RUNBOOK.md Step 3)"
echo "  - Run healthcheck on each project: ./paperclip-uaw/healthcheck.sh <path> <slug>"
echo ""
echo "What is not recoverable:"
echo "  - Previous run history (logs, token counts, costs)"
echo "  - Previous issue state (tasks, comments, approvals)"
echo ""
echo "Paperclip is running at http://localhost:3100 (PID: $DEV_PID)"
echo "Press Ctrl+C to stop, or use 'kill $DEV_PID' later."
