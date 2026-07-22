# Triage-Time Consumer Evaluation

**Verdict:** Solid triage material — 3 of 5 drafts are one-pass acceptable, but the two single-instance ones bury their kill-or-keep signal below a wall of justification that stalls the 30-second budget.

---

## Per-draft triage simulation

### Draft 1 — Verify current state before triaging stale artifacts
- **Action:** Accept
- **Time:** ~20s
- **Stalled?** No
- **Why:** The title is a full imperative sentence, the "Why" has four verbatim quotes across four unrelated projects (that's the strongest possible durability signal), and "How to apply" gives me three concrete steps I can imagine executing tomorrow. The final sentence — "This sharpens but doesn't replace the existing 'exhaust lookup first' doctrine" — is exactly the kind of cross-reference that lets me accept without worrying about duplication. This is the model draft.

### Draft 2 — Never let evidence-mining alone define scope
- **Action:** Edit-and-accept, but I stalled
- **Time:** ~45s (over budget)
- **Stalled?** Yes — on the "Single-project justification" block. I had to re-read to understand this was single-instance, then evaluate whether the (a)/(b)/(c) reasoning was strong enough. That's cognitive load the format is asking me to carry.
- **Why:** The rule is real and I'd keep it, but the title is 12 words and reads more like a paper abstract than a preference. The "Why" runs one giant paragraph without any visual breaks. Could I confidently accept it in 30s? Only because I remember the finishing session. A cold read would take longer.

### Draft 3 — Routing heuristic (constraints project-local, taste user-global)
- **Action:** Accept immediately
- **Time:** ~15s
- **Stalled?** No
- **Why:** Highest-leverage draft in the file — it's a meta-rule about how the retro itself routes every future draft. The justification enumerates four in-flight examples ("Firebase server-model landed global; targets human-visibility rule landed project-local…") which pre-empts the "is this real?" question. This should have been draft #1 by order of leverage.

### Draft 4 — Workaround blocked by same class of bug
- **Action:** Edit-and-accept (would tighten the title)
- **Time:** ~30s (right at budget)
- **Stalled?** Slightly — the title is a mouthful; I had to read the "Why" before I understood what "workaround-blocked-by-same-class" means
- **Why:** The verbatim quote (settings-window-not-sizeable) is vivid and the pattern is clear once you read it. But the concept doesn't land from the title alone — I need the example. On a cold triage pass, I'd probably accept with a shorter title like "If the workaround hits the same bug, the bug is in scope."

### Draft 5 — nanoclaw fork constraint
- **Action:** Accept
- **Time:** ~25s
- **Stalled?** No
- **Why:** Verbatim caps-lock "REFUSE" plus in-session repeat is unambiguous durability. The "How to apply" is specifically actionable ("never propose or run `git merge upstream/main`"). Target path is project-scoped and correctly justified. Clean.

---

## Cross-cutting readability issues

1. **Order-of-presentation is wrong for leverage.** Draft 3 (meta-rule about ALL future intent capture) should be first — everything downstream depends on it. Draft 1 (4-project reinforcement) is the second-strongest. The current order feels like "biggest paragraph first" rather than "highest leverage first."

2. **Titles are inconsistent in length.** Compare Draft 3's crisp "Routing heuristic — engineering constraints project-local, aesthetic/interaction preferences user-global" to Draft 2's "Never let evidence-mining alone define scope; always merge with an outside-in readiness standard." The latter reads like it wants to be two rules stapled together.

3. **"Single-project justification" blocks are a triage tax.** They're necessary — I want to know why a 1-hit correction escaped discard — but they force a second-read pass. Would prefer a one-line inline tag: `[1-hit: kept because meta-rule / verbatim-repeat / hardline-language]` rather than a 3-line paragraph after the fenced block.

4. **"Why" paragraphs vary from crisp (Draft 5) to dense wall-of-text (Draft 2).** A blank line before the verbatim quote in Draft 2 would help scan-ability enormously.

5. **Target paths use both `~/` and `/Users/dylanr/`.** Draft 5 is fully expanded (`/Users/dylanr/work/tools/nanoclaw/...`) while Drafts 1-4 use `~/.claude/intent/pending/...`. Not a blocker but noticeable during scan.

---

## What's missing

- **A one-line leverage tag per draft.** Something like `[reinforced-4x]` `[meta-rule]` `[verbatim-repeat]` — inline in the header — would let me sort the queue mentally in one pass.
- **Explicit "reject → why not to reject" for the single-instance ones.** The current justifications explain why they were kept, but during triage I want to see the counterargument surfaced too. If none exists, say so.
- **A one-liner overlap check.** Draft 1's last sentence does this well ("sharpens but doesn't replace 'exhaust lookup first'"). Drafts 2, 3, 4 don't cross-reference existing doctrine — I have to mentally check against `intent.md` myself.
- **"Notes → Discarded but worth watching" section is great**, but I'd want it flagged for the drafts that share DNA (e.g., is Draft 4's "workaround-blocked" adjacent to the "Agent controls artifact under test" discard? Skim says maybe).

---

## What's there that I don't need

- **The "Notes → Already captured" and "Also captured elsewhere" sections.** Useful for the report author's rigor, but during triage I'm not going to act on these — they're proof-of-work, not queue items. Could be an appendix.
- **"Range compliance" block.** Fine for the author's self-audit; zero value during triage. Move to footer or drop.
- **The footnote about gitwatcher being a small session.** I don't need to know what was excluded and why during triage.
- **Sessions-scanned / projects list at top.** Interesting for provenance audits, not for triage. Could be a `<details>` block or footer.
- **"Next: Materialize" section.** The instructions on how to run `/intent-pending materialize-from-report` are useful ONCE, but every future report will duplicate this. Belongs in the plugin README, not each report.

---

## Final score: **7 / 10**

Justification: Drafts 1, 3, 5 are triage-ready and I'd action them in under a minute total. Drafts 2 and 4 pushed past the 30s budget because of dense "Why" paragraphs and title clarity issues. The report is honest and provenance-tight — I trust it — but it treats triage as "reading" when I want it to be "scanning." The report author is optimizing for defensibility; I'm optimizing for velocity. Move the meta-rule (Draft 3) to top, tighten Draft 2's title, add inline leverage tags, and move the "Notes" tail into a collapsible appendix, and this jumps to a 9.
