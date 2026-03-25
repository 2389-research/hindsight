# Lens Writing Skill — Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Create a lens-writing subskill for the cc-review plugin that guides users through creating and evaluating lenses using persona-based judge panels.

**Architecture:** Single SKILL.md with two modes (create/evaluate) sharing an evaluation core. Personas generated from lens definition, confirmed via AskUserQuestion. Evaluations stored in `~/.claude/cc-review/evaluations/<lens>/<timestamp>/`.

**Tech Stack:** Markdown skill file, Agent tool for judge panels, AskUserQuestion for user interaction, Write tool for file output.

---

### Task 1: Add version field to existing lenses

**Files:**
- Modify: `lenses/standup.md`
- Modify: `lenses/knowledge-extraction.md`
- Modify: `lenses/workflow-optimization.md`

**Step 1: Add version to standup lens frontmatter**

In `lenses/standup.md`, update the frontmatter from:
```yaml
---
name: standup
description: Daily standup summary — what was done, what's next, blockers
---
```
to:
```yaml
---
name: standup
description: Daily standup summary — what was done, what's next, blockers
version: 1
---
```

**Step 2: Add version to knowledge-extraction lens frontmatter**

Same pattern — add `version: 1` to `lenses/knowledge-extraction.md` frontmatter.

**Step 3: Add version to workflow-optimization lens frontmatter**

Same pattern — add `version: 1` to `lenses/workflow-optimization.md` frontmatter.

**Step 4: Commit**

```bash
git add lenses/standup.md lenses/knowledge-extraction.md lenses/workflow-optimization.md
git commit -m "feat: add version field to all lens frontmatter"
```

---

### Task 2: Update cc-review main skill to include lens version in output

**Files:**
- Modify: `skills/cc-review/SKILL.md`

**Step 1: Add version inclusion to Phase 2 (Load Lens)**

In `skills/cc-review/SKILL.md`, update Phase 2 to also extract the `version` field
from lens frontmatter.

Add after step 3 of Phase 2:
```
4. Extract the `version` field from the lens frontmatter. If not present, default to `1`.
```

**Step 2: Add version stamp to Phase 5 (Write Report)**

In Phase 5 step 3, add instruction to include the lens version in the report output.
After writing the report header, include:

```
Include a version line after the report title:
`*Generated with <lens-name> lens v<version>*`
```

**Step 3: Commit**

```bash
git add skills/cc-review/SKILL.md
git commit -m "feat: include lens version in cc-review report output"
```

---

### Task 3: Create the lens-writing SKILL.md — frontmatter and overview

**Files:**
- Create: `skills/cc-review/lens-writing/SKILL.md`

**Step 1: Create the directory**

```bash
mkdir -p skills/cc-review/lens-writing
```

**Step 2: Write the frontmatter and overview section**

Create `skills/cc-review/lens-writing/SKILL.md` with:

```markdown
<!-- ABOUTME: Subskill for creating, evaluating, and refining cc-review lenses. -->
<!-- ABOUTME: Uses persona-based judge panels to assess lens quality through a RED/GREEN/REFACTOR cycle. -->

---
name: lens-writing
description: Use when creating, evaluating, or asking about cc-review lenses or analysis perspectives — including when the user describes a new way to analyze session data without using the word "lens"
---

# Lens Writing — Create & Evaluate cc-review Lenses

## Overview

This skill helps you create new cc-review lenses and evaluate existing ones using
persona-based judge panels. It follows a RED/GREEN/REFACTOR cycle: run the lens,
evaluate with a panel, refine based on findings, repeat.

## Modes

This skill has two modes, detected from user intent:

- **Create**: "write a lens for security auditing", "I want a new way to find repeated mistakes"
- **Evaluate**: "evaluate the standup lens", "run a panel against yesterday's KE output"

If intent is ambiguous, use AskUserQuestion to ask which mode.
```

**Step 3: Commit**

