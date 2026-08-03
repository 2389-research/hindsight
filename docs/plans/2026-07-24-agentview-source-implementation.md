# agentsview source support — implementation plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Support agentsview as an alternative session-log source alongside ccvault, with runtime auto-detection and naive parallel-merge when both are installed.

**Architecture:** Extract per-source CLI knowledge into a new `skills/shared/sources.md`. Add a Phase 0 detect-sources step. Phase 1 queries every available source, dedupes by session ID (ccvault wins), tags each row with its source. Phase 3 dispatches source-parameterized subagent prompts. Cache and everything above the source layer stays unchanged.

**Tech stack:** Markdown-as-code plugin. No compiled artifacts. "Tests" are behavioral scenarios: run a lens end-to-end, verify report contents.

**Reference documents:**
- Design: `docs/plans/2026-07-23-agentview-source-design.md` (this repo)
- Session shape shared across sources: `skills/shared/session-summary-schema.md`
- ccvault repo (for adapter list verification): https://github.com/2389-research/ccvault
- agentsview repo (for CLI shape verification): https://github.com/kenn-io/agentsview

---

## Task 0: Verify agentsview CLI shape against a real install

Deferred question from the design: agentsview's `session show` / `session export` shape is not documented in the excerpts we've seen. Verify before writing the shared doc that references them.

**Files:**
- Scratch notes: `docs/plans/scratch/2026-07-24-agentview-cli-shape.md` (gitignored path — not committed)

**Step 1:** Install agentsview.

```bash
brew install --cask agentsview
agentsview --version
```

Expected: version string prints, no error.

**Step 2:** Trigger a sync so the local SQLite has real data.

```bash
agentsview daemon start
agentsview sync
```

Expected: daemon starts; sync completes; no error.

**Step 3:** Verify list-sessions equivalent.

```bash
agentsview session list --help 2>&1 | head -20
agentsview session list --json --limit 5 2>&1 | head -50
```

