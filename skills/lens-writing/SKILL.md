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

## Lens Locations

Lenses can live in two places:

- **User lenses** (`~/.claude/cc-review/lenses/<name>.md`): global lenses available
  across all projects. Built-in lenses ship here on install.
- **Project lenses** (`<project-root>/.claude/cc-review/lenses/<name>.md`): scoped
  to a specific codebase, checked into the repo.

When listing available lenses, check both locations. Project lenses take precedence
if a name collision occurs. Revisions always write in place — wherever the lens
currently lives.

## Lens File Format

~~~markdown
<!-- ABOUTME: One-line description of what this lens does. -->
<!-- ABOUTME: One-line description of who uses it. -->

---
name: lens-name
description: What this lens produces
version: 1
---

# Analysis Instructions

Brief directive: what this lens produces and how bullets should read.
Content principles go here — keep them short and testable.

The lens owns all formatting. The aggregation layer only enforces three
rules: date range filtering, no fabrication, and omit-don't-pad. Everything
else — heading levels, bullet style, section order, project grouping,
acronym policy — must be specified here.

## Format

Use `##` for sections, `###` for sub-groupings (e.g., per-project).
Specify the exact output sections and what goes in each.

Formatting rules belong in the section they apply to, not in a
separate "formatting guide" block. Different sections may need
different rules — e.g., past-tense bullets for accomplishments,
infinitive-tense for future work. Blanket rules that span all
sections cause compliance failures when they don't fit every context.

## Extraction Hints

Additional instructions given to per-session extraction subagents.
These shape what extra data gets pulled from each session beyond the
base schema. Only include hints when the base schema doesn't capture
what this lens needs.
~~~

## Create Mode

### Step 1: Brainstorm the Lens

Clarify the lens purpose through conversation. Ask one question at a time:

1. **What question does this lens answer?** ("What mistakes keep recurring?",
   "How is time distributed?", "What security risks exist?")
2. **Who reads the output?** (the developer themselves, a manager, an auditor,
   a future onboarding engineer)
3. **What scope?** Per-session signals vs cross-session patterns vs both?
4. **What existing lens is closest?** Read available lenses from both
   `~/.claude/cc-review/lenses/` and `<project-root>/.claude/cc-review/lenses/`
   and check if one already covers this need or could be extended.

Use AskUserQuestion with multiple choice where possible.

### Step 2: Draft the Lens File

Generate a complete lens file following the Lens File Format above.

Before writing:
- Present the draft to the user for review
- Explain what goes in Analysis Instructions vs Extraction Hints
- If the lens needs signals not in the base schema, put them in Extraction Hints
- If the lens only needs to reorganize/filter existing schema data, Extraction Hints
  may be unnecessary

Ask the user where to write the lens via AskUserQuestion:
- **User lens** (`~/.claude/cc-review/lenses/`): available across all projects
- **Project lens** (`<project-root>/.claude/cc-review/lenses/`): scoped to this repo

Write to the chosen location.

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

## Evaluation Core

This is the shared evaluation logic used by both Create and Evaluate modes.

### Step 1: Setup

Create the evaluation output directory:

~~~bash
mkdir -p ~/.claude/cc-review/evaluations/<lens-name>/<timestamp>
~~~

Where `<timestamp>` is ISO-8601 format (e.g., `2026-03-25T14-30`).

Copy the current lens file as a snapshot:

~~~bash
cp ~/.claude/cc-review/lenses/<lens-name>.md \
   ~/.claude/cc-review/evaluations/<lens-name>/<timestamp>/lens-snapshot.md
~~~

### Step 2: Generate and Confirm Personas

Follow the Persona Generation process above. Write the confirmed personas to:
`~/.claude/cc-review/evaluations/<lens-name>/<timestamp>/personas.md`

### Step 3: Dispatch Judge Panel

For each persona, dispatch a parallel subagent (Agent tool) with this prompt
structure:

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
