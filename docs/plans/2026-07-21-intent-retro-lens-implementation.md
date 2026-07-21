# intent-retro Lens Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Ship a new default `intent-retro` lens that mines a date range of Claude Code sessions for durable user intent and emits fenced draft ledger entries consumable by the intent plugin's `/intent-pending` triage skill.

**Architecture:** Pure Layer 3+4 contribution. Extraction hints capture verbatim corrections and ephemeral-vs-durable judgment per session. Analysis instructions cluster across sessions/projects, discard ephemeral candidates, emit keepers as fenced blocks with target paths and provenance, and hand off materialization to a companion PR in the intent plugin. `scripts/install.sh` already auto-discovers `.md` files in `lenses/`, so no script changes are required — only README + lens file + eval artifacts + real output sample.

**Tech Stack:** Markdown lens file (YAML frontmatter + Analysis Instructions + Extraction Hints); `hindsight:lens-writing` Evaluate mode for the RED cycle; ccvault for session data (via existing pipeline).

**Reference design:** [`docs/plans/2026-07-21-intent-retro-lens-design.md`](./2026-07-21-intent-retro-lens-design.md)

---

## Task 1: Draft the lens file

**Files:**
- Create: `lenses/intent-retro.md`

**Step 1: Study existing lens files for structure**

Read `lenses/knowledge-extraction.md` and `lenses/skill-review.md` in full. Note the ABOUTME header, frontmatter fields (`name`, `description`, `version`), section ordering (`# Analysis Instructions` first, `## Extraction Hints` last), and the tone of imperative instructions.

**Step 2: Write `lenses/intent-retro.md`**

Follow the design doc's Layer 3 (Extraction Hints) and Layer 4 (Analysis Instructions) sections exactly. The file must:

- Start with two `ABOUTME:` HTML comment lines.
- Have frontmatter with `name: intent-retro`, `description: Mine sessions for durable user intent — taste rules, constraints, standing preferences — and draft ledger entries for the intent plugin`, `version: 1`.
- Have a `# Analysis Instructions` section covering: clustering rule (repeat sorts first), ruthless discard of ephemeral candidates with the ~10–20% keep-rate target, scope rule (1 project → project path, ≥2 projects → global path, 1-project global override allowed with justification), fenced-block emission with `**Target path:**`, provenance ledger with verbatim quotes, INTENT.md overlap flag, sort order, and the exact output structure from the design doc.
- Have a `## Extraction Hints` section covering: verbatim corrections with 1–2 turns of surrounding agent action; standing-preference statements outside corrections; ephemeral-vs-durable evidence tag; repeat flag; project attribution; INTENT.md-touched flag with diff snippet.
- Include the "zero drafts" fallback line ("No durable intent surfaced in this range.").

**Step 3: Sanity-check the file**

Run:
```bash
head -20 /Users/dylanr/work/2389/hindsight/lenses/intent-retro.md
```

Expected: ABOUTME comments, frontmatter, opening of Analysis Instructions.

Run:
```bash
grep -c '^## ' /Users/dylanr/work/2389/hindsight/lenses/intent-retro.md
```

Expected: at least 2 (Extraction Hints + Output structure at minimum).

**Step 4: Commit**

```bash
git -C /Users/dylanr/work/2389/hindsight add lenses/intent-retro.md
git -C /Users/dylanr/work/2389/hindsight commit -m "$(cat <<'EOF'
feat: add intent-retro lens

New default lens that mines a date range of sessions for durable user
intent — taste rules, constraints, standing preferences — and emits
draft ledger entries in the intent plugin's `.intent/pending/` format.

Layer 3 captures verbatim corrections + ephemeral-vs-durable judgment.
Layer 4 clusters across sessions/projects, discards ephemeral
candidates ruthlessly, and hands off materialization to a companion PR
in the intent plugin.

Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>
EOF
)"
```

---

## Task 2: Update README's Built-in Lenses table

**Files:**
- Modify: `README.md` (the `## Built-in Lenses` table)

**Step 1: Locate the table**

