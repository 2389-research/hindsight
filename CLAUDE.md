# Hindsight

A Claude Code plugin that analyzes session logs through configurable lenses. See [README.md](README.md) for full user-facing docs and [AGENTS.md](AGENTS.md) for project structure and internals.

## Usage

Interactive: `/hindsight <date-range> <lens-name>`
Headless: `claude -p "use hindsight for <date-range> with the <lens-name> lens"`

## Dev Conventions

- All code files start with a two-line `ABOUTME:` comment explaining what the file does.
- No mock implementations. Always use real session data via ccvault.
- Match the style of surrounding code. Consistency within a file over external standards.
- Design docs: `docs/plans/YYYY-MM-DD-<topic>-design.md`
- Implementation plans: `docs/plans/YYYY-MM-DD-<topic>-implementation.md`
- Deferred work: `docs/backlog.md`

## Layer System

Changes to layers 1-2 (session summary schema, extraction prompt) affect every lens. Test against multiple lenses before modifying. See [AGENTS.md](AGENTS.md) for the full layer breakdown and modification guide.

## Lens Contributions

New default lenses have a high bar: differentiation proof, evaluation cycle with 7+/10 panel score, and real output samples. See [README.md contributing guidelines](README.md#lens-contributions) for full requirements.
