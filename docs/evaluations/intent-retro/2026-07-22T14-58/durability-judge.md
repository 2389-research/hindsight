# The Durability Judge — evaluation of intent-retro report (2026-07-01..2026-07-21)

**Verdict:** Discipline is mostly upheld; 3 of 5 drafts clear the durability bar cleanly, 2 are borderline single-instance keepers that were promoted with real (but stretched) justifications — the report is honest about that stretch, so I accept it as good-faith rather than smuggled noise.

---

## Criterion-by-criterion assessment

### 1. Every keeper survives "would this prevent a future correction in a different session?"

**Draft 1 — "Verify current state before triaging stale artifacts."** *Clear pass.* Four verbatim corrections across four projects (block-friends, quoindroid, fantastty ×2). The failure mode is textbook cross-session-repeatable: agent proposes work against a stale mental model. This is exactly the shape the doctrine demands. The most defensible keeper in the report.

**Draft 2 — "Never let evidence-mining alone define scope."** *Borderline, honestly flagged.* Single-project, single-session — the report says so at line 37 and defends the promotion on grounds that it's methodological rather than domain-bound. I accept, marginally, because the correction is stated at the level of general reasoning ("we are forgetting about security review, user review, compliance"), not a finishing-plugin-specific tweak. Would it prevent a future correction elsewhere? Plausible yes — any scoping-from-logs session risks the same trap. **Keeper, but I'd want the "single-project justification" line in the draft body itself, not just in the retro margin, so the durability-review record travels with the pending file into /intent-pending.**

**Draft 3 — "Constraints project-local, taste user-global."** *Clear pass despite single-session.* This is a meta-rule about the intent-capture pipeline itself. The report's justification at line 49 is strong: the user is observably applying this rule already across their captured entries (Firebase→global, targets→project-local, symmetric-enforcement→global, tabbed-UI→global). Every downstream intent draft is affected by this rule. The single-instance status is not fatal here because the leverage is exceptional.

**Draft 4 — "Workaround blocked by same-class bug → treat bug as in-scope."** *Weakest keeper.* Single-project, single-session, single-instance. The report's justification at line 61 leans on "explicit statement of the problem shape makes it generalizable." I am not fully convinced — the pattern (agent defers a bug, workaround also fails to same bug) is real but I have not seen it repeat. This is the one I would put on probation: it's plausibly durable but has no repeat evidence, and the underlying summary (ecfb2b04) lists it alongside several other durable candidates that the report correctly discarded. **I'd accept in triage but flag "if no cross-project repeat surfaces in the next 4–6 weeks, drop it."**

**Draft 5 — "nanoclaw refuse v2 merge."** *Clear pass.* Single-session but caps-lock "REFUSE" and verbatim in-session repeat 3h later after an AUP refusal are the two strongest available single-instance durability signals. Project-scoped, blast-radius-relevant, no existing INTENT.md — starting one with this constraint is exactly what the doctrine prescribes. The provenance quote from summary line 82 is authentic.

**Score on this criterion: 3 clear passes, 1 strong single-instance pass, 1 borderline that I'd probation-accept.**

---

### 2. Discard discipline (10-20% keep rate)

Report header claims 18 non-automated sessions from a 5,390-session raw pool (nanoclaw automation and haiku eval runs filtered out — legitimate filtering, not a discard-rate dodge). Sessions like ecfb2b04 alone contain 13 candidate corrections in the lens extraction; the report keeps exactly one from that session (workaround-blocked) and discards the other 12 either into the "Notes → watch for repeat" bucket or silently.

Rough math: from spot-checking the fantastty summary (13 candidates) and the finishing summary (10 candidates) alone, the underlying corpus contains ~40–60 tagged candidates across 18 sessions. 5 keepers out of ~50 tagged candidates = ~10%. **This lands at the strict end of the 10–20% target, which is where I want it.** Discipline held.

The "Discarded but worth watching" section is not padding — every entry there has a stated reason for rejection (single-instance, adjacent to existing rule, explicitly rejected by user, business preference not agent behavior). This is exactly how discards should be documented.

---

### 3. Single-project single-session keepers carry strong survival justification

The report ships 3 single-session keepers (drafts 2, 3, 4, and arguably 5 — nanoclaw is single-session but has in-session repeat). Each has an explicit "Single-project justification" line, which is *required* by the lens spec at line 108–110.

- Draft 2's justification (methodological, mirrors agent's own retrospective learnings): **acceptable.**
- Draft 3's justification (meta-rule with observable downstream application): **strong.**
- Draft 4's justification (explicit problem-shape generalizes): **weakest — leaning on shape rather than evidence.**
- Draft 5's justification (verbatim in-session repeat + hardline language + no existing INTENT.md): **strong.**

