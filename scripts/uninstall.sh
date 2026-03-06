#!/usr/bin/env bash
# ABOUTME: Removes cc-review user directories after confirmation.
# ABOUTME: Does not remove the plugin itself, only user-generated data and config.

set -euo pipefail

CC_REVIEW_DIR="${HOME}/.claude/cc-review"

if [[ ! -d "$CC_REVIEW_DIR" ]]; then
  echo "Nothing to uninstall — ${CC_REVIEW_DIR} does not exist."
  exit 0
fi

echo "This will remove:"
echo "  ${CC_REVIEW_DIR}/lenses/ (your lens files, including customizations)"
echo "  ${CC_REVIEW_DIR}/reports/ (all generated reports)"
echo ""
read -p "Are you sure? (y/N) " -n 1 -r
echo ""

if [[ $REPLY =~ ^[Yy]$ ]]; then
  rm -rf "$CC_REVIEW_DIR"
  echo "Removed ${CC_REVIEW_DIR}"
else
  echo "Cancelled."
fi
