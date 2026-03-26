<!-- ABOUTME: Backlog of future work items for cc-review. -->
<!-- ABOUTME: Tracks deferred tasks that came up during development. -->

# cc-review Backlog

## ccvault prerequisite management
Figure out how to ensure ccvault is installed and synced before cc-review runs.
Options: install script that checks for/installs ccvault, prereq check in Phase 0,
or document as a manual step. Need to handle both `brew install` and `go install` paths.

## Incorporate ccvault skill
The ccvault project ships its own skill (`ccvault:ccvault`) with search patterns,
orient/recall workflows, and a full tool reference. cc-review should reference or
depend on that skill so extraction subagents and lenses can use ccvault's search
playbook effectively (cost ladder, query operators, pagination patterns).

## Lens-writing subskill
~~Add a subskill to cc-review that guides writing new lenses.~~ **Done** — implemented
as `skills/lens-writing/SKILL.md` with create/evaluate modes and persona-based panels.

## Upstream: session slugs in extraction pipeline
Session slugs are not surfaced from extraction through to aggregation. The standup lens
spec requires session slug references in "In Progress" and the old "Knowledge Share"
sections, but the extraction prompt and base schema don't capture or pass session
identifiers in a way the aggregation agent can reference. Surfaced by 3/6 panel judges.

## Upstream: project descriptions in base schema
The base schema captures project name and path but not a human-readable description
of what the project is. Every lens that groups by project suffers from this — readers
who don't know the projects can't understand the report. Surfaced by 3/6 panel judges.

## Upstream: PR URLs in extraction
The extraction prompt captures PR numbers but not full URLs. Reports mention "PR #69"
but can't link to it. Surfaced by 4/6 panel judges.

## Upstream: session duration and time allocation
The base schema doesn't capture session duration or time-per-project. Multiple personas
(EM, Friday Reviewer, Morning Scanner) want to know how effort was distributed across
projects. Surfaced by 4/6 panel judges.

## Aggregation compliance: LLM instruction following
The aggregation agent doesn't fully comply with lens instructions. Observed issues:
- Content principles partially ignored (e.g., "deleted 8,888 lines" is the exact
  anti-pattern the lens v2 calls out, but it appeared in the v2 output anyway)
- Heading hierarchy broken (sections and project sub-headings both at ### level)
- Date misattribution (work from other dates included in single-day report)
- Project naming inconsistency (instapost vs postkeeper without explanation)
- Fabricated claims (blocker not traceable to any session summary)
May need stronger instruction language, explicit counter-examples, or a post-generation
validation step.
