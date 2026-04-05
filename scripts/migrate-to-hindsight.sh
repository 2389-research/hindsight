#!/usr/bin/env bash
# ABOUTME: One-time migration script to rename cc-review to hindsight.
# ABOUTME: Moves user data dir, session log dir, and repo dir.

set -euo pipefail

echo "=== Migrating cc-review → hindsight ==="
echo ""

# 1. Move user data directory
CC_REVIEW_DIR="${HOME}/.claude/cc-review"
HINDSIGHT_DIR="${HOME}/.claude/hindsight"

if [[ -d "$CC_REVIEW_DIR" ]]; then
  if [[ -d "$HINDSIGHT_DIR" ]]; then
    echo "ERROR: Both ${CC_REVIEW_DIR} and ${HINDSIGHT_DIR} exist. Resolve manually."
    exit 1
  fi
  mv "$CC_REVIEW_DIR" "$HINDSIGHT_DIR"
  echo "Moved ${CC_REVIEW_DIR} → ${HINDSIGHT_DIR}"
else
  echo "  Skipped user data dir (${CC_REVIEW_DIR} does not exist)"
fi

# 2. Move session log directory
OLD_SESSIONS="${HOME}/.claude/projects/-Users-dylanr-work-2389-cc-review"
NEW_SESSIONS="${HOME}/.claude/projects/-Users-dylanr-work-2389-hindsight"

if [[ -d "$OLD_SESSIONS" ]]; then
  if [[ -d "$NEW_SESSIONS" ]]; then
    echo "ERROR: Both session dirs exist. Resolve manually."
    exit 1
  fi
  mv "$OLD_SESSIONS" "$NEW_SESSIONS"
  echo "Moved session logs → ${NEW_SESSIONS}"
else
  echo "  Skipped session logs (${OLD_SESSIONS} does not exist)"
fi

# 3. Move repo directory
OLD_REPO="/Users/dylanr/work/2389/cc-review"
NEW_REPO="/Users/dylanr/work/2389/hindsight"

if [[ -d "$OLD_REPO" ]]; then
  if [[ -d "$NEW_REPO" ]]; then
    echo "ERROR: Both repo dirs exist. Resolve manually."
    exit 1
  fi
  mv "$OLD_REPO" "$NEW_REPO"
  echo "Moved repo → ${NEW_REPO}"
else
  echo "  Skipped repo dir (${OLD_REPO} does not exist)"
fi

echo ""
echo "=== Migration complete ==="
echo ""
echo "Manual steps remaining:"
echo "  1. Update ~/.claude/settings.json:"
echo "     - Change 'cc-review@cc-review-dev' → 'hindsight@hindsight-dev'"
echo "     - Change 'cc-review-dev' → 'hindsight-dev'"
echo "     - Update path to /Users/dylanr/work/2389/hindsight"
echo "  2. cd /Users/dylanr/work/2389/hindsight"
echo "  3. Delete plugin cache: rm -rf ~/.claude/plugins/cache/cc-review-dev"