Table currently has 6 rows: `standup`, `knowledge-extraction`, `workflow-optimization`, `content-mining`, `agent-autonomy`, `skill-review`. Add a 7th row for `intent-retro`.

**Step 2: Add the row**

Use `Edit` to insert after the `skill-review` row:

```
| `intent-retro` | Mine sessions for durable user intent — taste rules, constraints, standing preferences — and draft entries for the intent plugin's `.intent/pending/` triage queue |
```

**Step 3: Verify**

Run:
```bash
grep -c '^| ' /Users/dylanr/work/2389/hindsight/README.md
```

Expected: previous count + 1.

**Step 4: Commit**

```bash
git -C /Users/dylanr/work/2389/hindsight add README.md
git -C /Users/dylanr/work/2389/hindsight commit -m "$(cat <<'EOF'
docs: list intent-retro in built-in lenses table

Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>
EOF
)"
```

---

## Task 3: Smoke-test the lens locally

**Purpose:** Confirm the lens is discovered by hindsight and the pipeline runs end-to-end against a small date range before committing to the full RED cycle.

**Step 1: Copy the lens into the user lenses dir**

`install.sh` skips existing files, and hindsight reads from `~/.claude/hindsight/lenses/`. Copy the fresh lens in:

```bash
cp /Users/dylanr/work/2389/hindsight/lenses/intent-retro.md \
   ~/.claude/hindsight/lenses/intent-retro.md
```

Expected: no output; file present at target.

Verify:
```bash
ls ~/.claude/hindsight/lenses/intent-retro.md
```

Expected: file listed, no error.

**Step 2: Run hindsight against a 1-day range**

Use the `hindsight` skill against yesterday (or any recent day with ≥2 sessions). Ask the user which day is a good smoke-test target — pick one with known corrections if possible.

Expected outcome:
- Pipeline discovers the `intent-retro` lens by name.
- Extraction phase produces per-session summaries with the new `Lens-Specific Extraction` fields.
- Aggregation phase produces a report at `~/.claude/hindsight/reports/<date>/intent-retro.md`.

**Step 3: Inspect the smoke-test output**

Read the report file. Check for:
- Header with sessions scanned + projects + drafts count.
- If drafts exist: each has `**Target path:**` line and a fenced block matching the intent-plugin format.
- If drafts exist: each has a `**Provenance:**` line with session ID(s) + verbatim quote(s).
- Zero-draft fallback line if nothing durable surfaced.

**Step 4: Fix any structural bugs before proceeding**

If the report is missing structural elements (e.g., no fenced blocks, no target paths), the lens file has a defect. Edit `lenses/intent-retro.md`, re-copy to `~/.claude/hindsight/lenses/`, delete the cached report + summaries, and re-run. Commit any fix as a separate `fix:` commit.

---

## Task 4: Full RED cycle — run against the full 2026-07 range

**Files:**
- Reads: sessions via ccvault for 2026-07-01:2026-07-21
- Writes: `~/.claude/hindsight/reports/2026-07-01_2026-07-21/intent-retro.md`

**Step 1: Run hindsight for the full range**

Invoke the hindsight skill:
```
/hindsight 2026-07-01:2026-07-21 intent-retro
```

Or headless:
```bash
claude -p "use hindsight for 2026-07-01:2026-07-21 with the intent-retro lens"
```

**Step 2: Verify required-coverage projects landed**

The acceptance sketch requires sessions from `2389-ai`, `fantastty`, and `gtm-skills`. Grep the report and per-session summaries directory:

```bash
grep -l 'Project:.*2389-ai' ~/.claude/hindsight/reports/2026-07-01_2026-07-21/summaries/*.md | head -1
grep -l 'Project:.*fantastty' ~/.claude/hindsight/reports/2026-07-01_2026-07-21/summaries/*.md | head -1
grep -l 'Project:.*gtm-skills' ~/.claude/hindsight/reports/2026-07-01_2026-07-21/summaries/*.md | head -1
```

Expected: each returns at least one file path.

If any project is missing, stop and diagnose — either the date range doesn't cover work in that project, or ccvault didn't sync it. Fix before proceeding.

