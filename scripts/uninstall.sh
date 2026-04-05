#!/usr/bin/env bash
# ABOUTME: Removes hindsight user directories after confirmation.
# ABOUTME: Does not remove the plugin itself, only user-generated data and config.

set -euo pipefail

HINDSIGHT_DIR="${HOME}/.claude/hindsight"

if [[ ! -d "$HINDSIGHT_DIR" ]]; then
  echo "Nothing to uninstall — ${HINDSIGHT_DIR} does not exist."
  exit 0
fi

echo "This will remove:"
echo "  ${HINDSIGHT_DIR}/lenses/ (your lens files, including customizations)"
echo "  ${HINDSIGHT_DIR}/reports/ (all generated reports)"
echo ""
read -p "Are you sure? (y/N) " -n 1 -r
echo ""

if [[ $REPLY =~ ^[Yy]$ ]]; then
  rm -rf "$HINDSIGHT_DIR"
  echo "Removed ${HINDSIGHT_DIR}"
else
  echo "Cancelled."
fi
