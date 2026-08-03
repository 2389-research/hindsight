# The Scope-Attribution Reviewer

**Verdict:** Scope calls are mostly defensible and the report is diligent about tagging single-project overrides, but Draft #4 is a soft override that would silently expand the global taste list without meeting the spec's bar, and Draft #3 is a self-promoting meta-rule whose "override justification" partly leans on the very report it appears in.

## Per-draft scope audit

### Draft #1 — "Verify current state before triaging stale artifacts"

- **Suggested scope:** global (`~/.claude/intent/pending/2026-07-22-verify-current-state.md`)
- **Evidence supports it?** Yes. Four verbatim corrections across three distinct projects (block-friends, quoindroid, fantastty ×2) in the 3-week window. Cleanly clears the "≥2 projects" bar per the lens spec.
- **Override justification present?** N/A — no override needed.
- **Correct?** Yes. Textbook global promotion by evidence weight.

### Draft #2 — "Never let evidence-mining alone define scope; merge with outside-in readiness"

- **Suggested scope:** global (`~/.claude/intent/pending/2026-07-22-outside-in-scope.md`)
- **Evidence supports it?** Single-session (skills-dev/finishing:023ca2da). Fails the ≥2 project bar on evidence alone.
- **Override justification present?** Yes. The report explicitly names it "a methodological rule about how the agent reasons about scope, not a skills-dev/finishing-specific choice" and adds a `**Single-project justification:**` line pointing to (a) methodological principle, (b) prevent-a-class-of-misreads shape, (c) reinforced by the agent's own retro insight ("Log-mining has survivorship bias"). The justification is on-format and load-bearing.
- **Correct?** Yes. This is the strongest single-project override in the report — the rule is intrinsically about how the agent reasons, which is inherently cross-project. Would want the justification line to note that it's already partly captured in the existing global doctrine (the "Exhaust lookup first" doctrine and the "produce something concrete to react to" thesis), because outside-in-vs-inside-out is the same axis. That would sharpen the "why universal" claim rather than weaken it.

### Draft #3 — "Routing heuristic — constraints project-local, taste user-global"

- **Suggested scope:** global (`~/.claude/intent/pending/2026-07-22-constraint-vs-taste-routing.md`)
- **Evidence supports it?** Single-session (quoindroid:56f06a39) with one verbatim quote.
- **Override justification present?** Yes, and it's explicit: "meta-rule about how ALL captured corrections should be routed, not a Quoin-specific choice." The report further claims the rule was "observably applied by the user across other 2026-07 sessions" and enumerates four instances (Firebase server-model global, targets human-visibility project-local, symmetric-enforcement global, mobile tabbed/segmented global).
- **Correct?** Yes, with a caveat. The rule is inherently meta — it governs the routing of every future intent draft — so the promotion is defensible on shape alone. But the four-example reinforcement claim is a self-audit that the reviewer would want to cross-check against the actual existing `~/.claude/subfiles/intent.md` "Standing taste" section. Reading that file confirms three of the four listed reinforcements (mobile tabbed, Firebase server-model, symmetric enforcement all landed as user-global taste). Reinforcement claim holds up.

### Draft #4 — "When a workaround is blocked by the same class of bug, treat the bug as in-scope"

- **Suggested scope:** global (`~/.claude/intent/pending/2026-07-22-workaround-blocked-scope.md`)
- **Evidence supports it?** Single-session (fantastty:ecfb2b04). Fails ≥2 project bar on evidence alone.
- **Override justification present?** Yes — but it's the thinnest of the three overrides: "identifies a specific and reproducible failure mode (workaround-recursion) that would recur in any environment with pre-existing bugs. Explicit statement of the problem shape makes it generalizable." That's a plausibility argument, not a demonstration of universality. Compare to Draft #2's "methodological rule" claim (backed by the shape of the rule itself) or Draft #3's "meta-rule that shapes every future intent draft" (backed by four reinforcement examples).
- **Correct?** **Ambiguous — should be flagged, not silently resolved.** This rule could arguably be project-scoped to fantastty (or to any specific project encountering a bug-triage session) until a repeat surfaces in a second project. The "generic bug-scoping rule" framing is doing heavy lifting for a single instance where no comparable correction appeared in the other 17 sessions of the range. Per the report's own Draft #3 heuristic ("constraint project-local, taste global"), workaround-blocked-scope is much closer to a **constraint about bug triage** than to a taste/aesthetic preference — which would push it toward project-local pending an evidence repeat. **This is the report's most fragile scope call**, and by the spec's letter ("without that line, keep it project-scoped") the justification is present but comparatively weak.

### Draft #5 — "nanoclaw fork constraint — no upstream v2 merge"