Verify the flags for date range filtering (equivalent of ccvault's `--after` / `--before`). Record the exact flag names.

**Step 4:** Verify session-show equivalent.

```bash
# Pick any session ID from Step 3's output
agentsview session show <session-id> --json 2>&1 | head -30
```

If `session show` doesn't exist, try `agentsview session get <id>`, `agentsview session view <id>`, etc. Or fall back to the HTTP API: `curl -s http://127.0.0.1:8080/api/v1/sessions/<id>` (with auth token if required — read from `~/.agentsview/config.toml` `auth_token` field).

**Step 5:** Verify transcript-export equivalent.

```bash
agentsview session export <session-id> -o /tmp/av-test.md 2>&1
head -30 /tmp/av-test.md
```

Same fallback logic if the CLI subcommand doesn't exist.

**Step 6:** Record findings in scratch file.

Write the confirmed CLI shape (or HTTP API fallback) to `docs/plans/scratch/2026-07-24-agentview-cli-shape.md`:

- List sessions: exact command + JSON schema of returned rows
- Show session metadata: exact command + JSON schema
- Export session transcript: exact command + output format
- Any surprises (auth token required, daemon lifecycle quirks, etc.)

**Step 7:** No commit — scratch findings feed Task 2.

---

## Task 1: Extract ccvault knowledge into `skills/shared/sources.md`

Refactor prep: move all ccvault CLI knowledge from `skills/hindsight/SKILL.md` and `skills/shared/extraction-prompt.md` into a new shared file, before adding agentsview. This is a pure refactor — behavior must not change.

**Files:**
- Create: `skills/shared/sources.md`
- Modify: `skills/hindsight/SKILL.md` (Prerequisites, Phase 1 Collect Sessions)
- Modify: `skills/shared/extraction-prompt.md` ("How to Read the Session" section)

**Step 1:** Create `skills/shared/sources.md` with a single `## ccvault` section. Content extracted verbatim from current SKILL.md + extraction-prompt.md. Structure:

```markdown
<!-- ABOUTME: Canonical per-source CLI contracts for hindsight session-log sources. -->
<!-- ABOUTME: One section per source. Referenced by SKILL.md Phase 0/1 and by extraction-prompt.md subagent template. -->

# Session Log Sources

Hindsight reads session data through one of two interchangeable local-first
tools. This file is the single source of truth for how each is invoked.
Both are multi-agent at the ingestion layer and normalize their data into
a common session/turn/tool-call shape before hindsight sees it.

Adding a future third source is a new `## <source-name>` section here plus
one probe in SKILL.md Phase 0.

## ccvault

**Probe (Phase 0):** `command -v ccvault >/dev/null 2>&1 && ccvault orient --json 2>/dev/null | head -1`

**List sessions in date range (Phase 1):**

    ccvault list-sessions --json --limit <N> 2>&1

Then filter client-side by `started_at` (JSON field, ISO-8601 string) since
the CLI does not accept `--after`/`--before` flags. Session rows include:

- `id` — session UUID (may be prefixed like `nanoclaw:<uuid>` for non-claude-code sources)
- `project_path`, `project_id`, `started_at`, `ended_at`
- `model`, `git_branch`, `turn_count`
- `input_tokens`, `output_tokens`, `cache_read_tokens`, `cache_write_tokens`
- `source_file`, `has_error`, `has_subagent`, `source`

The `source` field identifies which ccvault adapter produced the session
(`claude-code`, `nanoclaw`, `codex`, `hex`, `jeff`, …). Hindsight does not
filter by this — every session goes through the same extraction pipeline
and lens output naturally reflects what each session contains.

**Session metadata (Phase 3 subagent):**

    ccvault show <session-id> --json

**Full transcript for extraction (Phase 3 subagent):**

    ccvault export <session-id> -o <output-file>

The exported markdown includes metadata, full conversation, tool usage,
tool results (default on), and thinking blocks (default on). Flags
`--no-thinking` and `--no-tool-results` can trim size for large sessions.

## agentsview

(Placeholder — filled in by Task 2.)
```

**Step 2:** Modify `skills/hindsight/SKILL.md` — Prerequisites section. Replace the current ccvault-required text with:

```markdown
## Prerequisites

1. **A session log source** must be installed and synced. Currently supported:
   - **ccvault** (`brew install 2389-research/tap/ccvault && ccvault sync`)

   See `skills/shared/sources.md` for probe commands and CLI contracts.

2. **User directories** must exist at `~/.claude/hindsight/`. If they don't, run:
   ```bash
   bash <plugin-root>/scripts/install.sh
   ```
```

**Step 3:** Modify `skills/hindsight/SKILL.md` — Phase 1 section. Replace the ccvault-specific commands with a reference to sources.md:

```markdown
### Phase 1: Collect Sessions

Use the source's `list-sessions` command (see `skills/shared/sources.md`
`## <source>` section) to find sessions in the date range. Filter by
`started_at` client-side.

For now, use `## ccvault` — additional sources will be added in a
follow-up task.
```

**Step 4:** Modify `skills/shared/extraction-prompt.md` — "How to Read the Session" section. Replace the ccvault-specific instructions with a source-parameterized version. For this refactor pass, the parameter is fixed to ccvault:

```markdown
## How to Read the Session

Use the CLI for your assigned source (see `skills/shared/sources.md`
`## <source>` section). The current source for this session is:
**{source}**.

Follow the CLI contract in that section: probe → list-sessions (already
done by parent) → show metadata → export transcript.

Read the exported transcript with the Read tool (paginate with
offset/limit for long sessions). Skim user turns first for the arc,
then sample assistant turns at decision points.
```

For this task, `{source}` is always the literal string `ccvault`.

**Step 5:** Behavioral regression check. Run the standup lens against a
known-good day and confirm the report shape is unchanged.

```bash
/hindsight 2026-07-21 intent-retro
```

Expected: report renders at `~/.claude/hindsight/reports/2026-07-21/intent-retro.md`; same 5 drafts (Tier 1 verify-current-state, Tier 2 nanoclaw, three Tier 3 keepers) as before this task. Diff empty modulo whitespace.

**Step 6:** Commit.

```bash
git add skills/shared/sources.md skills/hindsight/SKILL.md skills/shared/extraction-prompt.md
git commit -m "refactor(sources): extract ccvault CLI knowledge into shared/sources.md

Pure refactor. SKILL.md Prerequisites and Phase 1 now reference the new
canonical per-source contract file. extraction-prompt.md is parameterized
on {source} (fixed to 'ccvault' until Task 3 wires runtime detection).

No behavior change — regression run of intent-retro against 2026-07-21
produces identical output."
```

---

## Task 2: Add `## agentsview` section to `skills/shared/sources.md`

