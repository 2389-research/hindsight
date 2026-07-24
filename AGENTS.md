# Hindsight — Agent Guide

## If You Encountered Hindsight in Another Project

Hindsight is a Claude Code plugin for analyzing session logs. If you see `/hindsight` in a conversation or a `.claude/hindsight/` directory in a project, here's what you need to know:

- **`/hindsight <date-range> <lens>`** runs a session analysis pipeline. It reads session logs via ccvault or agentsview (auto-detected), extracts summaries, and produces a report through a configurable lens.
- **`/hindsight:lens-writing`** is a subskill for creating and evaluating lenses.
- **`~/.claude/hindsight/lenses/`** contains user-global lens files. **`<project>/.claude/hindsight/lenses/`** contains project-scoped lenses.
- **`~/.claude/hindsight/reports/`** contains generated reports organized by date range and lens name.
- **`~/.claude/hindsight/evaluations/`** contains lens evaluation artifacts from the lens-writing skill.

You do not need to understand hindsight's internals to use it. Invoke the skill and it handles the rest.

## If You Are Developing Hindsight

### Project Structure

```text
hindsight/
├── .claude-plugin/
│   ├── plugin.json              # Plugin identity (name, version, skill path)
│   └── marketplace.json         # Dev marketplace config
├── skills/
│   ├── hindsight/
│   │   └── SKILL.md             # Main orchestrator — the five-phase pipeline
│   ├── hindsight:lens-writing/
│   │   └── SKILL.md             # Lens creation and evaluation subskill
│   └── shared/
│       ├── extraction-prompt.md  # Prompt template for per-session subagents
│       └── session-summary-schema.md  # Standardized summary format
├── lenses/                       # Default lenses shipped with the plugin
│   ├── standup.md
│   ├── knowledge-extraction.md
│   ├── workflow-optimization.md
│   ├── content-mining.md
│   ├── agent-autonomy.md
│   └── skill-review.md
├── scripts/
│   ├── install.sh                # Creates user dirs, copies default lenses
│   ├── uninstall.sh              # Removes user dirs after confirmation
│   └── migrate-to-hindsight.sh   # One-time migration from cc-review
├── docs/
│   ├── backlog.md                # Deferred work items
│   └── plans/                    # Design and implementation docs
├── CLAUDE.md                     # Dev conventions for this repo
├── AGENTS.md                     # This file
└── README.md                     # Human-facing docs
```

### How the Plugin System Works

Claude Code plugins are defined by `.claude-plugin/plugin.json`, which points to a skills directory. Each skill is a `SKILL.md` file with YAML frontmatter (name, description, args) and markdown instructions that Claude follows when the skill is invoked.

- **`plugin.json`** declares the plugin name, version, and skills path.
- **`marketplace.json`** registers the plugin with a marketplace (or local dev directory) so Claude Code can discover it.
- Skills are loaded by name. `hindsight` maps to `skills/hindsight/SKILL.md`. The colon-namespaced `hindsight:lens-writing` maps to `skills/hindsight:lens-writing/SKILL.md`.

### The Layer System

The pipeline has four layers. Know which layer you're modifying:

| Layer | File | What It Controls |
| ------- | ------ | ----------------- |
| 1 | `skills/shared/session-summary-schema.md` | Fields in every session summary |
| 2 | `skills/shared/extraction-prompt.md` | How subagents read sessions via the configured source |
| 3 | Lens `## Extraction Hints` | Extra data a specific lens needs per-session |
| 4 | Lens `## Analysis Instructions` | How the final report is synthesized |

**Layers 1-2 are core.** Changes here affect every lens. Test against multiple lenses before modifying. These are not lens-level concerns — if a lens needs something that layer 1-2 doesn't provide, that's a core contribution with a higher bar.

**Layers 3-4 are lens-scoped.** Each lens controls its own extraction hints and analysis instructions. Changes here only affect that lens.

### Pipeline Phases

The main skill (`skills/hindsight/SKILL.md`) orchestrates five phases:

0. **Interpret & Validate** — Parse input into date range + lens. Resolve natural language. Confirm interpretation with user.
1. **Collect Sessions** — Query the available source(s) for sessions in the date range. If both ccvault and agentsview are installed, results are merged and deduplicated by session ID. See `skills/shared/sources.md` for per-source CLI contracts.
2. **Load Lens** — Read the lens file, extract analysis instructions and extraction hints.
3. **Extract Summaries** — Dispatch parallel subagents (batches of 5) to produce standardized summaries. Results are cached in `~/.claude/hindsight/reports/<date-range>/summaries/`.
4. **Cross-Cutting Analysis** — Apply the lens to all summaries and produce the final report.
5. **Write Report** — Save to `~/.claude/hindsight/reports/<date-range>/<lens-name>.md`.

### Session Source Dependency

Hindsight reads session data through one of two interchangeable local-first tools: [ccvault](https://github.com/2389-research/ccvault) or agentsview. Phase 0 auto-detects which is installed at runtime; if both are present, Phase 1 queries both and merges the results (deduped by session ID). The canonical per-source CLI contracts live in `skills/shared/sources.md`.

Do not attempt to read session JSONL files directly. Always go through the configured source.

### Where to Modify What

| I want to... | Modify |
| -------------- | -------- |
| Change what data every summary contains | `skills/shared/session-summary-schema.md` (layer 1) |
| Change how subagents read sessions | `skills/shared/extraction-prompt.md` (layer 2) |
| Add a new default lens | `lenses/<name>.md` + `scripts/install.sh` |
| Change how a lens analyzes data | The lens file's Analysis Instructions (layer 4) |
| Change what extra data a lens extracts | The lens file's Extraction Hints (layer 3) |
| Change the pipeline orchestration | `skills/hindsight/SKILL.md` |
| Change the lens creation/evaluation workflow | `skills/hindsight:lens-writing/SKILL.md` |
| Add a new skill to the plugin | Create `skills/<name>/SKILL.md`, no config changes needed |

### Conventions

- All code files start with a two-line `ABOUTME:` comment explaining what the file does.
- No mock implementations. The pipeline runs against real session data via the configured source.
- Lens files use the format documented in the [lens-writing skill](skills/hindsight:lens-writing/SKILL.md).
- Design docs go in `docs/plans/YYYY-MM-DD-<topic>-design.md`. Implementation plans go in `docs/plans/YYYY-MM-DD-<topic>-implementation.md`.
