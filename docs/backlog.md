<!-- ABOUTME: Backlog of future work items for hindsight. -->
<!-- ABOUTME: Tracks deferred tasks that came up during development. -->

# Hindsight Backlog

## ccvault prerequisite management

Figure out how to ensure ccvault is installed and synced before hindsight runs.
Options: install script that checks for/installs ccvault, prereq check in Phase 0,
or document as a manual step. Need to handle both `brew install` and `go install` paths.

## Incorporate ccvault skill

The ccvault project ships its own skill (`ccvault:ccvault`) with search patterns,
orient/recall workflows, and a full tool reference. hindsight should reference or
depend on that skill so extraction subagents and lenses can use ccvault's search
playbook effectively (cost ladder, query operators, pagination patterns).

## Lens-writing subskill

~~Add a subskill to hindsight that guides writing new lenses.~~ **Done** — implemented
as `skills/lens-writing/SKILL.md` with create/evaluate modes and persona-based panels.

## ~~Upstream: session slugs in extraction pipeline~~

~~Session slugs are not surfaced from extraction through to aggregation.~~ **Done** —
added extraction prompt guidance for finding slugs in session data.

## ~~Upstream: project descriptions in base schema~~

~~The base schema captures project name and path but not a human-readable description.~~
**Done** — added Project Description field to schema, extraction prompt infers it from
session content.

## ~~Upstream: PR URLs in extraction~~

~~The extraction prompt captures PR numbers but not full URLs.~~ **Done** — schema and
extraction prompt now request full PR URLs.

## ~~Upstream: session duration and time allocation~~

~~Duration not captured.~~ **Partially done** — duration was already in the schema;
added extraction prompt guidance for computing it from timestamps. Time-per-project
allocation across sessions remains unsolved (would need multi-session correlation).

## ~~Aggregation compliance: LLM instruction following~~

~~The aggregation agent doesn't fully comply with lens instructions.~~ **Addressed** —
added explicit aggregation compliance rules to Phase 4 of the hindsight skill covering
date range enforcement, heading hierarchy, content principles, fabrication prevention,
and project description usage. Needs re-evaluation to confirm improvement.

## SECURITY.md agentsview parity
`SECURITY.md` L22 still describes session log data as read "via [ccvault]..." only.
Add agentsview alongside ccvault for parity now that hindsight supports both sources.
Deferred: surfaced during Task 6 (docs polish) of the agentsview source work but out
of scope for that task — this is a small standalone doc edit.

## CLAUDE.md agentsview parity
`CLAUDE.md` L11 says "always use real session data via ccvault" as a dev convention.
Could be updated to "via the configured source" (or list both) for parity. Deferred
because it's a user-editable dev convention file and the wording change isn't
load-bearing for behavior.

## intent-retro lens compat sweep
Task 7's lens compatibility sweep covered 6 of 7 built-in lenses because
`intent-retro.md` lives on the un-merged `feature/intent-retro-lens` branch. Once
that PR merges, re-run the structural sweep against `intent-retro` to confirm no
source-specific field leaks.

## Behavioral verification of dual-source path
The manual smoke tests in `docs/testing/2026-07-24-agentview-source-smoke.md` are
the current stand-in for end-to-end behavioral validation of the dual-source path.
Formal end-to-end validation (running each scenario, ticking the boxes, recording
findings) is the next step after `feature/agentview-source` merges.

## Task 0 scratch note cleanup
`docs/plans/scratch/2026-07-24-agentview-cli-shape.md` was written as Task 0's
recon output for the agentsview source work and was never committed. Once
agentsview support ships and stabilizes, decide whether to delete the file or
promote it to a permanent working note under `docs/`.
