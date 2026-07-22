<!-- ABOUTME: Lens for mining sessions for durable user intent — taste rules, constraints, standing preferences. -->
<!-- ABOUTME: Emits fenced draft ledger entries consumable by the intent plugin's /intent-pending triage skill. -->

---
name: intent-retro
description: Mine sessions for durable user intent — taste rules, constraints, standing preferences — and draft ledger entries for the intent plugin
version: 2
---

# Analysis Instructions

Mine the session range for durable user intent — taste rules, constraints,
standing preferences that will prevent future corrections — and emit them as
draft ledger entries in the exact format the intent plugin's `/intent-pending`
triage skill consumes. The output is machine-actionable drafts, not prose.

Verbatim quotes beat paraphrase. The user's exact words are the primary
signal — paraphrasing loses the fidelity that durability judgment depends on.

## Clustering

Cluster verbatim corrections across sessions before judging any of them.
Group by the underlying rule, not the surface phrasing — "stop hedging" and
"cut the qualifiers" are the same cluster.

A correction that repeats across ≥2 sessions or ≥2 projects sorts first.
Repeat is the strongest durability signal available; a single-session
correction can be a mood, a cross-session repeat almost never is.

## Discard Discipline

Discard ephemeral candidates ruthlessly. Ephemeral = one-off wording tweaks,
typo fixes, bug-specific corrections, or context-bound preferences that
don't generalize. Durable = expresses a rule that would prevent a future
correction in a different session.

Target keep rate is 10–20% of raw corrections. A 10-session range yielding
3 drafts is a good report; the same range yielding 30 drafts is a bad one.
When in doubt, discard.

## Scope Rule

Decide each keeper's scope by where the evidence sits:

- **1 project, evidence local to that project** → target path is
  `<project>/.intent/pending/YYYY-MM-DD-<slug>.md`.
- **Same rule appears in ≥2 projects** → target path is
  `~/.claude/intent/pending/YYYY-MM-DD-<slug>.md` (global).
- **1-project → global override** is permitted only when the draft includes
  an explicit "why this is universal" line justifying the promotion (e.g.,
  writing style, comms preferences, cross-cutting agent behavior). Without
  that line, keep it project-scoped.

`<slug>` is a short kebab-case handle for the rule (e.g., `no-hedging`,
`prefer-tabs`, `stop-em-dashes`).

## Emitting Keepers

Emit each keeper as a fenced code block. On the line immediately above the
fence, print `**Target path:** <path>` using the scope rule above.

The fenced block must contain the intent plugin's exact draft format, in
this order, no additions:

```
# Proposed intent entry: <short title>
**Proposed entry (Taste|Constraints|Preference):** <the rule, 1-2 sentences>
**Why:** <the user's verbatim words + session ref>
**How to apply:** <when/where the rule kicks in>
**Suggested scope:** project <name> | global — <one-line reason>
**Durability signal:** <one-line summary of why this survived discard — e.g., "repeated across 4 projects in 3 weeks" / "verbatim in-session repeat with hardline language" / "meta-rule about the intent-capture system itself">
**Single-project justification:** <one line — only present when a single-project rule is proposed as global scope; must satisfy one of: (a) reinforced across ≥2 projects, (b) intrinsically meta/methodological, (c) explicitly extends existing global doctrine — cite which>
```

Do not deviate from field names or order. Downstream `/intent-pending`
parses fields by `**Prefix:**`. The last field is conditional (present
only on single-project → global overrides); all others are required.

## Provenance Ledger

Immediately after the fenced block, print one `**Provenance:**` line listing
the session IDs and verbatim quotes that back the draft:

```
**Provenance:** <session-id> — "<verbatim quote>"; <session-id> — "<verbatim quote>"
```

Quotes must be verbatim. Paraphrase loses signal.

When the session summary contains multiple variants of the same quote
(e.g., a truncated form in the correction summary and a fuller form in
the transcript excerpt), use the LONGEST verbatim variant. Never trim
leading discourse markers like `"ok, "` / `"well, "` / `"yeah, "` /
`"so, "` — those markers are part of the user's actual speech and can
carry tonal weight (agreement, resignation, redirection).

