<!-- ABOUTME: Implementation plan for renaming cc-review to hindsight. -->
<!-- ABOUTME: Covers migration script, codebase find-and-replace, and session log dir rename. -->

# Rename cc-review → hindsight Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Rename the cc-review plugin to "hindsight" across all code, config, scripts, docs, user directories, and session log paths.

**Architecture:** A migration script handles the three directory moves (repo dir, user data dir, session log dir). Then a codebase-wide find-and-replace updates all string references. Finally, config and identity files are updated manually where the replacement is structural (JSON, frontmatter), not just string substitution.

**Tech Stack:** Bash (migration script), sed-style find-and-replace via Edit tool, manual JSON edits.

---

### Task 1: Write the migration script

**Files:**
- Create: `scripts/migrate-to-hindsight.sh`

**Step 1: Write the script**

```bash
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
  echo "✓ Moved ${CC_REVIEW_DIR} → ${HINDSIGHT_DIR}"
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
  echo "✓ Moved session logs → ${NEW_SESSIONS}"
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
  echo "✓ Moved repo → ${NEW_REPO}"
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
```

**Step 2: Make it executable**

Run: `chmod +x scripts/migrate-to-hindsight.sh`

**Step 3: Commit**

```bash
git add scripts/migrate-to-hindsight.sh
git commit -m "feat: add migration script for cc-review → hindsight rename"
```

---

### Task 2: Update plugin identity files

**Files:**
- Modify: `.claude-plugin/plugin.json`
- Modify: `.claude-plugin/marketplace.json`

**Step 1: Update plugin.json**

Change `"name": "cc-review"` → `"name": "hindsight"`
Change description to: `"Analyze Claude Code sessions through configurable lenses. Past performance is not a guarantee of future results. Unless you measure it."`

**Step 2: Update marketplace.json**

Change `"name": "cc-review-dev"` → `"name": "hindsight-dev"`
Change inner plugin name `"name": "cc-review"` → `"name": "hindsight"`

**Step 3: Commit**

```bash
git add .claude-plugin/plugin.json .claude-plugin/marketplace.json
git commit -m "feat: rename plugin identity from cc-review to hindsight"
```

---

### Task 3: Rename and update the main skill

**Files:**
- Move: `skills/cc-review/SKILL.md` → `skills/hindsight/SKILL.md`
- Modify: `skills/hindsight/SKILL.md` (all `cc-review` refs → `hindsight`)

**Step 1: Move the skill directory**

Run: `mkdir -p skills/hindsight && mv skills/cc-review/SKILL.md skills/hindsight/SKILL.md && rmdir skills/cc-review`

**Step 2: Update all references in SKILL.md**

Replace all occurrences:
- `cc-review` → `hindsight` (in text, paths, commands, directory names)
- `CC Review` → `Hindsight` (title)
- `# CC Review — Session Log Analyzer` → `# Hindsight — Session Log Analyzer`
- `~/.claude/cc-review/` → `~/.claude/hindsight/` (all path references)
- `.claude/cc-review/` → `.claude/hindsight/` (project-scoped path references)
- `/cc-review` → `/hindsight` (command invocation examples)
- Frontmatter `name: cc-review` → `name: hindsight`

**Step 3: Commit**

```bash
git add skills/cc-review/ skills/hindsight/
git commit -m "feat: rename main skill from cc-review to hindsight"
```

---

### Task 4: Rename and update the lens-writing skill

**Files:**
- Move: `skills/lens-writing/SKILL.md` → `skills/hindsight:lens-writing/SKILL.md`
- Modify: `skills/hindsight:lens-writing/SKILL.md` (all `cc-review` refs → `hindsight`)

**Step 1: Move the skill directory**

Run: `mkdir -p "skills/hindsight:lens-writing" && mv skills/lens-writing/SKILL.md "skills/hindsight:lens-writing/SKILL.md" && rmdir skills/lens-writing`

**Step 2: Update all references in SKILL.md**

Replace all occurrences:
- `cc-review` → `hindsight` (in text, paths, commands)
- `~/.claude/cc-review/` → `~/.claude/hindsight/` (all paths)
- `.claude/cc-review/` → `.claude/hindsight/` (project-scoped paths)
- `/cc-review` → `/hindsight` (command references)
- `# Lens Writing — Create & Evaluate cc-review Lenses` → `# Lens Writing — Create & Evaluate Hindsight Lenses`
- ABOUTME comment: `cc-review lenses` → `hindsight lenses`
- Description: `cc-review lenses` → `hindsight lenses`

**Step 3: Commit**

