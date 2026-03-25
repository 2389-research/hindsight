# Lens Writing Skill — Design

## Date
2026-03-25

## Problem

The cc-review plugin has a lens extension point (`~/.claude/cc-review/lenses/`) where users
create analysis perspectives for session data. Currently there's no guidance for writing or
refining lenses, and no way to evaluate lens quality beyond reading the output yourself.

The judge panel approach (5 persona-based subagent evaluators) proved effective for comparing
outputs — this design formalizes it into a reusable skill.

## Decisions

| Decision | Choice | Rationale |
|----------|--------|-----------|
| Skill location | `skills/cc-review/lens-writing/SKILL.md` | Sibling subskill, discoverable within plugin |
| Modes | Create + Evaluate, shared evaluation core | Avoids duplication; TDD cycle maps to both |
| Trigger | Intent-based (NL detection) | Users may say "find repeated mistakes" not "write a lens" |
| Personas | 5, generated from lens definition, user override | Diverse perspectives; user knows their audience best |
| Scope | Lens-level changes only | Extraction prompt / schema are plugin internals, not user-facing |
| Evaluation output | `~/.claude/cc-review/evaluations/<lens-name>/<timestamp>/` | Lens-centric, supports iteration history |
| Versioning | Simple integer in lens frontmatter (`version: 1`) | No semver complexity; lenses aren't libraries |
| Lens snapshots | Copied into each evaluation directory | Lenses aren't necessarily git-tracked |
| Upstream findings | Mentioned in synthesis, not persisted separately | Feedback-to-repo loop deferred to future design |

## Architecture

### Pipeline Layers (Read-Only Context)

The cc-review pipeline has four layers. This skill only modifies layer 3 and 4:

| Layer | File | Skill Access |
|-------|------|-------------|
| 1. Base Schema | `skills/shared/session-summary-schema.md` | Read-only |
| 2. Extraction Prompt | `skills/shared/extraction-prompt.md` | Read-only |
| 3. Lens Extraction Hints | `lenses/<name>.md § Extraction Hints` | **Read/Write** |
| 4. Lens Analysis Instructions | `lenses/<name>.md § Analysis Instructions` | **Read/Write** |

When evaluation surfaces issues at layers 1-2, the skill reports them in the synthesis
as "upstream findings" but does not modify those files.

### Lens File Format

```markdown
<!-- ABOUTME: One-line description of what this lens does. -->
<!-- ABOUTME: One-line description of who uses it. -->

---
name: lens-name
description: What this lens produces
version: 1
---

# Analysis Instructions

Instructions for the aggregation phase (cross-session synthesis).

## Format

Output structure specification.

## Extraction Hints

Additional per-session extraction instructions for subagents.
```

### File Layout

```
~/.claude/cc-review/
  lenses/
    <name>.md                              # lens files (created/edited by this skill)
  evaluations/
    <lens-name>/
      <timestamp>/
        lens-snapshot.md                   # lens as it was at evaluation time
        personas.md                        # the 5 personas used
        <persona-slug>.md                  # each judge's evaluation
        synthesis.md                       # cross-panel synthesis with layer diagnosis
  reports/                                 # cc-review pipeline output (read-only)
```

## Workflows

### Create Mode

Triggered by: "write a lens for X", "I want a new way to analyze Y",
"help me find Z across sessions"

1. **Brainstorm** — clarify purpose, audience, scope (one question at a time)
2. **Draft** — generate lens file, present for review before writing
3. **RED** — run cc-review with the lens, generate personas, confirm via
   AskUserQuestion, dispatch 5-judge panel
4. **Synthesize** — scoreboard, themes, layer diagnosis
5. **GREEN** — propose lens-level changes, apply if approved
6. **Iterate** — offer another RED/GREEN round

### Evaluate Mode

Triggered by: "evaluate the standup lens", "how good is the KE output?",
"run a panel against yesterday's report"

1. **Identify** — which lens, existing output or run fresh?
2. **Personas** — generate from lens, confirm via AskUserQuestion
3. **Panel** — dispatch 5 parallel subagent judges
4. **Synthesize** — same as Create step 4
5. **Optionally refine** — same as Create step 5-6

### Shared: Persona Generation

Input: lens name, description, analysis instructions, target audience

Output: 5 personas spanning diversity axes:
- Time horizon (needs this now vs reading later)
- Technical depth (deep expert vs high-level consumer)
- Relationship to work (doing it vs managing/reviewing)
- Consumption mode (scanning vs reading deeply)
- Skepticism level (trusting vs auditing)

Each persona has: name, role description, evaluation criteria (3-5 bullets),
intended use for the output.

Presented via AskUserQuestion (multi-select to keep/remove, option to add custom).

### Shared: Layer Diagnosis

Each panel finding is categorized:

**Lens-level (skill can fix):**
- Analysis instructions not producing right structure
- Extraction hints missing needed signals
- Lens asking wrong questions of the data

**Upstream (flag in synthesis):**
- Base schema missing fields
- Extraction prompt gaps
- Schema redundancy

Categorization presented to user for confirmation before acting.

## Integration Points

- **cc-review main skill**: Lens-writing may invoke cc-review to generate output for evaluation
- **cc-review pipeline**: Reports should include lens version (`*Generated with <lens> v<N>*`)
- **AskUserQuestion tool**: Used for mode detection (when ambiguous), persona confirmation,
  date range selection, layer diagnosis review

## TDD Mapping

| TDD Phase | Lens-Writing Analog |
|-----------|-------------------|
| RED | Run cc-review + panel evaluation → identify gaps |
| GREEN | Refine lens at the right layer → address panel feedback |
| REFACTOR | Re-run panel → find remaining issues → iterate |

## Future Work (Out of Scope)

- Feedback-to-repo loop for upstream findings (needs design around public repo constraints)
- Comparing two lens versions side-by-side in a single panel run
- Auto-suggesting lenses from session data patterns