**Step 3: Acceptance probe**

Grep the final report for the "confident brevity in public copy" rule:

```bash
grep -i -A 2 'confident brevity\|brevity in public\|hedges\|hedging' \
  ~/.claude/hindsight/reports/2026-07-01_2026-07-21/intent-retro.md
```

Expected: at least one draft matching this rule, with a verbatim quote from the user in the provenance line.

If missing, this is a lens-level defect and Task 6 (GREEN) is required before shipping.

---

## Task 5: Run the evaluation panel

**Files:**
- Writes: `~/.claude/hindsight/evaluations/intent-retro/<timestamp>/*`

**Step 1: Invoke the lens-writing skill in Evaluate mode**

```
/hindsight:lens-writing evaluate the intent-retro lens against the 2026-07-01:2026-07-21 report
```

The skill will generate 5 personas from the lens definition. Aim the diversity axes at:

- **Durability judge** (rejects noise; skeptical of any candidate that could be ephemeral)
- **Verbatim-fidelity auditor** (checks that provenance quotes are exact user words, not paraphrase)
- **Triage-time consumer** (can they act on a draft in <30s? Is the target path obvious?)
- **Cross-session dedup checker** (are repeats merged? Are near-duplicates flagged?)
- **Scope-attribution reviewer** (are project-vs-global calls justified? Any 1-project global overrides properly explained?)

Confirm the 5 personas before the skill dispatches the panel.

**Step 2: Wait for panel synthesis**

The skill dispatches 5 parallel judge subagents and writes a synthesis to `~/.claude/hindsight/evaluations/intent-retro/<timestamp>/synthesis.md`.

**Step 3: Read the scoreboard**

Extract the persona × score table from the synthesis. Compute the average.

**Step 4: Gate decision**

- **Average ≥ 7/10 AND acceptance probe passed (Task 4 Step 3)** → proceed to Task 7.
- **Average < 7/10 OR acceptance probe failed** → proceed to Task 6 (GREEN).

---

## Task 6: GREEN cycle (only if Task 5 gate failed)

**Files:**
- Modify: `lenses/intent-retro.md` (bump version to 2)

**Step 1: Read the synthesis findings**

Focus on findings tagged **Lens-level** (this skill can fix). Ignore anything tagged **Upstream** (base schema / extraction prompt) — flag those for a separate discussion and do not modify Layer 1/2 files in this contribution.

**Step 2: Propose specific edits**

For each lens-level finding, identify the exact change to `lenses/intent-retro.md`:
- Analysis instructions edit (e.g., "sort by X before Y")
- Extraction hint tightening (e.g., "capture the 2 turns before the correction, not 1")
- Output format change (e.g., "put target path inside the fenced block")

Present the change list to the user before editing.

**Step 3: Apply edits and bump version**

Change `version: 1` → `version: 2` in the frontmatter.

**Step 4: Re-copy to user lenses dir and re-run**

```bash
cp /Users/dylanr/work/2389/hindsight/lenses/intent-retro.md \
   ~/.claude/hindsight/lenses/intent-retro.md
```