The report is doing the right ritual here. Draft 4 is where I'd push back in triage.

---

### 4. Borderline candidates called out honestly, not padded through

The report earns real credit here. It could have padded with:
- "External OSS = smaller PRs, hands-on user review" (fantastty explicit user statement) — but correctly noted at line 103 as "refinement of existing reversibility-floor doctrine — not novel enough."
- "Visual affordance > textual annotation" (fantastty) — parked at line 101 as single UI-taste instance.
- "PR thematic coherence" (fantastty) — parked at line 100 with reason.
- "Confident brevity in public-facing copy" (gtm-skills) — the report explicitly respects the user's "skip" rejection at line 105 rather than second-guessing it.

That last one is a real trust signal. The user said "skip" on a candidate and the report did not smuggle it through. **This is the behavior I want to see.**

---

### 5. Notes section discards are actually discardable (not durable rules smuggled into the margin)

I checked each discard in "watch for repeat":

- **PR thematic coherence:** legitimately adjacent to existing "smallest reasonable changes." Discard-until-repeat is correct.
- **Visual affordance > textual annotation:** single UI-taste instance. Reasonable park.
- **Agent controls artifact under test:** flagged as "aligns with existing Control Boundaries in global CLAUDE.md." Correct — this is a reinforcement, not a new rule.
- **External OSS smaller PRs:** correctly identified as a refinement, not a novel rule.
- **Subscription-based LLM billing:** business preference. Correct discard.
- **Confident brevity in public-facing copy:** user explicitly said skip. Correct respect.

**None of these look smuggled.** The one I'd second-look is the "agent controls artifact under test" — the underlying fantastty summary (line 127–131) tags this as durable and notes it fits Control Boundaries. If the fit is really that clean, it might warrant a small addendum to Control Boundaries rather than nothing. But the discard is defensible.

---

## What's missing that I'd want

1. **Cross-session repeat evidence for draft 4 (workaround-blocked).** The report should either surface a second instance if one exists in the corpus, or explicitly say "no other instances found; retain-on-probation." Right now it's asserted-durable without repeat evidence, and my probation flag has to live in my head instead of in the file.

2. **Provenance line quality check for draft 1.** The provenance line lists four session quotes but two are from the same session (fantastty:ecfb2b04-...). Would be tighter as "3 unrelated projects, one project with two instances" — the current phrasing at line 25 obscures that.

3. **A one-line "repeat evidence found" tag on drafts 1 and 5.** The lens spec calls repeat "the strongest durability signal available" — surface it on the draft face, not just in the retro's justification prose. Downstream triage sees the raw draft file first.

4. **Explicit rejection log for the fantastty tab-thumbnails-toggle and "looks the same, prove it" candidates.** These are tagged [durable] in the underlying summary (line 122–124) and the report does not surface them in either keepers or discards. If they were consciously rejected, say so; if they were missed, that's a signal miss.

---

## What's there that I don't need (waste)

1. **The "Sessions scanned" preamble at line 4** — the raw 5,390 vs 18 accounting is useful once but the footnote-plus-parenthetical density is high for what a triage reviewer needs.

2. **The "Also captured elsewhere" section (lines 92–96).** Nice to know that skills-dev/finishing memory captured installable-artifact preference, and that skills-dev/intent is the founding thesis for existing doctrine. But this is background context, not triage-relevant. Could be one line each.

3. **The "Range compliance" footer (lines 108–110).** Self-audit that every provenance timestamp is in-range is good hygiene, but it belongs in a generation log, not in the report a triage reviewer reads.

4. **The materialize command tail (lines 112–116).** Half-instruction half-fallback. Useful to have somewhere, but it's operational noise for me — I'm evaluating whether to accept drafts, not to materialize them.

None of this waste is severe. It doesn't dilute the drafts themselves.

---

## Final score: 8/10

**Justification:**
- Discard discipline held (~10% keep rate) → +
- Cross-project repeat draft (1) is textbook durable → +
- Meta-rule draft (3) is high-leverage and honestly justified as single-instance → +
- Nanoclaw draft (5) uses the strongest available single-instance signals → +
- Every discard in the margin is genuinely discardable → +
- Draft 4 (workaround-blocked) is the weakest and would benefit from a probation flag on its face → −
- Draft 2's single-project justification lives in the retro margin, not the draft body — will not travel with the file → −
- Missing an explicit "repeat: yes/no" tag on the draft face reduces triage speed → −

Two points off for the borderline draft 4 and the missing on-face repeat/probation tagging. Not more, because the report is honest about its stretches and the discipline is real. This is the kind of report I can triage from without redoing the durability analysis myself — which is exactly what it exists to enable.