```bash
git add skills/cc-review/lens-writing/SKILL.md
git commit -m "feat: create lens-writing skill with frontmatter and overview"
```

---

### Task 4: Write the Lens Architecture Reference section

**Files:**
- Modify: `skills/cc-review/lens-writing/SKILL.md`

**Step 1: Add the architecture reference**

Append to SKILL.md after the Modes section:

```markdown
## Lens Architecture

The cc-review pipeline has four layers. This skill only modifies layers 3 and 4:

| Layer | What It Controls | This Skill |
|-------|-----------------|------------|
| 1. Base Schema (`skills/shared/session-summary-schema.md`) | What every summary always contains | Read-only |
| 2. Extraction Prompt (`skills/shared/extraction-prompt.md`) | How subagents read sessions and write summaries | Read-only |
| 3. Extraction Hints (`lenses/<name>.md § Extraction Hints`) | Extra per-session data for this lens | **Read/Write** |
| 4. Analysis Instructions (`lenses/<name>.md § Analysis Instructions`) | How aggregation synthesizes summaries | **Read/Write** |

**Layer diagnosis matters.** When evaluation finds an issue, identify which layer
it belongs to before making changes:

- "Summaries are missing commit hashes" → Layer 2 (upstream, flag don't fix)
- "Report doesn't group by severity" → Layer 4 (analysis instructions)
- "Summaries don't capture security signals" → Layer 3 (extraction hints)
- "Metadata table is inconsistent" → Layer 1 (upstream, flag don't fix)

## Lens File Format

```yaml
<!-- ABOUTME: One-line description of what this lens does. -->
<!-- ABOUTME: One-line description of who uses it. -->

---
name: lens-name
description: What this lens produces
version: 1
---

# Analysis Instructions

Instructions for the aggregation phase. Tell the aggregating agent:
- What question this lens answers
- How to structure the output (section headers, format)
- What to look for across sessions (patterns, themes, anomalies)

## Format

Specify the exact output sections and what goes in each.

## Extraction Hints

Additional instructions given to per-session extraction subagents.
These shape what extra data gets pulled from each session beyond the
base schema. Only include hints when the base schema doesn't capture
what this lens needs.
```
```

**Step 2: Commit**

```bash
git add skills/cc-review/lens-writing/SKILL.md
git commit -m "feat: add lens architecture reference to lens-writing skill"
```

---

### Task 5: Write the Create Mode workflow

**Files:**
- Modify: `skills/cc-review/lens-writing/SKILL.md`

**Step 1: Add the Create Mode section**

Append to SKILL.md:

```markdown
## Create Mode

### Step 1: Brainstorm the Lens

Clarify the lens purpose through conversation. Ask one question at a time:

1. **What question does this lens answer?** ("What mistakes keep recurring?",
   "How is time distributed?", "What security risks exist?")
2. **Who reads the output?** (the developer themselves, a manager, an auditor,
   a future onboarding engineer)
3. **What scope?** Per-session signals vs cross-session patterns vs both?
4. **What existing lens is closest?** Read available lenses from
   `~/.claude/cc-review/lenses/` and check if one already covers this need
   or could be extended.

Use AskUserQuestion with multiple choice where possible.

### Step 2: Draft the Lens File

Generate a complete lens file following the Lens File Format above.

Before writing:
- Present the draft to the user for review
- Explain what goes in Analysis Instructions vs Extraction Hints
- If the lens needs signals not in the base schema, put them in Extraction Hints
- If the lens only needs to reorganize/filter existing schema data, Extraction Hints
  may be unnecessary

Write to: `~/.claude/cc-review/lenses/<name>.md`

### Step 3: RED — Run and Evaluate

1. Run cc-review with the new lens against a date range.
   Ask the user which date range to test against (default: yesterday).
   Use the cc-review main skill: `/cc-review <date-range> <lens-name>`

2. Once output exists, proceed to the **Evaluation Core** (below).

### Step 4: GREEN — Refine

For each lens-level finding from the evaluation:
- Propose a specific change to the lens file (hints or analysis instructions)
- Explain which layer the change targets and why

Apply changes only after user approval. Bump the `version` field.

### Step 5: Iterate

Ask the user: "Want to run another evaluation round?"
If yes, return to Step 3 (RED). This is the REFACTOR phase — find remaining
issues and tighten the lens.
```