Add the new source with real CLI commands (or HTTP API fallback) from Task 0 findings. Not wired to the pipeline yet.

**Files:**
- Modify: `skills/shared/sources.md` (fill in the agentsview placeholder)

**Step 1:** Read the Task 0 scratch notes at `docs/plans/scratch/2026-07-24-agentview-cli-shape.md`.

**Step 2:** Write the `## agentsview` section. Template (fill in the verified command shapes):

```markdown
## agentsview

**Probe (Phase 0):** `command -v agentsview >/dev/null 2>&1 && agentsview session list --limit 1 --json 2>/dev/null | head -1`

If the daemon is not running, `agentsview` auto-starts it or falls back
to direct SQLite reads for read-only queries. No manual daemon start is
required for hindsight's read-only path.

**List sessions in date range (Phase 1):**

    agentsview session list <verified-flags> --json

Filter client-side by <verified-timestamp-field> (JSON field, ISO-8601
string). Session rows include:

<Fill in verified schema from Task 0 Step 3>

**Session metadata (Phase 3 subagent):**

    agentsview session show <session-id> --json

(Or HTTP API fallback if the CLI subcommand doesn't exist:)

    curl -s http://127.0.0.1:8080/api/v1/sessions/<session-id> \
      -H "Authorization: Bearer $(awk '/^auth_token/{print $3}' ~/.agentsview/config.toml | tr -d '"')"

**Full transcript for extraction (Phase 3 subagent):**

    agentsview session export <session-id> -o <output-file>

(Or HTTP API fallback for the messages endpoint if export doesn't exist.)

Both sources are multi-agent; the `agent` field on each session row
identifies the underlying agent type. Hindsight does not filter by
agent type — every session goes through the same extraction pipeline.
```

**Step 3:** Sanity check the section renders. No pipeline wiring yet, so no behavioral test.

**Step 4:** Commit.

```bash
git add skills/shared/sources.md
git commit -m "docs(sources): add agentsview CLI contract to shared/sources.md

Not wired to the pipeline yet — Task 3 does the runtime detection and
Task 4 wires Phase 1 querying. Content sourced from verified CLI shape
in Task 0 scratch notes."
```

---

## Task 3: Add Phase 0 source detection to SKILL.md

Introduce the detect-sources step. Builds an `available` list from probes; halts if empty.

**Files:**
- Modify: `skills/hindsight/SKILL.md` (add Phase 0 subsection or introduce Phase 0.5)

**Step 1:** Locate the current Phase 0 section in SKILL.md (should be "Interpret Input and Validate"). Add a new step within it, before the date-range resolution:

```markdown
**Step 0: Detect available sources**

Before doing anything else, probe which session-log sources are
installed and healthy. Read `skills/shared/sources.md` and for each
`## <source>` section, run its **Probe** command:

    # ccvault
    if command -v ccvault >/dev/null 2>&1 && ccvault orient --json >/dev/null 2>&1; then
      AVAILABLE_SOURCES="$AVAILABLE_SOURCES ccvault"
    fi

    # agentsview
    if command -v agentsview >/dev/null 2>&1 && agentsview session list --limit 1 --json >/dev/null 2>&1; then
      AVAILABLE_SOURCES="$AVAILABLE_SOURCES agentsview"
    fi

If `AVAILABLE_SOURCES` is empty after probing every section: halt with
this exact message:

> No session log source found. Install one of:
> - ccvault: `brew install 2389-research/tap/ccvault && ccvault sync`
> - agentsview: `brew install --cask agentsview && agentsview sync`

If exactly one source is available, use it exclusively. If both are
available, proceed with dual-source Phase 1 (see next task).
```

**Step 2:** Behavioral scenarios (manual, no automated test framework):

- **Both installed:** Run `/hindsight today standup` → skill announces "sources detected: ccvault, agentsview" (or equivalent).
- **Only ccvault installed:** Rename the agentsview binary temporarily (`sudo mv $(which agentsview){,.bak}`) → skill announces "sources detected: ccvault".
- **Only agentsview installed:** Similarly rename ccvault. Skill announces "sources detected: agentsview".
- **Neither:** Rename both → skill halts with the exact install-pointer message.

Restore both binaries after tests.

**Step 3:** Commit.

```bash
git add skills/hindsight/SKILL.md
git commit -m "feat(sources): add Phase 0 source detection