```bash
git add skills/lens-writing/ "skills/hindsight:lens-writing/"
git commit -m "feat: rename lens-writing skill to hindsight:lens-writing"
```

---

### Task 5: Update scripts

**Files:**
- Modify: `scripts/install.sh`
- Modify: `scripts/uninstall.sh`

**Step 1: Update install.sh**

Replace all occurrences:
- `cc-review` → `hindsight` (in ABOUTME, variable names, echo statements, paths)
- `CC_REVIEW_DIR` → `HINDSIGHT_DIR`
- `/cc-review` → `/hindsight` (command examples)

**Step 2: Update uninstall.sh**

Replace all occurrences:
- `cc-review` → `hindsight` (in ABOUTME, variable names, echo statements, paths)
- `CC_REVIEW_DIR` → `HINDSIGHT_DIR`

**Step 3: Commit**

```bash
git add scripts/install.sh scripts/uninstall.sh
git commit -m "feat: update install/uninstall scripts for hindsight rename"
```

---

### Task 6: Update CLAUDE.md and docs

**Files:**
- Modify: `CLAUDE.md`
- Modify: `docs/backlog.md`

**Step 1: Update CLAUDE.md**

Replace all `cc-review` → `hindsight`:
- Title: `# CC Review Plugin` → `# Hindsight`
- Description: `the \`cc-review\` skill` → `the \`hindsight\` skill`
- Commands: `/cc-review` → `/hindsight`

**Step 2: Update backlog.md**

Replace all `cc-review` → `hindsight` in ABOUTME comments, title, and body text.

**Step 3: Do NOT update historical design/implementation docs**

The files in `docs/plans/2026-03-05-cc-review-*` and `docs/plans/2026-03-25-lens-writing-*`
are historical records. They document what was built at the time and should keep their
original references. Do not modify them.

**Step 4: Commit**

```bash
git add CLAUDE.md docs/backlog.md
git commit -m "docs: update CLAUDE.md and backlog for hindsight rename"
```

---

### Task 7: Run the migration script

This task must be run AFTER all code changes are committed, because the script
moves the repo directory.

**Step 1: Verify all changes are committed**

Run: `git status`
Expected: clean working tree

**Step 2: Run the migration script**

Run: `bash scripts/migrate-to-hindsight.sh`

Expected output:
```
=== Migrating cc-review → hindsight ===

✓ Moved /Users/dylanr/.claude/cc-review → /Users/dylanr/.claude/hindsight
✓ Moved session logs → /Users/dylanr/.claude/projects/-Users-dylanr-work-2389-hindsight
✓ Moved repo → /Users/dylanr/work/2389/hindsight

=== Migration complete ===
```

**Step 3: cd into the new repo location**

Run: `cd /Users/dylanr/work/2389/hindsight`

**Step 4: Verify git still works**

Run: `git log --oneline -3`
Expected: recent commits visible, repo intact

---

### Task 8: Update Claude settings

**Files:**
- Modify: `~/.claude/settings.json`

**Step 1: Update the settings file**

Three changes needed:
1. `"cc-review@cc-review-dev": true` → `"hindsight@hindsight-dev": true`
2. `"cc-review-dev": {` → `"hindsight-dev": {`
3. `"path": "/Users/dylanr/work/2389/cc-review"` → `"path": "/Users/dylanr/work/2389/hindsight"`

**Step 2: Delete stale plugin cache**

Run: `rm -rf ~/.claude/plugins/cache/cc-review-dev`

**Step 3: Verify**

The plugin should reload on next Claude Code session start. No commit needed — settings.json is not in the repo.

---

### Task 9: Verify everything works

**Step 1: Check directory structure**

Run:
```bash
ls ~/.claude/hindsight/lenses/
ls ~/.claude/hindsight/reports/
ls ~/.claude/hindsight/evaluations/
ls ~/.claude/projects/-Users-dylanr-work-2389-hindsight/
```

All should exist with migrated content.

**Step 2: Check old directories are gone**

Run:
```bash
ls ~/.claude/cc-review 2>/dev/null && echo "ERROR: old dir still exists" || echo "OK: old dir removed"
ls ~/.claude/projects/-Users-dylanr-work-2389-cc-review 2>/dev/null && echo "ERROR: old sessions still exist" || echo "OK: old sessions removed"
```

**Step 3: Verify no remaining cc-review references in active code**

Run from repo root:
```bash
grep -r "cc-review" --include="*.md" --include="*.json" --include="*.sh" . \
  --exclude-dir=docs/plans | grep -v "2026-03-05\|2026-03-25\|2026-04-05-rename"
```

Expected: no results (only historical plan docs should contain cc-review).
