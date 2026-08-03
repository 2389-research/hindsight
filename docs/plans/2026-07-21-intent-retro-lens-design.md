# intent-retro Lens — Design

## Date
2026-07-21

## Problem

The `intent` plugin (2389 skills-dev/intent) has a live Stop-hook retro that catches
corrections in-session and stashes drafts to `.intent/pending/<YYYY-MM-DD>-<slug>.md`;
the `/intent-pending` skill batch-triages those drafts into a project's `INTENT.md`
or global config. That live retro is inherently local: one session, one machine,
past a threshold. It misses corrections that only look durable in aggregate — the
same rule surfacing across sessions or projects — and it misses machines where the
hook wasn't installed.

Hindsight already reads sessions across a date range through ccvault. A dedicated
lens can be the batch-recall complement to the live retro: cross-session,
cross-project, aimed at durable user intent (taste rules, constraints, standing
preferences), emitting the same draft format the intent plugin's triage skill
already consumes.

## Consumer contract

Drafts must land in the intent-plugin's expected format so `/intent-pending` can
consume them without special-casing:

    # Proposed intent entry: <short title>
    **Proposed entry (Taste|Constraints|Preference):** <the rule, 1-2 sentences>
    **Why:** <the user's verbatim words + session ref>
    **How to apply:** <when/where the rule kicks in>
    **Suggested scope:** project <name> | global — <one-line reason>

Verbatim quotes beat paraphrase. The user's exact words are the primary data —
paraphrasing loses signal that the durability judgment depends on.

## Differentiation

| Lens | Captures | Consumer | Format |
|------|----------|----------|--------|
| `knowledge-extraction` | Technical learnings, patterns, prescriptive rules | Humans, onboarding | Human-readable prose |
| `intent-retro` | Standing user preferences, taste rules, constraints | The intent plugin (agent behavior config) | Machine-actionable draft entries |

`knowledge-extraction` has a single bullet in its hints about "user corrections
that suggest a convention." Here that is the entire lens, with durability
judgment, cross-session dedup, and a downstream contract to a specific tool.

## Decisions

| Decision | Choice | Rationale |
|----------|--------|-----------|
| Materialization | Report emits fenced drafts + target paths; `/intent-pending` gains a reader in a companion PR | Keeps hindsight lenses pure (report-only, no side effects outside `~/.claude/hindsight/reports/`); keeps materialization in the tool that owns `.intent/pending/` |
| Discarded candidates section | Omitted | Signal-to-noise: the report should show keepers, not the reject pile |
| Scope override at 1 project | Allowed with justification | Some rules (writing style, comms preferences) are obviously universal even at first sighting; strict 2+ project rule would miss them |
| Version | `version: 1` | Fresh lens, no history yet |
| Location | `lenses/intent-retro.md` (ships as default) | Contribution target is the default set; install.sh copies it out on install |
| Extraction hints | Present — Layer 3 needed | Base schema doesn't capture verbatim corrections or ephemeral/durable judgment |
| INTENT.md flag | Extract diff on any session that touched an INTENT.md file; use in analysis for "possibly already captured" tag | Prevents proposing rules the user has already codified |

## Architecture

### Layer 3 — Extraction Hints

Added to each session summary under `Lens-Specific Extraction`:

- **Verbatim corrections.** Every user correction, quoted exactly. Include 1–2
  turns of surrounding agent action so the reader sees what the correction was
  reacting to. Corrections include: interrupts, "no/not that/wrong/don't/stop
  doing X", scope pushback ("too much", "simpler"), rejected approaches, taste
  reactions to presented UI/copy.
- **Standing-preference statements.** "always / never / prefer / from now on"
  statements even when not preceded by a correction.
- **Ephemeral vs durable tag.** One line of evidence per correction.
  Ephemeral = one-off wording/typo/bug fix that doesn't generalize. Durable =
  expresses a rule that would prevent a future correction.
- **Repeat flag.** Did the agent make a mistake it had already been corrected on
  in this session, or one visibly referenced from prior sessions?
- **Project attribution.** Already in metadata; carried through so analysis can
  attribute scope.
- **INTENT.md touched.** Did any turn read or edit an `INTENT.md` file? If yes,
  capture the diff snippet for later overlap checks.

### Layer 4 — Analysis Instructions

1. **Cluster** verbatim corrections across sessions. Repeat across ≥2 sessions
   or ≥2 projects sorts first — repeat is the strongest durability signal.