If a quote is long, keep the load-bearing clause verbatim and trim with
`[...]` only around it.

## Possibly-Already-Captured Flag

If any session in the range touched an `INTENT.md` file (read or edit), and
the captured diff overlaps a draft's rule, tag that draft with a line
immediately after the provenance line:

```
[possibly already captured — check <path>]
```

`<path>` points at the specific INTENT.md and, when possible, the line or
section that overlaps. Do not emit this tag speculatively — only when a real
diff overlap exists.

## Sort Order

Sort keepers in this exact order:

1. Repeat across ≥2 projects (strongest durability signal)
2. Repeat within 1 project across ≥2 sessions
3. Single-project, single-session durable candidates — each must carry a
   one-line justification for why it survived the discard cut

Within each tier, order by strength of quote (clearest standing-preference
language first).

Emit each tier under its own explicit `### Tier N — <description>` heading
in the report (see Output Structure). If a tier has zero drafts, omit that
tier's heading entirely — do not emit empty tiers.

## Output Structure

Emit exactly this shape:

    # Intent Retro — <date range>
    Sessions scanned: N | Projects: <list> | Drafts: K

    ## Drafts

    ### Tier 1 — Cross-project repeats
    (Repeat across ≥2 projects. Omit this heading if no drafts qualify.)

    #### <short title>
    **Target path:** <target-path>
    ```
    <fenced draft in the intent-plugin format>
    ```
    **Provenance:** <session-id> — "<verbatim quote>"; …
    [possibly already captured — check <path>]   (only when applicable)

    ### Tier 2 — In-project repeats
    (Repeat within 1 project across ≥2 sessions. Omit this heading if no drafts qualify.)

    #### <short title>
    ... (same shape as above)

    ### Tier 3 — Single-instance durable
    (Single-project, single-session. Each draft must carry a **Single-project justification:** inside the fenced block. Omit this heading if no drafts qualify.)

    #### <short title>
    ... (same shape as above)

    ## Next: Materialize
    Run `mkdir -p ~/.claude/intent/pending` if the global pending directory
    doesn't exist yet, then `/intent-pending materialize-from-report
    <report-path>` to stash the drafts into `.intent/pending/`. If that command
    isn't available, the fenced blocks above can be copy-pasted directly into
    the target paths.

## Zero-Drafts Fallback

If nothing durable surfaces across the range, emit only the header plus a
single line:

    No durable intent surfaced in this range.

Do not pad. Do not list rejected candidates. Do not explain why nothing
qualified. A short honest report beats a padded one.

## Extraction Hints

When summarizing each session, capture:

- **Verbatim corrections.** Every user correction, quoted exactly. Include
  1–2 turns of surrounding agent action so the reader can see what the
  correction was reacting to. Corrections include: interrupts; "no / not
  that / wrong / don't / stop doing X"; scope pushback ("too much",
  "simpler"); rejected approaches; taste reactions to presented UI or copy.
- **Standing-preference statements** even outside corrections: any turn
  containing "always / never / prefer / from now on / stop doing" applied
  to agent behavior.
- **Ephemeral vs durable tag.** Tag each captured correction with one line
  of evidence. Ephemeral = one-off wording, typo, or bug fix that does not
  generalize. Durable = expresses a rule that would prevent a future
  correction in a different session or project.
- **Repeat flag.** Note whether the agent made a mistake it had already
  been corrected on in this session, or one visibly referenced from prior
  sessions. Repeats are the strongest durability signal — flag them
  explicitly so analysis can sort them first.
- **Project attribution.** Project name is already in session metadata.
  Carry it into each captured correction so cross-project clustering can
  attribute scope correctly.
- **INTENT.md touched.** Record whether any turn read or edited an
  `INTENT.md` file. If yes, capture the diff snippet (or the relevant
  section that was read). This feeds the analysis's
  "possibly-already-captured" flag.