Probe ccvault and agentsview; build available-sources list; halt with
install pointer if empty. Single-source path unchanged from Task 1
behavior — dual-source Phase 1 wiring lands in Task 4."
```

---

## Task 4: Wire dual-source Phase 1 with dedup

Extend Phase 1 to query every source in `AVAILABLE_SOURCES`, merge, dedupe by session ID, tag each row with its source.

**Files:**
- Modify: `skills/hindsight/SKILL.md` (Phase 1)

**Step 1:** Replace the current Phase 1 body with the dual-source variant:

```markdown
### Phase 1: Collect Sessions

For each source in `AVAILABLE_SOURCES`:
1. Look up its `## <source>` section in `skills/shared/sources.md`
2. Run its list-sessions command
3. Parse the JSON output
4. Tag each row with `source: "<source-name>"`
5. Filter client-side by date range on the source's timestamp field

Concatenate all tagged rows. Dedupe by session ID: if the same ID
appears from two sources, keep the ccvault-sourced row and drop the
agentsview one (naive tie-break; ccvault preferred because its
extraction assumptions match its field names).

If the final merged list is empty: halt with "No sessions found for the
specified date range."

Report to the user: "Found N sessions across M projects for
<date-range> (sources: <comma-separated>)."
```

**Step 2:** Behavioral scenarios:

- **Both installed, both index the same day:** Run against a day both cover. Verify final session count equals ccvault-only count (dedup working). Verify the report announces both sources.
- **Both installed, one index has a day the other doesn't:** Verify sessions from the coverage-only source still appear in the report.
- **Single source:** No behavior change from Task 3.

**Step 3:** Commit.

```bash
git add skills/hindsight/SKILL.md
git commit -m "feat(sources): dual-source Phase 1 with ccvault-preferred dedup

Phase 1 iterates every AVAILABLE_SOURCE, tags rows with source, dedupes
by session ID. Single-source path unchanged. Extraction dispatch (Phase
3) uses the tagged source to select the right toolset — Task 5."
```

---

## Task 5: Parameterize Phase 3 extraction on `{source}`

The subagent prompt template needs to receive the source tag and inline the correct section of sources.md.

**Files:**
- Modify: `skills/hindsight/SKILL.md` (Phase 3, subagent prompt construction)
- Modify: `skills/shared/extraction-prompt.md` (finalize `{source}` templating)

**Step 1:** In SKILL.md Phase 3, update the subagent-prompt-construction section. Add explicit source-lookup step:

```markdown
**Constructing the subagent prompt:**

For each session, construct the subagent prompt by combining:

1. Base extraction prompt from `<plugin-root>/skills/shared/extraction-prompt.md`
2. Session summary schema from `<plugin-root>/skills/shared/session-summary-schema.md`
3. **Source-specific instructions** — look up the `## <source>` section
   of `skills/shared/sources.md` for the session's tagged source and inline
   its CLI-contract content, replacing `{SOURCE_CLI_CONTRACT}` in the
   base prompt.
4. Any lens-specific extraction hints (as before), replacing
   `{LENS_EXTRACTION_HINTS}`.
5. The session ID, project name, project path, and date range.
6. The output file path.
```

**Step 2:** In `skills/shared/extraction-prompt.md`, add the `{SOURCE_CLI_CONTRACT}` placeholder. Replace the current "How to Read the Session" section with:

```markdown
## How to Read the Session

Your assigned source is **{source}**. The CLI contract for this source is:

{SOURCE_CLI_CONTRACT}

Follow that contract: probe (already verified by parent) → show metadata
→ export transcript. Read the exported transcript with the Read tool,
paginating with offset/limit for long sessions.

Reading strategy for long sessions (100+ turns): focus on user turns to
understand the conversation arc, then sample assistant turns at decision
points rather than reading every turn.
```

**Step 3:** Behavioral test:

- Sample a ccvault-tagged session in a range → subagent transcript should show it invoking `ccvault export`, not `agentsview session export`.
- Sample an agentsview-tagged session → subagent transcript should show `agentsview session export`, not ccvault.
- Verify: the caching path is unchanged; a summary produced by one source can be re-used when the same session ID surfaces from the other source in a later run.

**Step 4:** Commit.

```bash
git add skills/hindsight/SKILL.md skills/shared/extraction-prompt.md
git commit -m "feat(sources): parameterize Phase 3 extraction on {source}

