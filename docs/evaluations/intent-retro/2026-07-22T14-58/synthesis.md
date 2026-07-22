# intent-retro evaluation synthesis — 2026-07-22T14-58

Report evaluated: `~/.claude/hindsight/reports/2026-07-01_to_2026-07-21/intent-retro.md`
Lens version: 1
5 personas, all completed.

## Scoreboard

| Persona | Score | Verdict |
|---|---|---|
| Durability Judge | 8/10 | Discipline mostly upheld; 3/5 drafts clear cleanly, 2 are borderline single-instance with honestly-flagged justifications. |
| Verbatim-Fidelity Auditor | 8/10 | 7/8 quotes verify character-for-character; Draft #1's fantastty "pull latest" quote silently drops a leading `"ok, "` — real verbatim violation. |
| Triage-Time Consumer | 7/10 | Drafts 1/3/5 are one-pass acceptable; Drafts 2 & 4 blow the 30s budget on dense "Why" walls and unclear titles. |
| Cross-Session Dedup Checker | 8/10 | No draft-to-draft or draft-to-pending overlap; sort order violates spec (nanoclaw Tier-2 buried behind Tier-3 drafts); missing already-captured flag for finishing memory. |
| Scope-Attribution Reviewer | 7/10 | Scope calls mostly defensible; Draft #4 is a soft global override that fails the report's own Draft #3 routing heuristic. |

**Average: 7.6/10** — above the 7+/10 lens-contribution bar.

## Cross-persona themes (2+ judges converged)

### T1 — Draft #4 (workaround-blocked) is the weakest keeper
- **Judges:** Durability, Scope-Attribution, Dedup (implicit)
- **Signal:** Durability calls it "probation-accept, drop if no cross-project repeat in 4-6 weeks." Scope calls it "soft override, most fragile scope call — the rule's own category (constraint) argues against global scope by Draft #3's own heuristic." Dedup marks it clean but low-evidence.
- **Convergent recommendation:** Either downgrade Draft #4 to project-scoped (fantastty) with a "watch for repeat" tag, OR strengthen the universality justification by tying it to an existing global rule (reversibility floor / smallest reasonable changes). Silent-global-with-plausibility-argument is the report's most fragile scope call.

