# Contributing to Hindsight

Thanks for your interest in contributing. This document covers the basics. For project structure and internals, see [AGENTS.md](AGENTS.md).

## Reporting Bugs

Open an issue with:

- What you tried to do
- What happened instead
- The lens and date range you used (if applicable)
- Your Claude Code version and platform

## Submitting Changes

1. Fork the repo and create a branch from `main`.
2. Make your changes. Follow the conventions in [CLAUDE.md](CLAUDE.md) — two-line `ABOUTME:` comments, no mocks, match surrounding style.
3. Open a PR with a clear problem statement and focused changes.

Open an issue first for anything non-trivial so we can align on approach before you invest time.

## Lens Contributions

**Lens contributions have a deliberately high bar.** A bad default lens wastes everyone's time and erodes trust in the tool. See the [Lens Contributions section in the README](README.md#lens-contributions) for the full requirements:

- Differentiation proof (no overlap with existing lenses)
- At least one RED/GREEN/REFACTOR evaluation cycle
- 7+/10 average panel score in the most recent evaluation
- Real-world output samples in the PR
- Clean lens file matching the documented format

PRs that skip these requirements will be closed without review. This isn't hostile — it's respect for the default lens set, which ships to every user.

## Upstream Changes (Layers 1 & 2)

Changes to the session summary schema (`skills/shared/session-summary-schema.md`) or the extraction prompt (`skills/shared/extraction-prompt.md`) affect every lens. These require:

- A clear case for why the existing schema or prompt is insufficient
- Evidence that the change doesn't break existing lenses
- Testing against at least 2 existing lenses to verify compatibility

See [AGENTS.md](AGENTS.md) for the layer system explanation.

## Code of Conduct

Be respectful. We're all here because we care about making this useful.