Subagent prompts now embed the CLI contract for their tagged source
only — no runtime branching inside subagents. Cache path unchanged;
cross-source cache reuse works because summaries are session-shaped, not
source-shaped."
```

---

## Task 6: Update README.md and AGENTS.md

User-facing and agent-facing docs need to reflect the new dual-source support.

**Files:**
- Modify: `README.md` (Prerequisites, Installation, Limitations, and any pipeline-description text mentioning ccvault)
- Modify: `AGENTS.md` (Dependency section, pipeline description)

**Step 1:** README.md Prerequisites section — expand:

```markdown
### Prerequisites

- **Claude Code** with plugin support
- **A session log source** — at least one of:
  - **ccvault** (`brew install 2389-research/tap/ccvault && ccvault sync`)
  - **agentsview** (`brew install --cask agentsview && agentsview sync`)

Both are local-first session indexers. Both are multi-agent at the
ingestion layer (Claude Code, Codex, and others). Hindsight auto-detects
which is installed and uses it; if both are installed, sessions from
both are merged (deduped by session ID).
```

**Step 2:** README.md "It works by" section — replace "via ccvault" with "via the configured source" and link to sources.md.

**Step 3:** README.md Limitations section — replace the ccvault-hard-dependency bullet:

```markdown
- **A session log source is a hard dependency.** Hindsight reads session
  data exclusively through ccvault or agentsview. If neither is installed
  and synced, nothing works.
- **Session data fidelity is bounded by the configured source.** Hindsight
  can only analyze what the source surfaces. Anything the source doesn't
  extract isn't available to lenses.
```

**Step 4:** AGENTS.md — update the Dependency section similarly and update the Phase 1 pipeline description ("Query ccvault" → "Query available source(s)").

**Step 5:** Commit.

```bash
git add README.md AGENTS.md
git commit -m "docs: document dual-source ccvault/agentsview support

Prerequisites now require at least one source (either works). Limitations
section reframed away from ccvault-specific hard-dependency to
source-generic. Pipeline descriptions updated to reflect the auto-detect
+ dual-source Phase 1 flow."
```

---

## Task 7: Lens compatibility sweep (regression across all built-in lenses)

Confirm that every built-in lens still works ccvault-only after the refactor. No lens should require changes if the source layer is honestly abstracted.

**Files:**
- No code changes expected. Fix-forward if any lens surfaces a source-specific field.

**Step 1:** For each of the 7 built-in lenses, run against a small (2-3 session) known-good ccvault-covered range:

```bash
/hindsight 2026-07-21 standup
/hindsight 2026-07-21 knowledge-extraction
/hindsight 2026-07-21 workflow-optimization
/hindsight 2026-07-21 agent-autonomy
/hindsight 2026-07-21 content-mining
/hindsight 2026-07-21 skill-review
/hindsight 2026-07-21 intent-retro
```

**Step 2:** For each report, verify:
- Report renders without error
- Schema fields (Metadata table, What Happened, Key Activities, etc.) all populate
- Lens-specific sections render as expected

**Step 3:** If any lens surfaces a source-specific field (e.g., a lens that references `ccvault:` prefix in session IDs, or that special-cases the `source_file` metadata), flag it as a design leak. Do NOT paper over — surface it to the user and add a follow-up task.

**Step 4:** If all seven pass with no leaks, commit a smoke-test note:

```bash
mkdir -p docs/testing
cat > docs/testing/2026-07-24-lens-compat-sweep.md <<'EOF'
# Lens compatibility sweep — 2026-07-24

Verified after refactor to dual-source Phase 1.

Ran each built-in lens against 2026-07-21 (ccvault-only):

- standup — ✓ renders, schema intact
- knowledge-extraction — ✓
- workflow-optimization — ✓
- agent-autonomy — ✓
- content-mining — ✓
- skill-review — ✓
- intent-retro — ✓