### T2 — Sort order violates the lens spec
- **Judges:** Dedup (explicit table), Triage-Consumer (by leverage)
- **Signal:** Spec order is Tier-1 (≥2 projects) → Tier-2 (within-project repeats) → Tier-3 (single-instance). Actual order is 1, 2, 3, 4, 5 which puts Tier-3 drafts (#2, #3, #4) *before* the Tier-2 draft (#5, nanoclaw with in-session verbatim repeat). Triage-Consumer separately argues Draft #3 should lead by leverage.
- **Convergent recommendation:** Either add explicit `## Tier 1 / ## Tier 2 / ## Tier 3` headings AND resort, or drop tiers entirely and sort by leverage (meta-rules first).

### T3 — Notes section is triage-time waste
- **Judges:** Durability, Triage-Consumer, Verbatim-Fidelity
- **Signal:** "Range compliance," "Also captured elsewhere," "Next: Materialize" all land as proof-of-work rather than actionable queue items. Triage-Consumer wants them in a `<details>` block or footer; Durability calls out the same lines as waste; Verbatim-Fidelity flags "Range compliance" self-attestation as worth exactly the cost of the ink.
- **Convergent recommendation:** Move rigor/audit trails into a companion notes file or collapsed appendix; keep only actionable content (drafts + already-captured list + discards) in the main body.

### T4 — On-draft leverage/repeat tagging missing
- **Judges:** Durability, Triage-Consumer, Dedup
- **Signal:** The lens spec calls repeat "the strongest durability signal available" but drafts don't surface it inline. Durability wants a `Repeat: yes/no` on the draft face. Triage-Consumer wants `[reinforced-4x]` `[meta-rule]` `[verbatim-repeat]` inline tags. Dedup wants tier labels visible.
- **Convergent recommendation:** Add a one-line tag inside each fenced draft body — e.g., `**Durability signal:** repeated across 4 projects` / `**Durability signal:** verbatim in-session repeat, hardline language` / `**Durability signal:** single-instance meta-rule (governs all future intent capture)`. This lets the tag travel with the pending file into `/intent-pending` triage rather than living in the retro's justification prose.

### T5 — Cross-reference to existing doctrine is inconsistent
- **Judges:** Triage-Consumer, Scope-Attribution
- **Signal:** Draft #1 explicitly notes "sharpens but doesn't replace 'exhaust lookup first' doctrine" — Triage-Consumer calls this "the model." Drafts #2, #3, #4 don't cross-reference. Scope specifically wants Draft #2 tied to the "Exhaust lookup first" doctrine to strengthen the "why universal" claim.
- **Convergent recommendation:** Every keeper should include a one-line "adjacent doctrine" or "extends X" reference where applicable, or an explicit "no overlap found" note.

### T6 — Single-project justification block placement
- **Judges:** Durability, Triage-Consumer
- **Signal:** The `**Single-project justification:**` block lives *after* the fenced draft body, not inside it. Durability: "will not travel with the file." Triage-Consumer: "3-line paragraph after the fenced block adds tax; would prefer one-line inline tag."
- **Convergent recommendation:** Move the justification INTO the fenced block (as a `**Single-project justification:** <one line>` field parallel to `**Why:**`), so the pending .md file arrives at `/intent-pending` already carrying the durability argument.

## Single-judge findings worth surfacing

### F1 — Draft #1 Q1.3 verbatim drift ("ok, " dropped)
- **Judge:** Verbatim-Fidelity only
- **Severity:** Minor but real; violates the lens's load-bearing doctrine of strict verbatim.
- **Fix:** Update Draft #1's `Why:` block to include the correct opening `"ok, we need to pull latest back into what we have and see if there's anything left to what we're doing."` on the fantastty line. Update the provenance line at the bottom of the draft the same way.

### F2 — Missing already-captured flag for finishing-memory
- **Judge:** Dedup only
- **Severity:** Medium — highest re-materialization risk in the corpus. skills-dev/finishing's "installable single-artifact" preference and "file-drop extensibility" are tagged durable+global-scope in the underlying summary but sit in `~/.claude/projects/…/memory/feedback_installable_artifacts.md` rather than in `.intent/pending/`, so a future intent-retro could re-mine them.
- **Fix:** Promote the "Also captured elsewhere" mention into the primary `## Notes → Already captured` list with a `[possibly already captured — see finishing memory]` framing.

### F3 — `~/.claude/intent/pending/` directory does not exist
- **Judge:** Dedup only
- **Severity:** Operational — Drafts #1-4 target this path but the directory is not on disk.
- **Fix:** Add to `## Next: Materialize` — "note: `~/.claude/intent/pending/` will need to be created (`mkdir -p`) before materialization."

### F4 — Missing transcript-line references
- **Judge:** Verbatim-Fidelity only
- **Severity:** Low, but would make provenance auditing seconds-fast instead of minutes-slow. This is an upstream ask (extraction prompt / summary schema).

### F5 — Draft 5's nanoclaw "3h later" temporal claim not verifiable from summary
- **Judge:** Verbatim-Fidelity only
- **Severity:** Low. Consistent with the summary's user-turn count between instances but not directly timestamped.

## Layer diagnosis

### Lens-level (this skill can fix — Analysis Instructions, Layer 4)
- **T1** (Draft #4 downgrade OR strengthen): tighten the "override justification" requirement — spec should say override lines must either (a) cite ≥2 projects of reinforcement, (b) be intrinsically meta/methodological, or (c) tie explicitly to an existing global rule. Draft #4 fits none of these.
- **T2** (sort order): add `## Tier 1 / ## Tier 2 / ## Tier 3` headings requirement OR replace tier-sort with leverage-sort with explicit ordering rule.
- **T3** (notes waste): specify what belongs in main body vs collapsed appendix. Current spec doesn't distinguish.
- **T4** (on-draft leverage tag): add a required `**Durability signal:**` line inside the fenced draft body.
- **T5** (cross-reference doctrine): require a `**Adjacent doctrine:** <cite or "none">` line for every global-scoped draft.
- **T6** (single-project justification placement): move `**Single-project justification:**` from post-fence to inside the fence, parallel to `**Why:**`.
- **F2** (finishing-memory dedup): add a specific "check the project-memory system for adjacent captures" step to the analysis instructions.

### Report-level (fix this run before materializing)
- **F1** (Q1.3 verbatim drift): correct the fantastty "ok, " drop in the current report before running `/intent-pending materialize-from-report`.
- **F3** (missing global pending dir): note the `mkdir -p` step in the current report.

### Upstream (flag, don't fix here)
- **F4** (transcript-line references): would require Layer 2 (extraction prompt) or Layer 1 (session-summary schema) change to capture transcript line numbers. Non-trivial; file for the base-schema backlog.
- **Summary-internal drift on Q1.3** (Verbatim-Fidelity flagged that the fantastty summary itself contained two variant truncations of the same quote): Layer 2 issue — extraction prompt should enforce a single canonical verbatim per correction. Non-trivial; flag but don't fix here.

## Recommended next actions

**Immediate (this run):**
1. Fix Draft #1's Q1.3 provenance quote — restore the leading `"ok, "`.
2. Add `mkdir -p ~/.claude/intent/pending` to the Materialize section.
3. Decide Draft #4: downgrade to fantastty-project scope OR add a stronger universality justification. Recommended: downgrade + `[watch for repeat]`.
4. Promote finishing-memory to the primary Already-captured list.

**Lens revision (bump to v2):**
5. Add tier headings (Tier 1 / Tier 2 / Tier 3) as required section structure.
6. Move `**Single-project justification:**` inside the fenced draft body.
7. Add a required `**Durability signal:** <one line>` field to every fenced draft.
8. Add a required `**Adjacent doctrine:** <cite or "none">` field for every global-scoped draft.
9. Split "Notes" into a `## Actionable notes` (already-captured, discards) main-body section and a `<details>Report metadata</details>` collapsible appendix (range compliance, sessions scanned, materialize instructions).
10. Tighten the "override justification" spec to name the three acceptable universality tests (cross-project reinforcement / intrinsically meta / explicit doctrine extension).

**Upstream (backlog, don't act here):**
11. Layer 2: extraction prompt should require a single canonical verbatim per correction (no summary-internal drift like fantastty's two variants of pull-latest).
12. Layer 1 or 2: session summaries should include transcript-line references for verbatim quotes.
