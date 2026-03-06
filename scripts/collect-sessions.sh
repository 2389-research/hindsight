#!/usr/bin/env bash
# ABOUTME: Collects Claude Code session JSONL files matching a date range.
# ABOUTME: Outputs a JSON manifest with session metadata for downstream analysis.

set -euo pipefail

usage() {
  echo "Usage: $0 <start-date> <end-date>"
  echo "  Dates in YYYY-MM-DD format"
  echo "  Outputs JSON manifest of matching session files to stdout"
  exit 1
}

if [[ $# -ne 2 ]]; then
  usage
fi

START_DATE="$1"
END_DATE="$2"

# Validate date format
if ! [[ "$START_DATE" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]] || ! [[ "$END_DATE" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]]; then
  echo "Error: Dates must be in YYYY-MM-DD format" >&2
  exit 1
fi

# Convert to comparable timestamps (start of start day, end of end day)
START_TS="${START_DATE}T00:00:00.000Z"
END_TS="${END_DATE}T23:59:59.999Z"

PROJECTS_DIR="${HOME}/.claude/projects"

if [[ ! -d "$PROJECTS_DIR" ]]; then
  echo "Error: Projects directory not found at $PROJECTS_DIR" >&2
  exit 1
fi

# Extract timestamp from a JSONL line, handling both top-level and nested timestamps
extract_timestamp() {
  echo "$1" | jq -r '.timestamp // .snapshot.timestamp // empty' 2>/dev/null
}

# Extract the first valid timestamp from first N lines of a file
get_first_timestamp() {
  local file="$1"
  local ts=""
  while IFS= read -r line; do
    ts=$(extract_timestamp "$line")
    if [[ -n "$ts" ]]; then
      echo "$ts"
      return
    fi
  done < <(head -n 5 "$file")
  echo ""
}

# Extract the last valid timestamp from last N lines of a file
get_last_timestamp() {
  local file="$1"
  local ts=""
  local last_ts=""
  while IFS= read -r line; do
    ts=$(extract_timestamp "$line")
    if [[ -n "$ts" ]]; then
      last_ts="$ts"
    fi
  done < <(tail -n 5 "$file")
  echo "$last_ts"
}

# Decode project path from directory name by reconstructing the real filesystem path.
# The encoding replaces "/" with "-", but directory names can also contain "-",
# so we resolve ambiguity by checking which paths actually exist on disk.
decode_project_path() {
  local encoded="$1"
  # Strip leading dash to get "Users-dylanr-work-2389-boba"
  local remaining="${encoded#-}"
  local current="/"

  while [[ -n "$remaining" ]]; do
    # Try progressively longer segments to find the longest match on disk
    local best_segment=""
    local best_rest=""
    local IFS='-'
    local parts=($remaining)
    unset IFS

    local found=false
    # Try from longest possible segment down to single part
    for (( i=${#parts[@]}; i>=1; i-- )); do
      local segment=""
      for (( j=0; j<i; j++ )); do
        if [[ -z "$segment" ]]; then
          segment="${parts[$j]}"
        else
          segment="${segment}-${parts[$j]}"
        fi
      done

      local candidate="${current%/}/${segment}"
      if [[ -e "$candidate" ]]; then
        best_segment="$segment"
        # Rebuild remaining from parts[i:]
        best_rest=""
        for (( j=i; j<${#parts[@]}; j++ )); do
          if [[ -z "$best_rest" ]]; then
            best_rest="${parts[$j]}"
          else
            best_rest="${best_rest}-${parts[$j]}"
          fi
        done
        found=true
        break
      fi
    done

    if [[ "$found" == true ]]; then
      current="${current%/}/${best_segment}"
      remaining="$best_rest"
    else
      # No filesystem match — use all remaining parts joined with hyphens as the final segment
      current="${current%/}/${remaining}"
      remaining=""
    fi
  done

  echo "$current"
}

# Extract project name (last path component) from decoded path
get_project_name() {
  local decoded="$1"
  basename "$decoded"
}

# Try to extract session slug from the file (from system entries)
get_session_slug() {
  local file="$1"
  # Look in last 20 lines for system entries with slug
  tail -n 20 "$file" | jq -r 'select(.type == "system") | .slug // empty' 2>/dev/null | head -n 1
}

# Build manifest
echo "["
first_entry=true

for project_dir in "$PROJECTS_DIR"/*/; do
  [[ -d "$project_dir" ]] || continue

  project_dirname=$(basename "$project_dir")
  project_path=$(decode_project_path "$project_dirname")
  project_name=$(get_project_name "$project_path")

  for jsonl_file in "$project_dir"*.jsonl; do
    [[ -f "$jsonl_file" ]] || continue

    # Skip empty files
    [[ -s "$jsonl_file" ]] || continue

    first_ts=$(get_first_timestamp "$jsonl_file")
    last_ts=$(get_last_timestamp "$jsonl_file")

    # Skip if we couldn't extract timestamps
    [[ -n "$first_ts" && -n "$last_ts" ]] || continue

    # Check if session overlaps with requested date range
    # Session overlaps if: session_start <= range_end AND session_end >= range_start
    if [[ "$first_ts" > "$END_TS" ]] || [[ "$last_ts" < "$START_TS" ]]; then
      continue
    fi

    file_bytes=$(wc -c < "$jsonl_file" | tr -d ' ')
    slug=$(get_session_slug "$jsonl_file")
    session_id=$(basename "$jsonl_file" .jsonl)

    if [[ "$first_entry" == "true" ]]; then
      first_entry=false
    else
      echo ","
    fi

    jq -n \
      --arg path "$jsonl_file" \
      --arg sessionId "$session_id" \
      --arg project "$project_name" \
      --arg projectPath "$project_path" \
      --arg slug "$slug" \
      --arg firstTimestamp "$first_ts" \
      --arg lastTimestamp "$last_ts" \
      --arg bytes "$file_bytes" \
      '{
        path: $path,
        sessionId: $sessionId,
        project: $project,
        projectPath: $projectPath,
        slug: $slug,
        firstTimestamp: $firstTimestamp,
        lastTimestamp: $lastTimestamp,
        bytes: ($bytes | tonumber)
      }'
  done
done

echo ""
echo "]"
