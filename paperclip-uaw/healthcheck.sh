#!/usr/bin/env bash
set -euo pipefail

# Paperclip-UAW v1 Health Check
# Checks project readiness and writes a status report for agents to ingest.
#
# Usage:
#   ./paperclip-uaw/healthcheck.sh <project-directory> [project-slug]
#
# Outputs:
#   - Console summary with [OK], [WARN], [MISS] indicators
#   - Writes .uaw-healthcheck.json to the project directory
#     (agents read this on session start to know what's incomplete)
#
# Exit codes:
#   0 — all checks passed
#   1 — warnings present (not blocking, but agent should note gaps)
#   2 — usage error

if [ $# -lt 1 ]; then
  echo "Usage: $0 <project-directory> [project-slug]"
  echo ""
  echo "Checks Paperclip-UAW configuration health for a project."
  echo "Writes .uaw-healthcheck.json for agent ingestion."
  echo ""
  echo "Examples:"
  echo "  $0 /path/to/project"
  echo "  $0 /path/to/project tflabs-poc"
  exit 2
fi

TARGET_DIR="$1"
PROJECT_SLUG="${2:-$(basename "$TARGET_DIR")}"

if [ ! -d "$TARGET_DIR" ]; then
  echo "Error: Directory does not exist: $TARGET_DIR"
  exit 2
fi

# Counters
OK_COUNT=0
WARN_COUNT=0
MISS_COUNT=0

# JSON arrays for the report
JSON_OK=()
JSON_WARN=()
JSON_MISS=()

check_ok() {
  local category="$1" item="$2" detail="$3"
  OK_COUNT=$((OK_COUNT + 1))
  echo "  [OK]   $item"
  JSON_OK+=("{\"category\":\"$category\",\"item\":\"$item\",\"detail\":\"$detail\"}")
}

check_warn() {
  local category="$1" item="$2" detail="$3"
  WARN_COUNT=$((WARN_COUNT + 1))
  echo "  [WARN] $item — $detail"
  JSON_WARN+=("{\"category\":\"$category\",\"item\":\"$item\",\"detail\":\"$detail\"}")
}

check_miss() {
  local category="$1" item="$2" detail="$3"
  MISS_COUNT=$((MISS_COUNT + 1))
  echo "  [MISS] $item — $detail"
  JSON_MISS+=("{\"category\":\"$category\",\"item\":\"$item\",\"detail\":\"$detail\"}")
}

echo "Paperclip-UAW Health Check"
echo "Project: $TARGET_DIR"
echo "Slug: $PROJECT_SLUG"
echo ""

# ─── UAW Contract Files ───────────────────────────────────────

echo "UAW Contract Files:"

for f in CLAUDE.md AGENTS.md; do
  if [ -f "$TARGET_DIR/$f" ]; then
    check_ok "uaw_files" "$f" "present"
  else
    check_miss "uaw_files" "$f" "missing — run ./paperclip-uaw/install.sh"
  fi
done

# resume.md — check for unfilled placeholders
if [ -f "$TARGET_DIR/resume.md" ]; then
  if grep -q '{{' "$TARGET_DIR/resume.md" 2>/dev/null; then
    check_warn "uaw_files" "resume.md" "has unfilled {{placeholders}} — fill in project state"
  else
    check_ok "uaw_files" "resume.md" "present and filled in"
  fi
else
  check_miss "uaw_files" "resume.md" "missing — run ./paperclip-uaw/install.sh"
fi

# decisions.md — check if it has any entries
if [ -f "$TARGET_DIR/decisions.md" ]; then
  # Count lines starting with ## (decision entries), skip the HTML comment template
  DECISION_COUNT=$(grep -c '^## [0-9]' "$TARGET_DIR/decisions.md" 2>/dev/null || true)
  if [ "$DECISION_COUNT" -eq 0 ]; then
    check_warn "uaw_files" "decisions.md" "exists but no decision entries yet"
  else
    check_ok "uaw_files" "decisions.md" "$DECISION_COUNT decision(s) recorded"
  fi
else
  check_miss "uaw_files" "decisions.md" "missing — run ./paperclip-uaw/install.sh"
fi

# specs/ directory
if [ -d "$TARGET_DIR/specs" ]; then
  SPEC_COUNT=$(find "$TARGET_DIR/specs" -name '*.md' ! -name 'spec-template.md' 2>/dev/null | wc -l | tr -d ' ')
  if [ "$SPEC_COUNT" -eq 0 ]; then
    check_ok "uaw_files" "specs/" "present (no active specs yet — normal for exploratory phase)"
  else
    check_ok "uaw_files" "specs/" "present with $SPEC_COUNT spec(s)"
  fi
else
  check_miss "uaw_files" "specs/" "missing — run ./paperclip-uaw/install.sh"
fi

# archive/ directory
if [ -d "$TARGET_DIR/archive" ]; then
  check_ok "uaw_files" "archive/" "present"
else
  check_warn "uaw_files" "archive/" "missing — create with: mkdir $TARGET_DIR/archive"
fi

echo ""

# ─── Project Setup ────────────────────────────────────────────

echo "Project Setup:"

# Git repo
if [ -d "$TARGET_DIR/.git" ]; then
  check_ok "project" "git repo" "initialized"
else
  check_warn "project" "git repo" "not initialized — codex agents will fail (run: git init)"
fi

# Pipeline config
PIPELINE_PATH="$HOME/.paperclip/pipelines/$PROJECT_SLUG.yaml"
if [ -f "$PIPELINE_PATH" ]; then
  check_ok "project" "pipeline config" "$PIPELINE_PATH"
else
  check_warn "project" "pipeline config" "missing at $PIPELINE_PATH — VentureLead needs this to dispatch stages"
fi

echo ""

# ─── Environment ──────────────────────────────────────────────

echo "Environment:"

if [ -n "${ANTHROPIC_API_KEY:-}" ]; then
  check_ok "environment" "ANTHROPIC_API_KEY" "set"
else
  check_warn "environment" "ANTHROPIC_API_KEY" "not set (needed for claude_local agents)"
fi

if [ -n "${OPENAI_API_KEY:-}" ]; then
  check_ok "environment" "OPENAI_API_KEY" "set"
else
  check_warn "environment" "OPENAI_API_KEY" "not set (needed for codex agents)"
fi

# Check if Paperclip is running
if curl -s -o /dev/null -w '' "http://localhost:3100/api/health" 2>/dev/null; then
  check_ok "environment" "Paperclip server" "running at localhost:3100"
else
  check_warn "environment" "Paperclip server" "not responding at localhost:3100"
fi

echo ""

# ─── Summary ──────────────────────────────────────────────────

TOTAL=$((OK_COUNT + WARN_COUNT + MISS_COUNT))
echo "Summary: $OK_COUNT ok, $WARN_COUNT warnings, $MISS_COUNT missing ($TOTAL checks)"

# ─── Write JSON report for agent ingestion ────────────────────

# Build JSON arrays
join_json() {
  local IFS=','
  echo "$*"
}

OK_JSON="[$(join_json "${JSON_OK[@]+"${JSON_OK[@]}"}" )]"
WARN_JSON="[$(join_json "${JSON_WARN[@]+"${JSON_WARN[@]}"}" )]"
MISS_JSON="[$(join_json "${JSON_MISS[@]+"${JSON_MISS[@]}"}" )]"

REPORT_PATH="$TARGET_DIR/.uaw-healthcheck.json"

cat > "$REPORT_PATH" << ENDJSON
{
  "generated": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "project": "$PROJECT_SLUG",
  "directory": "$TARGET_DIR",
  "summary": {
    "ok": $OK_COUNT,
    "warnings": $WARN_COUNT,
    "missing": $MISS_COUNT,
    "ready": $([ $MISS_COUNT -eq 0 ] && echo "true" || echo "false")
  },
  "ok": $OK_JSON,
  "warnings": $WARN_JSON,
  "missing": $MISS_JSON
}
ENDJSON

echo ""
echo "Report written to: $REPORT_PATH"
echo "(Agents read this file on session start to detect configuration gaps)"

# Exit with appropriate code
if [ $WARN_COUNT -gt 0 ] || [ $MISS_COUNT -gt 0 ]; then
  exit 1
else
  exit 0
fi