Delete the cached aggregation but keep the per-session summaries (they don't change on Layer 4 edits):

```bash
rm ~/.claude/hindsight/reports/2026-07-01_2026-07-21/intent-retro.md
```

If Layer 3 (extraction hints) changed, also delete summaries so subagents re-extract:

```bash
rm -rf ~/.claude/hindsight/reports/2026-07-01_2026-07-21/summaries/
```

Re-run hindsight for the same date range.

**Step 5: Re-run the evaluation panel**

Repeat Task 5 with the new report. Save to a new timestamped directory.

**Step 6: Gate decision**

- **New average ≥ 7/10** → proceed to Task 7.
- **New average < 7/10** → repeat Task 6 up to one more time. If still short after two GREEN cycles, stop and consult the user — the lens may need scope redesign rather than tightening.

**Step 7: Commit the refined lens**

```bash
git -C /Users/dylanr/work/2389/hindsight add lenses/intent-retro.md
git -C /Users/dylanr/work/2389/hindsight commit -m "$(cat <<'EOF'
feat(intent-retro): tighten <specific area> based on eval findings

<specific findings addressed>

Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>
EOF
)"
```

---

## Task 7: Archive eval artifacts into the repo

**Files:**
- Create: `docs/evals/intent-retro-<timestamp>/lens-snapshot.md`
- Create: `docs/evals/intent-retro-<timestamp>/personas.md`
- Create: `docs/evals/intent-retro-<timestamp>/<persona-slug>.md` (5 files)
- Create: `docs/evals/intent-retro-<timestamp>/synthesis.md`

**Step 1: Locate the passing evaluation directory**

Identify the timestamp of the eval run that passed the 7+/10 gate:

```bash
ls ~/.claude/hindsight/evaluations/intent-retro/
```

Use the latest passing one.

**Step 2: Copy artifacts into the repo**

```bash
mkdir -p /Users/dylanr/work/2389/hindsight/docs/evals
cp -R ~/.claude/hindsight/evaluations/intent-retro/<timestamp> \
      /Users/dylanr/work/2389/hindsight/docs/evals/intent-retro-<timestamp>
```

Replace `<timestamp>` with the actual directory name.

**Step 3: Verify structure**

```bash
ls /Users/dylanr/work/2389/hindsight/docs/evals/intent-retro-<timestamp>/
```

Expected: `lens-snapshot.md`, `personas.md`, five persona reports, `synthesis.md`.

**Step 4: Commit**

```bash
git -C /Users/dylanr/work/2389/hindsight add docs/evals/intent-retro-<timestamp>/
git -C /Users/dylanr/work/2389/hindsight commit -m "$(cat <<'EOF'
docs(intent-retro): archive RED/GREEN eval artifacts

Panel of 5 personas evaluated the lens against 2026-07-01:2026-07-21.
Average score: <N>/10. Synthesis and individual persona reports
included for reviewer transparency.

Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>
EOF
)"
```

---

## Task 8: Save a redacted real-output sample

**Files:**
- Create: `docs/samples/intent-retro-2026-07.md`

**Step 1: Copy the report**

```bash
mkdir -p /Users/dylanr/work/2389/hindsight/docs/samples
cp ~/.claude/hindsight/reports/2026-07-01_2026-07-21/intent-retro.md \
   /Users/dylanr/work/2389/hindsight/docs/samples/intent-retro-2026-07.md
```

**Step 2: Redact sensitive content**

Read through the sample. Redact:
- Private project names → `<project-redacted>` (unless already public: e.g., `hindsight`, `ccvault`)
- Personal names of collaborators → `<name-redacted>`
- Any credential/token/URL that looks internal → `<redacted>`

Preserve structure and general shape — the reader must see: fenced draft blocks, target paths, provenance lines, sort order, INTENT.md flags if any.

Present the redacted sample to the user before committing to confirm the redaction level is appropriate.

**Step 3: Commit**

```bash
git -C /Users/dylanr/work/2389/hindsight add docs/samples/intent-retro-2026-07.md
git -C /Users/dylanr/work/2389/hindsight commit -m "$(cat <<'EOF'
docs(intent-retro): add redacted real-output sample

Full report generated against 2026-07-01:2026-07-21 with sensitive
content redacted. Structure and draft format preserved.

Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>
EOF
)"
```

---

## Task 9: Note the companion PR in the backlog

**Files:**
- Modify: `docs/backlog.md`

**Step 1: Read the backlog**

Read `docs/backlog.md` to match the existing entry format.

**Step 2: Add an entry**

Append (or insert in the appropriate section):

```markdown
- **`/intent-pending materialize-from-report <path>`** — extend the intent
  plugin's `/intent-pending` skill to read a hindsight `intent-retro` report,
  parse its fenced draft blocks + target paths, and stash each draft to
  `.intent/pending/`. Companion to the `intent-retro` lens. Lives in the
  intent plugin repo, not this one.
```

**Step 3: Commit**

```bash
git -C /Users/dylanr/work/2389/hindsight add docs/backlog.md
git -C /Users/dylanr/work/2389/hindsight commit -m "$(cat <<'EOF'
docs: track companion PR for intent-retro materialization

Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>
EOF
)"
```

---

## Task 10: Open the pull request

**Step 1: Push the branch**

If working on `main` directly (per repo convention — check `git status` first):

```bash
git -C /Users/dylanr/work/2389/hindsight status
git -C /Users/dylanr/work/2389/hindsight log --oneline main..HEAD
```

If a feature branch is expected, ask the user before pushing to `main`. Otherwise push:

```bash
git -C /Users/dylanr/work/2389/hindsight push origin <branch>
```

**Step 2: Draft the PR body**

Body must include (README contribution requirements):

1. **Differentiation proof** — one paragraph: intent-retro emits machine-actionable drafts for the intent plugin; knowledge-extraction emits human-readable technical rules. Non-overlapping.
2. **RED/GREEN eval artifacts** — link to `docs/evals/intent-retro-<timestamp>/`.
3. **Scoreboard** — persona × score table (paste from synthesis).
4. **Real output sample** — link to `docs/samples/intent-retro-2026-07.md`.
5. **Companion PR follow-up** — note that `/intent-pending materialize-from-report` will land in a separate PR to the intent plugin repo; until then, materialization is manual copy-paste from the fenced blocks.

**Step 3: Open PR with gh**

```bash
gh pr create --title "feat: add intent-retro lens" --body "$(cat <<'EOF'
## Summary
- Adds `intent-retro` lens: mines a date range of sessions for durable user intent (taste rules, constraints, standing preferences) and emits fenced draft ledger entries in the intent plugin's `.intent/pending/` format.
- Pure Layer 3+4 contribution. No changes to `skills/hindsight/SKILL.md` or `skills/shared/*`.

## Differentiation
`knowledge-extraction` captures technical learnings for humans (prose, prescriptive rules, reusable snippets). `intent-retro` captures how the user wants their agent to behave — taste, constraints, standing preferences — as machine-actionable drafts for another tool (`/intent-pending`). Non-overlapping.

## Evaluation
Panel of 5 personas (durability judge, verbatim-fidelity auditor, triage-time consumer, cross-session dedup checker, scope-attribution reviewer) evaluated the lens against 2026-07-01:2026-07-21 across all projects in ccvault (verified coverage: `2389-ai`, `fantastty`, `gtm-skills`).

**Scoreboard:** (paste from synthesis.md)

Artifacts: `docs/evals/intent-retro-<timestamp>/`

**Acceptance probe passed:** report recovers the gtm-skills "confident brevity in public copy" rule with the user's verbatim reaction as Why.

## Sample output
`docs/samples/intent-retro-2026-07.md` — redacted real report.

## Companion PR (follow-up)
`/intent-pending materialize-from-report <path>` will land in the intent plugin repo separately. Until then, materialization is manual copy-paste of the fenced blocks. Tracked in `docs/backlog.md`.

## Test plan
- [ ] Fresh install: `bash scripts/install.sh` copies `intent-retro.md` into `~/.claude/hindsight/lenses/`
- [ ] `/hindsight <date-range> intent-retro` produces a report with the documented structure
- [ ] Report contains fenced draft blocks with target paths and provenance quotes
- [ ] Zero-drafts case emits the fallback line, no padding

🤖 Generated with [Claude Code](https://claude.com/claude-code)
EOF
)"
```

**Step 4: Return the PR URL to the user**

Print the URL from the `gh pr create` output.

---

## Post-execution checklist

- [ ] `lenses/intent-retro.md` exists, version 1 or 2, follows lens format
- [ ] README's Built-in Lenses table has the new row
- [ ] `docs/evals/intent-retro-<timestamp>/` has the 8 expected files (snapshot + personas + 5 judges + synthesis)
- [ ] `docs/samples/intent-retro-2026-07.md` is redacted and structurally complete
- [ ] `docs/backlog.md` mentions the companion PR
- [ ] All commits attributed with Co-Authored-By trailer
- [ ] PR opened with all 5 contribution requirements addressed in the body