**Step 2: Commit**

```bash
git add skills/cc-review/lens-writing/SKILL.md
git commit -m "feat: add create mode workflow to lens-writing skill"
```

---

### Task 6: Write the Evaluate Mode workflow

**Files:**
- Modify: `skills/cc-review/lens-writing/SKILL.md`

**Step 1: Add the Evaluate Mode section**

Append to SKILL.md:

```markdown
## Evaluate Mode

### Step 1: Identify What to Evaluate

Determine:
- **Which lens?** Detect from user intent or ask via AskUserQuestion.
- **Existing output?** Check `~/.claude/cc-review/reports/` for recent output
  from this lens. If found, ask user whether to use existing output or run fresh.
- **Date range?** If running fresh, ask which date range.

### Step 2: Run cc-review (if needed)

If no existing output, invoke the cc-review main skill to generate it.

### Step 3: Proceed to Evaluation Core

Continue with the shared Evaluation Core below.

### Step 4: Optionally Refine

If the user wants to act on findings, follow Create Mode Steps 4-5
(GREEN → Iterate).
```

**Step 2: Commit**

```bash
git add skills/cc-review/lens-writing/SKILL.md
git commit -m "feat: add evaluate mode workflow to lens-writing skill"
```

---

### Task 7: Write the Persona Generation section

**Files:**
- Modify: `skills/cc-review/lens-writing/SKILL.md`

**Step 1: Add the Persona Generation section**

Append to SKILL.md:

```markdown
## Persona Generation

Generate 5 evaluation personas from the lens definition. Read the lens file
(name, description, analysis instructions) and infer the target audience.

### Diversity Axes

Aim for spread across these dimensions — not every lens will hit all 5,
but avoid clustering:

- **Time horizon**: needs this output now vs reading it weeks later
- **Technical depth**: deep domain expert vs high-level consumer
- **Relationship to work**: doing the work vs managing/reviewing it
- **Consumption mode**: scanning in 30 seconds vs reading deeply
- **Skepticism level**: trusting the output vs auditing for gaps

### Persona Format

Each persona has:
- **Name**: short and evocative ("The Busy EM", "The Incident Responder")
- **Role**: 1-2 sentence description of who they are
- **Cares about**: 3-5 bullet evaluation criteria specific to their perspective
- **Uses this for**: what they'd do with the output

### User Confirmation

Present the 5 personas via AskUserQuestion (multi-select). The user can:
- Keep all 5 (most common)
- Deselect personas to remove them
- Select "Other" to describe a custom persona to add or swap

Confirm the final persona list before dispatching the panel.
```

**Step 2: Commit**

```bash
git add skills/cc-review/lens-writing/SKILL.md
git commit -m "feat: add persona generation to lens-writing skill"
```

---

### Task 8: Write the Evaluation Core section

**Files:**
- Modify: `skills/cc-review/lens-writing/SKILL.md`

**Step 1: Add the Evaluation Core section**

Append to SKILL.md:

```markdown
## Evaluation Core

This is the shared evaluation logic used by both Create and Evaluate modes.

### Step 1: Setup

Create the evaluation output directory:
```bash
mkdir -p ~/.claude/cc-review/evaluations/<lens-name>/<timestamp>
```

Where `<timestamp>` is ISO-8601 format (e.g., `2026-03-25T14-30`).

Copy the current lens file as a snapshot:
```bash
cp ~/.claude/cc-review/lenses/<lens-name>.md \
   ~/.claude/cc-review/evaluations/<lens-name>/<timestamp>/lens-snapshot.md
