#!/usr/bin/env bash
# ABOUTME: Installs hindsight default lenses and creates user directories.
# ABOUTME: Safe to re-run — does not overwrite existing user lenses.

set -euo pipefail

HINDSIGHT_DIR="${HOME}/.claude/hindsight"
LENSES_DIR="${HINDSIGHT_DIR}/lenses"
REPORTS_DIR="${HINDSIGHT_DIR}/reports"

# Find the plugin's lenses directory (relative to this script)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLUGIN_LENSES_DIR="${SCRIPT_DIR}/../lenses"

echo "Installing hindsight..."

# Create directories
mkdir -p "$LENSES_DIR"
mkdir -p "$REPORTS_DIR"
echo "  Created ${LENSES_DIR}"
echo "  Created ${REPORTS_DIR}"

# Copy default lenses (skip existing to preserve customizations)
if [[ -d "$PLUGIN_LENSES_DIR" ]]; then
  for lens_file in "$PLUGIN_LENSES_DIR"/*.md; do
    [[ -f "$lens_file" ]] || continue
    lens_name=$(basename "$lens_file")
    if [[ -f "${LENSES_DIR}/${lens_name}" ]]; then
      echo "  Skipped ${lens_name} (already exists, preserving customizations)"
    else
      cp "$lens_file" "${LENSES_DIR}/${lens_name}"
      echo "  Installed ${lens_name}"
    fi
  done
else
  echo "  Warning: No default lenses found at ${PLUGIN_LENSES_DIR}"
fi

echo ""
echo "Installation complete!"
echo "  Lenses: ${LENSES_DIR}"
echo "  Reports: ${REPORTS_DIR}"
echo ""
echo "Usage:"
echo "  Interactive: /hindsight today standup"
echo "  Headless:    claude -p \"use the hindsight skill for today with the standup lens\""
