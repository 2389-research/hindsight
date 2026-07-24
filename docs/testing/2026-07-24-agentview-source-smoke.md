# agentsview source — manual smoke tests

Automated coverage is limited because verifying the both-installed
dedup path and the agentsview-only path requires a live agentsview
install AND requires invoking `/hindsight` end-to-end (which a subagent
cannot do). This doc is the running record for hand-verified scenarios.

## Preconditions

- Both `ccvault` and `agentsview` installed and synced on the test
  machine (per Task 0 setup instructions).
- `feature/agentview-source` branch checked out.
- Baseline reports exist at `~/.claude/hindsight/reports/2026-07-21/`
  (from the pre-refactor pipeline — use these to sanity-check
  post-refactor output).

## Scenario A: agentsview-only path

Prereqs: temporarily disable ccvault so only agentsview is available.

    sudo mv $(which ccvault){,.bak}

1. Run `/hindsight <recent-date> standup`.
2. Verify Phase 0 announces "sources detected: agentsview".
3. Verify Phase 1 lists agentsview sessions from the date range.
4. Verify Phase 3 subagents invoke `agentsview session get`
   / `agentsview session messages` (not `ccvault show` / `ccvault export`).
5. Verify report renders with the same schema as ccvault-only runs.

Cleanup: `sudo mv $(which ccvault){.bak,}`.

## Scenario B: both-installed dedup path

Prereqs: both installed and synced from the same `~/.claude/projects/`
root.

1. Run `/hindsight <recent-date> standup`.
2. Verify Phase 0 announces both sources.
3. Verify session count matches the ccvault-only count for the same
   date (dedup working — the same Claude session UUID shows up in
   both sources' `list-sessions` output, and Phase 1's dedup keeps
   only the ccvault-tagged row).
4. Sanity-check a random session's subagent transcript: it should
   have been extracted via ccvault (the preferred source per Phase 1
   dedup), not agentsview.

## Scenario C: neither installed

Prereqs: rename both binaries.

    sudo mv $(which ccvault){,.bak}
    sudo mv $(which agentsview){,.bak}

1. Run `/hindsight today standup`.
2. Verify halt message matches the exact expected text from
   SKILL.md Phase 0 Step 0:

   > No session log source found. Install one of:
   > - ccvault: `brew install 2389-research/tap/ccvault && ccvault sync`
   > - agentsview: `brew install --cask agentsview && agentsview sync`

Cleanup:

    sudo mv $(which ccvault){.bak,}
    sudo mv $(which agentsview){.bak,}

## Scenario D: broken agentsview daemon (graceful degrade)

Prereqs: both installed; agentsview daemon stopped.

    agentsview daemon stop

1. Run `/hindsight <recent-date> standup`.
2. Verify the agentsview probe (`agentsview session list --limit 1
   --json`) either succeeds (auto-daemon restart) or fails cleanly.
3. If probe failed: Phase 0 announces "sources detected: ccvault"
   only; run continues on ccvault alone.
4. If probe succeeded (auto-restart): dual-source path continues
   normally.

Cleanup: `agentsview daemon start` if you stopped it.

Note: `skills/shared/sources.md` records that agentsview daemon
lifecycle is auto-managed by `agentsview sync` and there is no
manual `daemon start` step in normal operation. This scenario
exercises the broken-daemon graceful-degrade path — the exact
mechanism for forcing the failure may vary by agentsview version;
adjust to whatever produces a probe failure on the machine under
test.

## Scenario E: lens compat sweep (behavioral)

Task 7 did a structural sweep. This is the behavioral counterpart.

For each of the 7 built-in lenses (or 6 on this branch, pending
intent-retro merge):

    /hindsight 2026-07-21 <lens-name>

Verify: report renders without error; schema fields populate; no
source-specific field leaks in the report (a lens output that
mentions `source_file` or `health_score` would be a design leak
missed by Task 7).

Run through the list:

- [ ] standup
- [ ] knowledge-extraction
- [ ] workflow-optimization
- [ ] agent-autonomy
- [ ] content-mining
- [ ] skill-review
- [ ] intent-retro (post feature/intent-retro-lens merge)

## Recording results

When a scenario is verified, check the box or annotate with the
date and any surprises. This doc is meant to be updated in place as
the branch progresses toward merge.