2. **Ruthlessly discard** ephemeral candidates. Expected keep rate ~10–20%; a
   10-session range yielding 3 drafts is a good report, 30 drafts is a bad one.
3. **Scope rule**: 1 project → `<project>/.intent/pending/…`. Same rule across
   ≥2 projects → `~/.claude/intent/pending/…` (global). Override to global at
   1 project is permitted with an explicit "why this is universal" line.
4. **Emit each keeper** as a fenced block in the intent-plugin format, with
   `**Target path:**` on the line above the fence.
5. **Provenance ledger** — one line per draft: session IDs + verbatim quote.
6. **Possibly-already-captured flag** — if a session touched `INTENT.md` and
   the diff overlaps a draft's rule, tag the draft
   `[possibly already captured — check <path>]`.
7. Sort keepers by: repeat-across-projects, then repeat-in-project, then
   single-project durable with justification.

### Output structure

    # Intent Retro — <date range>
    Sessions scanned: N | Projects: <list> | Drafts: K

    ## Drafts

    ### <short title>
    **Target path:** <project>/.intent/pending/YYYY-MM-DD-<slug>.md
    ```
    <fenced draft in the intent-plugin format>
    ```
    **Provenance:** <session-id> — "<verbatim quote>"; <session-id> — "<verbatim quote>"
    [possibly already captured — check INTENT.md line 42]   (only when applicable)

    ## Next: Materialize
    Run `/intent-pending materialize-from-report <report-path>` to stash these
    drafts into `.intent/pending/`. (Companion PR to the intent plugin extends
    `/intent-pending` with the reader — until it lands, drafts can be
    copy-pasted from the fenced blocks above.)

If the report has zero drafts (nothing durable surfaced), emit only the header
plus a single line: "No durable intent surfaced in this range." Do not pad.

## Evaluation plan

- **Mode:** `hindsight:lens-writing` Evaluate mode, 5 auto-generated personas.
  Persona axes aimed at: durability judge (rejects noise), verbatim-fidelity
  auditor, triage-time consumer (act on a draft in <30s?), cross-session dedup
  checker, scope-attribution reviewer.
- **Date range:** 2026-07-01:2026-07-21. Required-coverage projects (per user
  acceptance sketch): `2389-ai`, `fantastty`, `gtm-skills`. Verify each has at
  least one session extracted before analysis.
- **Acceptance probe:** report must recover the gtm-skills "confident brevity
  in public copy" rule with the user's verbatim reaction as Why. Missing = a
  lens-level defect requiring a GREEN pass.
- **Target score:** 7+/10 panel average (matches README contribution bar). If
  RED falls short, at least one GREEN cycle. If still short, PR is not opened.
- **Future eval:** the user's 682-correction hand-classified corpus is a
  stronger judge rubric than persona-based eval. Flagged in the PR body as
  future work — not blocking this session on integrating a new judge harness.

## Install & PR bundle

**In this repo:**

- Add `lenses/intent-retro.md`.
- Update `scripts/install.sh` so fresh installs get the lens.
- Update the `## Built-in Lenses` table in `README.md`.
- Copy `~/.claude/hindsight/evaluations/intent-retro/<timestamp>/` into
  `docs/evals/intent-retro-<timestamp>/` for the PR.
- Add real output sample at `docs/samples/intent-retro-2026-07.md` (redacted if
  needed; structure preserved).

**No changes to:**

- `skills/hindsight/SKILL.md` (pipeline is layer-agnostic)
- `skills/shared/*` (base schema and extraction prompt untouched)

**Companion PR (separate, out of scope for this session):** extend
`/intent-pending` in the intent plugin with `materialize-from-report <path>`.
Noted in the hindsight PR description as follow-up.

## Risks & unknowns

- **Verbatim capture reliability.** ccvault surfaces turn text, but if the
  extraction subagent paraphrases user messages, provenance quotes will be
  weakened. Mitigation: the extraction hint explicitly demands verbatim, and
  the eval's verbatim-fidelity auditor persona checks for this.
- **Durability judgment drift.** "Ephemeral vs durable" is a judgment call. The
  RED evaluation panel is the primary check; if judges disagree with the
  lens's calls in specific drafts, GREEN tightens the durability rubric with
  concrete examples.
- **Cross-plugin coupling.** The materialize handoff requires the intent
  plugin to grow a reader. Until that lands, materialization is manual
  copy-paste. Not a blocker for merging the lens.
- **Sensitive content.** Verbatim quotes may include names, project details,
  or private preferences. The output sample in `docs/samples/` will be
  redacted; users generating their own reports own the redaction call.