No source-specific fields surfaced in any lens output. Source layer
abstraction is honest.
EOF
git add docs/testing/2026-07-24-lens-compat-sweep.md
git commit -m "test(sources): lens compatibility sweep — all 7 built-in lenses pass ccvault-only"
```

---

## Task 8: Manual smoke tests documented + follow-up questions filed

Cover the scenarios not automatable from this machine (both-installed dedup, agentsview-only path) as documented manual tests.

**Files:**
- Create: `docs/testing/2026-07-24-agentview-source-smoke.md`
- Modify: `docs/backlog.md` (add any follow-up items surfaced during implementation)

**Step 1:** Write manual test doc:

```markdown
# agentsview source — manual smoke tests

Automated coverage is limited because verifying the both-installed dedup
path and the agentsview-only path requires a live agentsview install.
This doc is the running record for hand-verified scenarios.

## Scenario A: agentsview-only

Prereqs: ccvault renamed (`sudo mv $(which ccvault){,.bak}`); agentsview
installed and synced.

1. Run `/hindsight <recent-date> standup`.
2. Verify Phase 0 announces "sources detected: agentsview".
3. Verify Phase 1 lists agentsview sessions from the date.
4. Verify Phase 3 subagents invoke `agentsview session export` (not
   `ccvault export`).
5. Verify report renders with the same schema as ccvault-only runs.

Restore ccvault after: `sudo mv $(which ccvault){.bak,}`.

## Scenario B: both installed, dedup path

Prereqs: both installed and synced. Both index `~/.claude/projects/`, so
the same session UUIDs should surface from both.

1. Run `/hindsight <recent-date> standup`.
2. Verify Phase 0 announces both sources.
3. Verify session count matches the ccvault-only count for the same
   date (dedup working).
4. Sanity-check a random session's transcript: it should have been
   extracted via ccvault (the preferred source), not agentsview.

## Scenario C: neither installed

1. Rename both binaries.
2. Run `/hindsight today standup`.
3. Verify halt message matches the exact expected text (see Task 3
   Step 1).
4. Restore both.

## Scenario D: broken daemon

1. `agentsview daemon stop`
2. Run `/hindsight <recent-date> standup`
3. Verify graceful degradation: probe fails, agentsview treated as
   unavailable, ccvault still used.
4. Restart daemon.
```

**Step 2:** Update `docs/backlog.md` with any surfaced follow-ups. Likely candidates:
- If Task 0 revealed that `agentsview session export` returns a different transcript format than `ccvault export`, note the gap for future normalization.
- If Task 7 surfaced any lens leak, add a "Fix lens X source-agnostic" backlog item.
- Note: multi-agent-aware lens work (a lens that specifically analyzes Codex-vs-Claude patterns) as a possible future direction.

**Step 3:** Commit.

```bash
git add docs/testing/2026-07-24-agentview-source-smoke.md docs/backlog.md
git commit -m "test(sources): document manual smoke-test scenarios + surface follow-ups"
```

---

## Post-plan: open the PR

Once all tasks are complete, follow the same PR flow used for the intent-retro contribution:

1. Push `feature/agentview-source` (already tracking origin).
2. Open PR against `main` via `gh pr create` with:
   - Title: `feat(sources): support agentsview as an alternative session source`
   - Body: link to design doc, list the 8 completed tasks, note the lens-compat-sweep results, link the manual smoke-test doc.

Existing hindsight repo convention: contributions include eval artifacts if lens-level, or test docs if pipeline-level. This is pipeline-level; the smoke-test doc from Task 8 is the equivalent evidence artifact.

---

## Task summary

| Task | Description | Files | Commit |
|---|---|---|---|
| 0 | Verify agentsview CLI shape against real install | scratch only | no commit |
| 1 | Extract ccvault CLI knowledge into sources.md (pure refactor) | sources.md (new), SKILL.md, extraction-prompt.md | refactor commit |
| 2 | Add agentsview section to sources.md | sources.md | docs commit |
| 3 | Add Phase 0 source detection | SKILL.md | feat commit |
| 4 | Wire dual-source Phase 1 with dedup | SKILL.md | feat commit |
| 5 | Parameterize Phase 3 extraction on {source} | SKILL.md, extraction-prompt.md | feat commit |
| 6 | Update README.md and AGENTS.md | README.md, AGENTS.md | docs commit |
| 7 | Lens compatibility sweep (regression) | docs/testing/…-sweep.md | test commit |
| 8 | Manual smoke test doc + backlog updates | docs/testing/…-smoke.md, docs/backlog.md | test commit |

**Total commits:** 7 (Task 0 is scratch-only).
