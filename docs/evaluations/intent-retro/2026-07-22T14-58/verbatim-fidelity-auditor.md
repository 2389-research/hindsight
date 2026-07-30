# The Verbatim-Fidelity Auditor

**Verdict:** Nearly clean — 7 of 8 quotes verify character-for-character against both summaries and raw transcripts, but the fantastty "pull latest" quote silently drops the leading `"ok, "` from the user's actual utterance, which is a real (minor) verbatim violation that would compound if the drafts are chained downstream.

## Per-quote audit

Each quote was verified first against the session summary at `/Users/dylanr/.claude/hindsight/reports/2026-07-01_to_2026-07-21/summaries/<session-id>.md`, then cross-checked against the raw transcript via `ccvault export <session-id>`.

### Draft #1 — "Verify current state" (four quotes)

**Q1.1 — block-friends: `08629465-f279-40a5-9dc9-901ad6c6045e`**

- Claimed: `"I know that what we did didn't address it - but it's from a long ass time ago - we may have moved away from it, or we may have otherwise implemented differently."`
- Summary line 42, 118 (matches).
- Raw transcript line 3588 (matches, same punctuation including the two hyphen-space " - " separators and terminal period).
- match=**yes** / severity=**none**

**Q1.2 — quoindroid: `56f06a39-ca92-4d0b-8712-2b9f2938d509`**

- Claimed: `"apprently quoincore should already work on linux - or something like that. can we look into what we already have and see if we can leverage it?"`
- Summary line 94 (matches).
- Raw transcript line 650 (matches; the misspelling "apprently" and lowercase "can" are preserved from the raw utterance).
- match=**yes** / severity=**none**

**Q1.3 — fantastty: `ecfb2b04-9bd1-4f26-96ff-7146b9b27cfc`**

- Claimed: `"we need to pull latest back into what we have and see if there's anything left to what we're doing."`
- Summary line 139: `"ok, we need to pull latest back into what we have and see if there's anything left to what we're doing."` (has leading `ok,`).
- Raw transcript line 8178 confirms the user's actual utterance was: `ok, we need to pull latest back into what we have and see if there's anything left to what we're doing.`
- The report **silently dropped the leading `"ok, "`** with no `[...]` elision marker.
- Note: the same summary contains a *second, shorter* variant of this quote at line 38 (`"we need to pull latest back into what we have and see if there's anything left."`) — a summary-internal drift. The report's version is neither the raw utterance nor the shorter summary paraphrase; it's a third variant that borrows the raw ending but drops the raw's leading word.
- match=**drift** / severity=**minor** (single leading discourse marker dropped; meaning intact; but violates verbatim rule and shows the mining pipeline is comfortable trimming quote edges without marking)

**Q1.4 — fantastty: `ecfb2b04-9bd1-4f26-96ff-7146b9b27cfc`**

- Claimed: `"I got the latest, and this is already handled in there."`
- Summary line 97, 3229 (matches).
- Raw transcript line 2048 (matches exactly; capitalization and terminal period preserved).
- match=**yes** / severity=**none**

### Draft #2 — "Never let evidence-mining alone define scope"

**Q2 — skills-dev/finishing: `023ca2da-a54f-434b-ad9b-a8e7fdb0b75a`**

- Claimed: `"I think I'm worried about all the other things we are forgetting about (security review, user review, compliance? etc, etc) we have very little deployment, what does that look like, etc"`
- Summary line 122 (matches).
- Raw transcript line 1154 (matches exactly — parenthesization, "?" after "compliance", double "etc, etc", and no terminal period all preserved).
- Note: line 1938 shows this was preceded in the same user turn by `"not sure where we'll try it, but w'll find something. / yes let's git init /"`. The report presents only the latter half. That's not stitching — it's a clean elision at a sentence boundary within the same turn — but a leading `[...]` marker would make the reader's job easier. No verbatim violation.
- match=**yes** / severity=**none**

### Draft #3 — "Routing heuristic"

**Q3 — quoindroid: `56f06a39-ca92-4d0b-8712-2b9f2938d509`**

- Claimed: `"so... I think that the constraint might make sense in Quoin's INTENT.md, but the taste one feels like a user level INTENT thing."`
- Summary line 118 (matches).
- Raw transcript line 1833 (matches exactly — ellipsis `"so..."`, capitalization, terminal period all preserved).
- match=**yes** / severity=**none**

### Draft #4 — "Workaround-blocked-by-same-bug"

**Q4 — fantastty: `ecfb2b04-9bd1-4f26-96ff-7146b9b27cfc`**

- Claimed: `"the settings window is not sizeable, and I can not make the terminal window any bigger. I also can not actually test this without being able to see the stuff."`
- Summary line 109, 5921 (matches).
- Raw transcript line 4378 (matches exactly — lowercase "the", split into two sentences, "I can not" as two words twice, terminal period).
- match=**yes** / severity=**none**

