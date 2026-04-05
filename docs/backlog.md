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
