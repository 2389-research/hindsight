# Hindsight

Analyze your Claude Code sessions through configurable lenses. *Past performance is not a guarantee of future results. Unless you measure it.*

## Quick Start

If you already know [Claude Code plugins](https://docs.anthropic.com/en/docs/claude-code/plugins):

```bash
# Install the plugin (from the 2389-Research marketplace or local dev)
# Then run the install script to set up user directories and default lenses:
bash <plugin-root>/scripts/install.sh

# Use it
/hindsight today standup
/hindsight last-week knowledge-extraction
```

## What Is This?

Hindsight is a [Claude Code plugin](https://docs.anthropic.com/en/docs/claude-code/plugins) that reads your session logs and produces structured reports through configurable **lenses** — analysis perspectives that control what gets extracted and how it gets summarized.

It works by:

1. Finding sessions in a date range via [ccvault](https://github.com/2389-research/ccvault) (a session log manager)
2. Dispatching parallel subagents to extract standardized summaries from each session
3. Applying a lens's analysis instructions to produce a cross-cutting report
4. Writing the report to `~/.claude/hindsight/reports/`

### Prerequisites

- **Claude Code** with plugin support
- **ccvault** installed and synced (`brew install 2389-research/tap/ccvault && ccvault sync`)

### Installation

```bash
# After adding the plugin to your Claude Code settings:
bash <plugin-root>/scripts/install.sh
```

This creates `~/.claude/hindsight/lenses/` and `~/.claude/hindsight/reports/`, and copies the default lenses into place. Safe to re-run — it won't overwrite customized lenses.

### Uninstallation

```bash
bash <plugin-root>/scripts/uninstall.sh
```

Removes `~/.claude/hindsight/` (lenses, reports, evaluations) after confirmation. Does not remove the plugin itself.

## Usage

**Interactive** (inside Claude Code):

```
/hindsight today standup
/hindsight yesterday knowledge-extraction
/hindsight last-week workflow-optimization
/hindsight 2026-03-01:2026-03-05 content-mining
```

**Headless** (from your terminal):

```bash
claude -p "use hindsight for today with the standup lens"
claude -p "use hindsight for last week with the knowledge-extraction lens"
```

**Natural language** works too:

```
/hindsight what did I work on this past week?
/hindsight summarize yesterday
/hindsight what knowledge can we extract from the last 3 days?
```

If no lens is specified, hindsight defaults to `standup`. If input is ambiguous, it asks for clarification.

## Built-in Lenses

| Lens | Description |
|------|-------------|
| `standup` | Daily standup summary — what was done, what's next, blockers. Groups by project. |
| `knowledge-extraction` | Extract reusable learnings, patterns, and prescriptive rules from session activity |
| `workflow-optimization` | Identify workflow inefficiencies, collaboration gaps, and operational friction |
| `content-mining` | Surface blog posts, social media content, and announcements from session activity |
| `agent-autonomy` | Treat every human message as a system failure. Interrogate each one. Build a plan to eliminate all of them. |
| `skill-review` | Audit skill usage, diagnose missed triggers, and specify new skill candidates |

Lenses live in `~/.claude/hindsight/lenses/`. You can also scope lenses to a project by placing them in `<project-root>/.claude/hindsight/lenses/` — project lenses take precedence on name collisions.

## Architecture

Hindsight runs a five-phase pipeline orchestrated by the main skill:

1. **Phase 0 — Interpret & Validate**: Parse the user's input into a date range and lens. Resolve natural language dates. Match intent to available lenses.

2. **Phase 1 — Collect Sessions**: Query ccvault for sessions in the date range. Supports MCP tools or CLI fallback.

3. **Phase 2 — Load Lens**: Read the lens file, extract analysis instructions and any extraction hints that should be passed to subagents.

4. **Phase 3 — Extract Summaries**: Dispatch parallel subagents (batches of 5) to read each session via ccvault and produce a standardized summary following the [session summary schema](skills/shared/session-summary-schema.md). Summaries are cached — re-runs skip already-extracted sessions.

5. **Phase 4 — Cross-Cutting Analysis**: Apply the lens's analysis instructions across all summaries to produce the final report.

6. **Phase 5 — Write Report**: Save to `~/.claude/hindsight/reports/<date-range>/<lens-name>.md` and display to the user.

### Layer System

The pipeline has four layers. Understanding these matters when writing or debugging lenses:

| Layer | File | Controls | Modifiable by lenses? |
|-------|------|----------|----------------------|
| 1 | `skills/shared/session-summary-schema.md` | What every summary always contains | No (read-only) |
| 2 | `skills/shared/extraction-prompt.md` | How subagents read sessions and write summaries | No (read-only) |
| 3 | Lens `## Extraction Hints` | Extra per-session data for this lens | Yes |
| 4 | Lens `## Analysis Instructions` | How aggregation synthesizes summaries | Yes |

Lenses control layers 3 and 4. Layers 1 and 2 are upstream — if a lens needs changes there, that's a core contribution, not a lens change.

## Writing Your Own Lenses

The easiest way to create a lens is to use the built-in lens-writing skill:

```
/hindsight:lens-writing I want a lens that tracks security-related decisions
```

This walks you through brainstorming, drafting, and evaluating the lens with a persona-based judge panel. It follows a RED/GREEN/REFACTOR cycle: run the lens, evaluate with a panel, refine based on findings, repeat.

For the lens file format and manual creation, see the [lens-writing skill](skills/hindsight:lens-writing/SKILL.md).

## Contributing

Contributions are welcome. The bar varies by what you're contributing.

### Code & Pipeline Changes

Standard contribution expectations: clear problem statement, focused changes, tests where applicable. Open an issue first for anything non-trivial.

### Lens Contributions

**Lenses ship as defaults to all users.** A bad lens wastes everyone's time and erodes trust in the tool. The bar is deliberately high.

A lens PR must include:

1. **Differentiation proof.** Your lens must answer a question that no existing lens already covers. If it's adjacent to an existing lens, explain why extending that lens isn't the right approach. "Slightly different standup" is not a lens.

2. **At least one RED/GREEN/REFACTOR cycle.** Your lens must have been run through the `hindsight:lens-writing` evaluate mode at least once, with findings addressed. Include the evaluation artifacts (personas, synthesis) in the PR.

3. **Minimum evaluation score.** The lens must achieve a 7+/10 average across all judge personas in its most recent evaluation panel. Include the scoreboard in the PR description.

4. **Real-world output samples.** Include at least one full report generated by the lens against real session data. Redact sensitive content if needed, but the structure and quality must be visible.

5. **Clean lens file.** Follows the [lens file format](skills/hindsight:lens-writing/SKILL.md) exactly. Extraction hints are present only when the base schema doesn't capture what the lens needs. Analysis instructions are specific and testable — no vague directives.

PRs that skip these requirements will be closed without review.

### Upstream Changes (Layers 1 & 2)

Changes to the session summary schema or extraction prompt affect every lens. These require:

- A clear case for why the existing schema/prompt is insufficient
- Evidence that the change doesn't break existing lenses
- Testing against at least 2 existing lenses to verify compatibility

## License

TBD
