# The Cross-Session Dedup Checker

**Verdict:** Dedup discipline is strong — no keeper collides with another keeper, no keeper duplicates an existing pending draft or a global standing-taste entry, and the "already captured" list correctly names all three shipped-adjacent drafts. Sort order is *not* explicitly labeled, but the presentation order is defensible under a strict reading of Tier definitions (see audit). One important omission worth flagging: the "installable single-artifact tooling" preference from skills-dev/finishing is noted as "captured elsewhere" but should also appear under **already-captured / global standing-taste candidates** so `/intent-pending` triagers don't accidentally re-materialize it later.

---

## Per-draft dedup audit

### 1. `verify-current-state`
- **Semantic overlap with other keepers:** partial with (2) *outside-in-scope* — both concern "the mental model doesn't match reality" — but they're distinct: (1) is about **temporal drift** of artifacts (git pull, re-read code), (2) is about **survivorship bias** of evidence-mining. Different failure modes, different remedies. Keep separate.
- **Overlap with existing pending drafts:** none. The three shipped drafts (SSH/branch/tmux) are unrelated.
- **Overlap with global standing-taste:** partial with the doctrine's existing *"Exhaust lookup first"* under Question doctrine. The draft explicitly names this ("sharpens but doesn't replace") — good faith disclosure, well handled.
- **Verdict:** clean. Cross-project provenance (4 sessions, 3 projects) is real and correctly consolidated as a single draft — a textbook example of proper Tier-1 merge.

### 2. `outside-in-scope`
- **Semantic overlap with other keepers:** partial with (1) as noted above; disjoint from (3)/(4)/(5).
- **Overlap with existing pending drafts:** none.
- **Overlap with global standing-taste:** none. Adjacent to *"Evidence-Based: Make decisions based on actual usage patterns"* in the user CLAUDE.md, but the draft is the *counter-rule* (evidence is necessary but not sufficient), not a duplicate.
- **Verdict:** clean.

### 3. `constraint-vs-taste-routing`
- **Semantic overlap with other keepers:** none. This is a meta-rule about where the *other* drafts get filed.
- **Overlap with existing pending drafts:** none.
- **Overlap with global standing-taste:** none by rule, but this draft is the *governing rule for* the "Standing taste" section itself. Slight recursion risk — if adopted, it would formalize what has been implicit practice. Not a duplication, but a promotion.
- **Verdict:** clean. Highest-leverage single-instance keeper.

### 4. `workaround-blocked-scope`
- **Semantic overlap with other keepers:** none.
- **Overlap with existing pending drafts:** none.
- **Overlap with global standing-taste:** none.
- **Verdict:** clean.

### 5. `nanoclaw-refuse-v2-upgrade`
- **Semantic overlap with other keepers:** none (only project-scoped keeper).
- **Overlap with existing pending drafts:** none.
- **Overlap with global standing-taste:** none (correctly kept project-local per the routing rule in draft 3).
- **Verdict:** clean. Target path `/Users/dylanr/work/tools/nanoclaw/.intent/pending/…` is correct for project scope.

---

## Sort-order audit

The report does **not** label tiers in the presentation. Reconstructing:

| # | Draft | Projects with evidence | Tier |
|---|---|---|---|
| 1 | verify-current-state | 3 (block-friends, quoindroid, fantastty) | **Tier 1** — cross-project |
| 2 | outside-in-scope | 1 (skills-dev/finishing) | Tier 3 — single-project single |
| 3 | constraint-vs-taste-routing | 1 (quoindroid) | Tier 3 |
| 4 | workaround-blocked-scope | 1 (fantastty) | Tier 3 |
| 5 | nanoclaw-refuse-v2-upgrade | 1 (nanoclaw, with in-session repeat) | Tier 2 — within-project repeat |

**Strict-spec sort would be:** 1, 5, {2, 3, 4}. Actual order is: 1, {2, 3, 4}, 5.

The nanoclaw draft has an explicit in-session verbatim restatement (which the report itself flags as "the strongest available durability signals"), so under the spec's Tier-2 definition (within-project repeats) it should precede the single-instance drafts (2, 3, 4).

**Severity:** minor. All Tier-3 drafts have per-draft "Single-project justification" blocks that argue their case, and Tier-1 is correctly first. But the nanoclaw draft's stronger repeat signal being buried at position 5 is a real sort violation. Fixable by either (a) moving nanoclaw to position 2, or (b) adding explicit "## Tier 1 / ## Tier 2 / ## Tier 3" headings so triagers can see the tiering.

---

## Missing "already captured" flags

None missing among the three named (SSH / branch / tmux) — those are correctly identified.

**However**, the "Also captured elsewhere" note about `feedback_installable_artifacts.md` at `~/.claude/projects/-Users-dylanr-work-2389-skills-dev-finishing/memory/` should be **promoted into the already-captured list**, not tucked in a lower note. The skills-dev/finishing summary explicitly tags both "installable single-artifact" and "file-drop extensibility" as **global-scope, durable** — meaning they're candidates for exactly the kind of global standing-taste entry a future intent-retro might re-materialize. Flag them with a `[possibly already captured — see finishing/memory]` note so `/intent-pending` triagers know they aren't fair game to draft again.

Additionally: the global standing-taste bullet added mid-range ("Mobile/compact UI: tabbed/segmented > stacked") is correctly noted as reinforced by session 56f06a39. Good.

---

## What's missing that I'd want

1. **Explicit tier headings** in the Drafts section. The lens spec has three tiers; the report should show them structurally (`## Drafts / ### Tier 1 — cross-project (2+) / ### Tier 2 — within-project repeats / ### Tier 3 — single-instance keepers`). Without labels, a reader has to reconstruct the sort from provenance, which is fragile.
2. **Explicit `[possibly already captured]` tags** on drafts that are adjacent-but-not-duplicate to existing pending or standing-taste entries. E.g., draft 1 could carry `[adjacent to "Exhaust lookup first" doctrine — verify no overlap]`; the report handles this in prose but a scannable tag would speed triage.
3. **Promotion of the finishing memory notes** into the already-captured list as detailed above.
4. **A cross-check of `~/.claude/intent/pending/`** — the report writes drafts to that path but the directory does not currently exist on disk (verified: `No such file or directory`). Not a dedup issue per se, but the target path in draft 1/2/3/4 depends on a directory the materialization step will need to create. Worth noting in the "Next: Materialize" section.

---

## Final score: 8 / 10

**Justification:**
- **+4** for correct cross-project merging of the four "stale-mental-model" corrections into a single Tier-1 draft (this is the fragile discipline; the report nails it).
- **+2** for complete and accurate already-captured list for the three shipped drafts (SSH/branch/tmux), with correct file paths verified against disk.
- **+2** for correctly identifying overlaps with existing doctrine ("Exhaust lookup first") in-prose and framing new drafts as sharpening rather than duplicating.
- **+1** for the "Discarded but worth watching" section — future-facing dedup hygiene that reduces the odds of a single-instance signal being re-mined stale.
- **−1** for missing tier headings and the nanoclaw Tier-2 draft being ordered after single-instance drafts.
- **−1** for burying the finishing-memory "installable-artifact" preference in a side note when it deserves a first-class already-captured flag (highest re-materialization risk in the corpus).