```

### Step 2: Generate and Confirm Personas

Follow the Persona Generation process above. Write the confirmed personas to:
`~/.claude/cc-review/evaluations/<lens-name>/<timestamp>/personas.md`

### Step 3: Dispatch Judge Panel

For each persona, dispatch a parallel subagent (Agent tool) with this prompt
structure:

```
You are **{persona name}** — {persona role description}.

You are evaluating a cc-review report generated by the "{lens-name}" lens.

**Your perspective:** You care about:
{persona evaluation criteria as bullets}

**You use this output for:** {persona use case}

**The report to evaluate:**
Read the file at: {report-path}

**Evaluate from YOUR perspective:**
For each of your evaluation criteria, assess how well the report serves
your needs. Be specific — quote sections that work well or fall short.

**Write your evaluation to:** {evaluations-dir}/{persona-slug}.md

Format:
1. Your persona name and a 1-sentence verdict
2. Criterion-by-criterion assessment
3. What's missing that you'd want
4. What's there that you don't need (waste)
5. Final score: 1-10 with justification
```

Dispatch all 5 judges in parallel using the Agent tool with `run_in_background: true`.

### Step 4: Synthesize

Once all judges return, read all 5 evaluations and produce a synthesis:

**Scoreboard:** Table of persona → score → 1-sentence verdict

**Cross-persona themes:** Findings mentioned by 2+ judges

**Layer diagnosis:** For each finding, categorize as:
- **Lens-level** (this skill can fix): analysis instructions or extraction hints
- **Upstream** (flag, don't fix): base schema or extraction prompt

Present the layer diagnosis to the user for confirmation via AskUserQuestion.

**Write the synthesis to:**
`~/.claude/cc-review/evaluations/<lens-name>/<timestamp>/synthesis.md`

Report results to the user.
```

**Step 2: Commit**

```bash
git add skills/cc-review/lens-writing/SKILL.md
git commit -m "feat: add evaluation core to lens-writing skill"
```

---

### Task 9: Test the skill with an existing lens evaluation

This is a manual integration test. No code changes — verify the skill works
end-to-end.

**Step 1: Invoke the skill in evaluate mode**

Ask the skill to evaluate the standup lens against yesterday's output
(which already exists at `~/.claude/cc-review/reports/2026-03-23/standup-ccvault.md`
or similar).

**Step 2: Verify persona generation**

Check that 5 personas are generated and presented for confirmation.
Verify they span different perspectives relevant to a standup report.

**Step 3: Verify panel dispatch**

Check that 5 subagent judges are dispatched in parallel.
Verify each writes to the correct evaluations directory.

**Step 4: Verify synthesis**

Check that synthesis is produced with:
- Scoreboard
- Cross-persona themes
- Layer diagnosis

**Step 5: Verify file layout**

Confirm the evaluations directory contains:
```
~/.claude/cc-review/evaluations/standup/<timestamp>/
  lens-snapshot.md
  personas.md
  <persona-1>.md
  <persona-2>.md
  <persona-3>.md
  <persona-4>.md
  <persona-5>.md
  synthesis.md
```

---

### Task 10: Test the skill with a new lens creation

Another manual integration test.

**Step 1: Invoke the skill in create mode**

Ask the skill to create a lens for finding repeated mistakes or friction points.

**Step 2: Verify brainstorming flow**

Check that the skill asks clarifying questions one at a time about purpose,
audience, and scope.

**Step 3: Verify lens draft**

Check that a draft lens file is presented for review before writing, with
correct format (ABOUTME, frontmatter with version, analysis instructions,
extraction hints if needed).

**Step 4: Verify RED phase**

Check that the skill offers to run cc-review with the new lens and then
proceeds to evaluation.

**Step 5: Verify GREEN phase**

Check that lens-level findings are proposed as specific changes and version
is bumped on refinement.
