<!-- ABOUTME: Design doc for renaming cc-review to hindsight. -->
<!-- ABOUTME: Covers naming rationale, vocabulary, invocation patterns, and file structure changes. -->

# Rename cc-review → hindsight

## Name

**hindsight**

**Tagline:** *Past performance is not a guarantee of future results. Unless you measure it.*

**Description:** Analyze your Claude Code sessions through configurable lenses.

## Rationale

"cc-review" is a generic internal name that doesn't convey what the tool does or
why you'd use it. For a public skill, the name needs to:

1. Be immediately understandable to someone who's never seen it
2. Convey that it's retrospective (analyzing past sessions)
3. Convey that it offers multiple perspectives (lenses), not a single view
4. Work naturally in both command syntax and conversation

"Hindsight" carries the retrospective angle ("looking back at what happened")
and implies clarity ("hindsight is 20/20"). The lens metaphor fits naturally
within it — you look back through different lenses to see different things.

The tagline plays on the financial disclaimer: past performance doesn't
guarantee future results — unless you actually measure and learn from it.
That's the tool's value prop in one line.

## Vocabulary

These terms are established and do not change:

| Term | Meaning |
|------|---------|
| **Lens** | An analytical perspective applied to session data |
| **Report** | The output of running a lens against sessions |
| **Evaluation** | A quality assessment of a lens using persona judges |
| **Summary** | A standardized per-session extraction (intermediate format) |
| **Session** | A Claude Code conversation from ccvault |
| **Extraction** | Pulling structured data from raw session logs |
| **Extraction Hints** | Lens-specific signals to capture per-session |
| **Analysis Instructions** | Lens-specific aggregation and output rules |

## Invocation Patterns

| Pattern | Example |
|---------|---------|
| Slash command | `/hindsight autonomy yesterday` |
| Natural language | "let's do a hindsight on last week" |
| Headless CLI | `claude -p "hindsight on last week with the standup lens"` |
| Lens authoring | `/hindsight:lens-writing` |
| Lens evaluation | `/hindsight:lens-evaluation` |
| No args | `/hindsight` → prompts for lens and date range |

## File Structure Changes

### Plugin identity

| File | Change |
|------|--------|
| `.claude-plugin/plugin.json` | `name: "cc-review"` → `name: "hindsight"` |
| `.claude-plugin/marketplace.json` | `name: "cc-review-dev"` → `name: "hindsight-dev"`, plugin ref updated |

### Skills

| From | To |
|------|-----|
| `skills/cc-review/` | `skills/hindsight/` |
| `skills/cc-review/SKILL.md` | `skills/hindsight/SKILL.md` (name field + all internal refs) |
| `skills/lens-writing/` | `skills/hindsight:lens-writing/` |
| `skills/lens-writing/SKILL.md` | `skills/hindsight:lens-writing/SKILL.md` (refs updated) |

### Scripts

| File | Change |
|------|--------|
| `scripts/install.sh` | All `cc-review` path refs → `hindsight` |
| `scripts/uninstall.sh` | All `cc-review` path refs → `hindsight` |

### User installation directory

| From | To |
|------|-----|
| `~/.claude/cc-review/` | `~/.claude/hindsight/` |
| `~/.claude/cc-review/lenses/` | `~/.claude/hindsight/lenses/` |
| `~/.claude/cc-review/reports/` | `~/.claude/hindsight/reports/` |
| `~/.claude/cc-review/evaluations/` | `~/.claude/hindsight/evaluations/` |

### Documentation

| File | Change |
|------|--------|
| `CLAUDE.md` | All `cc-review` refs → `hindsight` |
| `docs/backlog.md` | All `cc-review` refs → `hindsight` |
| Lens files (ABOUTME comments, if any reference cc-review) | Updated |

### Settings (user action required)

| From | To |
|------|-----|
| `cc-review@cc-review-dev` in settings.json | `hindsight@hindsight-dev` |
| `cc-review-dev` path entry | `hindsight-dev` path entry |

### Plugin cache (auto-regenerated)

| From | To |
|------|-----|
| `~/.claude/plugins/cache/cc-review-dev/` | Regenerated on next plugin load |

## What Does NOT Change

- Lens file format (frontmatter, ABOUTME comments, sections)
- Report content and structure
- Evaluation structure (personas, synthesis, snapshots)
- Summary schema
- Extraction prompt template
- The 5-phase pipeline architecture
- ccvault MCP dependency
- Any report or evaluation content already generated (historical data stays in place)

## Migration for Existing Users

The `install.sh` script should handle migration:

1. If `~/.claude/cc-review/` exists and `~/.claude/hindsight/` does not, move it
2. Update any symlinks or references
3. Print a message about updating settings.json

## Open Questions

- Should the repo directory itself rename from `/Users/dylanr/work/2389/cc-review` to
  `/Users/dylanr/work/2389/hindsight`? (Not strictly necessary — the repo dir
  doesn't affect the plugin identity — but cleaner.)
- Should historical reports/evaluations in `~/.claude/cc-review/` be moved to
  `~/.claude/hindsight/` or left in place with a note?