### Draft #5 — "nanoclaw fork constraint"

**Q5 — nanoclaw: `4ed30f27-34fa-4ca1-af4a-062ad5e4e65e`**

- Claimed: `"nanoclaw has a whole new version 2 that I REFUSE to upgrade to."` (with claim of in-session verbatim repeat 3h later)
- Summary line 81 (matches). Summary line 118 confirms the repeat.
- Raw transcript: appears at line 41 AND line 371, **byte-identical both times** — genuine verbatim in-session repeat is real, and the caps-lock "REFUSE" is preserved from the user's actual keystrokes.
- Caveat: the "3h later" temporal gap is not directly verifiable from the summary format (no timestamps embedded), but user-turn count between the two instances (~5 user messages, spanning a full AUP-refusal + retry arc) is consistent with a multi-hour gap.
- match=**yes** / severity=**none**

## Session-date & attribution check

All five cited sessions have `started_at` inside 2026-07-01..2026-07-21:

- `08629465` — 2026-07-01 18:46:20 (block-friends)
- `023ca2da` — 2026-07-02 19:55:01 (skills-dev/finishing)
- `ecfb2b04` — 2026-07-03 15:08:24 (fantastty)
- `4ed30f27` — 2026-07-07 15:33:34 (nanoclaw)
- `56f06a39` — 2026-07-17 15:38:14 (quoindroid)

Project labels in the report match the summaries' project attribution. No composite quotes stitching non-adjacent user turns (each quote came from a single contiguous user message in the raw transcript).

## What's missing that I'd want

1. **Transcript-line references, not just session IDs.** Every quote lands within a 5000-10000-line raw transcript. Verifying a claim like "3h later, verbatim repeat" or "stated at session open" would take seconds if the provenance line were `nanoclaw:4ed30f27:L41,L371 (open + 5-turn later)` instead of just `nanoclaw:4ed30f27`. Ask the summary generator to include the transcript line numbers where each verbatim quote was captured.
2. **Elision markers when leading discourse markers are dropped.** The `"ok, "` drop on Q1.3 could have been rendered `"[...]we need to pull latest back into what we have..."` and I'd have flagged it as clean. Right now it reads as if the user opened with "we need"; they opened with "ok, we need". Small but load-bearing for a strict-verbatim doctrine.
3. **Timestamp anchors for in-session repeat claims.** The report says "3h later after AUP refusal." The summary makes the same claim. Neither cites timestamps. If the durability argument leans on the temporal gap, cite it.
4. **A note on the summary's own internal drift.** The fantastty summary contains two different truncations of the pull-latest quote (line 38 shorter, line 139 full). The auditor upstream should either flag this or the report should call out which summary line it's quoting.

## What's there that I don't need (waste)

1. **The "Range compliance" section at line 108-110** — a self-attestation ("Every provenance quote above appears in a session with `started_at` inside 2026-07-01..2026-07-21. Verified.") that I still had to verify independently. Self-attestation of provenance is worth exactly the cost of the ink; either show your work or omit the claim.
2. **The "18 sessions summarized; 5 previously summarized" line** — inventory metadata that belongs in a run log, not in a provenance-critical report. Doesn't help me audit any specific quote.
3. **"(stated at session open, then restated verbatim 3h later after AUP refusal — in-session repeat)"** parenthetical on the Q5 provenance line — this is analysis, not provenance. Keep provenance to session:ID:quote and put durability commentary in the "Single-project justification" block where it already lives.

## Final score: 8/10

Justification:

- **+5** floor: 7/8 quotes verify character-for-character against both summary and raw transcript. Preserved: the "apprently" misspelling, the lowercase-"can" continuation, the double "etc, etc" with parenthesized "?", the caps-lock "REFUSE", the split-sentence "I can not" (two words), the `"so..."` ellipsis, the two-hyphen " - " separator style. That is high-fidelity mining discipline.
- **+2** for the nanoclaw in-session verbatim repeat being genuinely verbatim (byte-identical at line 41 and line 371), which validates one of the report's strongest durability signals.
- **+1** for correct session-date range compliance and correct project attribution across all five cited sessions.
- **-1** for the Q1.3 dropped `"ok, "` — a real verbatim violation, small enough that meaning survives but exactly the kind of edge-trim that erodes trust in the doctrine. It's the only drift, but the doctrine's whole load-bearing feature is that it doesn't drift. One drop is one too many.
- **-1** for missing transcript-line references, missing elision markers, and the self-attesting "Verified." line that I still had to redo by hand.

Verdict on downstream trust: **safe to promote with a fix on the Q1.3 quote.** The other four drafts stand on verifiable-verbatim ground. Before materializing, correct the Q1.3 provenance line to read `"ok, we need to pull latest back into what we have and see if there's anything left to what we're doing."` — the corresponding `Why:` bullet in the fenced block should be updated to match.