- **Suggested scope:** project nanoclaw (`/Users/dylanr/work/tools/nanoclaw/.intent/pending/2026-07-22-refuse-v2-upgrade.md`)
- **Evidence supports it?** Yes. Explicit in-session verbatim ("nanoclaw has a whole new version 2 that I REFUSE to upgrade to"), repeated verbatim within the session, tied to a specific fork's architectural stance.
- **Override justification present?** N/A — not overridden; single-project scope matches single-project evidence.
- **Correct?** Yes. The `**Single-project justification:**` line here is actually explaining why the *single-session* correction is durable enough to keep at all (verbatim in-session repeat, hardline "REFUSE," first entry in a not-yet-existent `nanoclaw/INTENT.md`) — that's a different use of the justification field than the global-promotion overrides in #2/#3/#4 use it for, but it's a legitimate use. Target path is a real, specific fork location.

## Meta-consistency check: does the report apply Draft #3's routing heuristic to itself?

Draft #3 says: **constraints project-local, taste/interaction/aesthetic global; split when both.**

Applying that heuristic back to the report's own drafts:

| Draft | Category by Draft #3 | Predicted scope | Actual scope | Consistent? |
|---|---|---|---|---|
| #1 verify current state | Meta/methodological (agent reasoning rule) | global | global | Yes |
| #2 outside-in scoping | Meta/methodological (agent reasoning rule) | global | global | Yes |
| #3 routing heuristic itself | Meta/meta (how corrections route) | global | global | Yes |
| #4 workaround-blocked bug in scope | **Constraint about bug triage** — closer to engineering constraint than taste | **project or ambiguous** | global | **Inconsistent** |
| #5 nanoclaw no-v2 | Architectural constraint | project | project | Yes |

Draft #3's own heuristic, applied consistently, would flag Draft #4 as at-best-ambiguous. The report does not do this self-audit. Every other draft is consistent with the heuristic.

Also notable: the report cleanly handles the "already-captured" cases in the Notes section (three ccvault/design pending drafts flagged, not re-materialized) and the "watch-for-repeat" discards (six single-instance rules explicitly held back until they recur). That discipline is exactly the anti-drift behavior the scope rules exist to enable, and it earns significant credit.

## What's missing that I'd want

1. **Draft #4 needs either stronger override justification or a scope downgrade.** As written, the "generic scoping rule" claim is asserted, not demonstrated. Either (a) tie it to an existing global rule it extends (the reversibility floor, or "smallest reasonable changes"), or (b) scope it to fantastty and add a `[watch for repeat]` note.
2. **Explicit ambiguity call-outs** for any draft that could go either way. Draft #4 is the obvious case. Silent resolution of ambiguity is the exact failure mode the routing heuristic exists to prevent.
3. **Self-audit line applying Draft #3 to the other drafts.** A one-liner per draft — "constraint or taste? → constraint/taste → project/global" — would make scope calls auditable at a glance and would have caught the Draft #4 inconsistency.
4. **Cross-reference to existing global doctrine for overrides.** Draft #2 in particular is an extension of the already-shipped "Exhaust lookup first" doctrine; flagging the overlap would strengthen the promotion argument and let the triage step decide whether to merge rather than add.

## What's there that I don't need (waste)

1. Nothing egregious. The report is dense and mostly earns each line.
2. The `¹ Small session (20 turns)` footnote on gitwatcher is nice but not necessary for scope evaluation.
3. The "Also captured elsewhere" section is useful context but is doing work outside the scope-decision surface — could live in a companion notes file rather than the ledger output. Minor.

## Final score: 7/10

Justification:

- **+3** Draft #1 is a textbook multi-project global promotion done right.
- **+2** Drafts #2 and #3 carry explicit, load-bearing "why universal" lines that meet the spec's override bar.
- **+1** Draft #5 is a clean single-project scope with correct target path.
- **+1** The report's Notes section shows real discipline: three already-captured drafts skipped, six discarded-until-repeat candidates named, existing global doctrine cross-referenced.
- **-1** Draft #4 is a soft override — justification present but weak, and the rule's own category (constraint, not taste) argues against the global scope by the report's own Draft #3 heuristic.
- **-1** The report doesn't self-audit its Draft #4 against its own Draft #3 routing rule. Meta-consistency is the exact discipline this report should model.
- **-1** No explicit ambiguity flags anywhere; Draft #4's scope call is silently resolved rather than surfaced.

The report would score a 9 if Draft #4 either downgraded to project scope (with a watch-for-repeat note) or added a stronger universality justification tying it to an existing global rule, and if the report included a one-line self-application of Draft #3's heuristic to each of the other drafts.
