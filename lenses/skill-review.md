<!-- ABOUTME: Lens for auditing skill usage, diagnosing missed triggers, and specifying new skills. -->
<!-- ABOUTME: Produces actionable skill-building briefs with trigger fixes, new skill specs, and pipeline candidates. -->

---
name: skill-review
description: Audit skill usage, diagnose missed triggers, and specify new skill candidates
version: 2
---

# Analysis Instructions

Analyze how Claude Code skills were used (or not used) across sessions. The goal
is to produce actionable output for skill builders: what to fix, what to build,
and what to leave alone.

All findings should be clearly categorized as one of three types:
- **Trigger fix**: a config/rule change to an existing skill (minutes to implement)
- **New skill**: a tool to build (hours to days)
- **Pipeline candidate**: a multi-skill composition to formalize (hours)

On first mention of each project, include a 1-line description so the report is
readable without prior context.

Use `##` for sections, `###` for sub-groupings.

## Skill Inventory

For each session, list:
- **Skills invoked**: which skills fired, and did they produce good results?
- **Skills available but not invoked**: which skills existed and could have helped
  but didn't fire? For each, explain why it was relevant.
- **No skill needed**: sessions where no skill gap was observed

Present as a table with columns: Session | Project | Skills Used | Skills Missed | Notes

## Missed Trigger Analysis

For each skill that should have fired but didn't, analyze in depth:

### What was the trigger signal?
- What did the user say or do that should have activated the skill?
- What project state (files, config, task type) matched the skill's domain?
- Quote the specific user message or describe the agent action that was the signal

### Why didn't it fire?
- Was the trigger condition too narrow for this case?
- Was the skill not loaded in this project context?
- Did the agent not recognize the pattern?
- Was there a competing behavior that took priority?
- **Contrast with a session where the same skill DID fire** (if available) —
  what was different about the prompt, the timing, or the task shape?

### What should the corrected trigger look like?
- Propose a specific trigger pattern (file presence, user message pattern,
  agent action, project state)
- Show the before/after: current trigger vs. proposed trigger
- If the current trigger is unknown, note that and propose what it should be
- **False-positive risk**: could this trigger fire when it shouldn't? What
  guardrails prevent false activation? (e.g., task too small, user already
  specified approach, skill would add overhead without value)

## Skill Successes — and Friction Within Success

Document skills that worked well, but also examine rough edges:
- What was the task? What skill fired? Why did the trigger work correctly?
- **Friction within success**: even when the skill worked, were there wasted
  steps, unnecessary back-and-forth, format mismatches between skill output and
  the next step, or moments where the skill's structure slowed things down?
- Is this a reusable pattern (skill composition, pipeline) worth documenting?

Brief is fine — 3-5 sentences per success. But do not skip the friction question.

## Trigger Fixes

For each existing skill that needs a trigger correction, summarize as a concrete
action item:
- **Skill name**
- **Current trigger** (inferred or documented)
- **Proposed trigger** (specific pattern)
- **False-positive guardrail**
- **Implementation**: what file/config/rule needs to change?
- **Effort**: `trivial` (CLAUDE.md line), `small` (skill file edit), `medium`
  (requires testing across projects)

This section should be a quick-reference list, not a repeat of the Missed Trigger
Analysis above. The analysis section explains *why*; this section says *what to do*.

## New Skill Candidates

For each proposed new skill:

### Specification
- **Name**: proposed skill name
- **What it does**: clear description of input → processing → output
- **Trigger condition**: what signal activates it — be specific (file patterns,
  command patterns, user message patterns, project state)
- **Step sequence**: the concrete steps the skill would execute
- **Decision points**: where does the skill need to branch? What happens on
  failure at each step?
- **Output contract**: what does the skill produce? A file? A summary? An action?

### Evidence
- Which sessions showed this need? How many times?
- Time savings per invocation (with methodology: timestamps, turn counts, or estimate)
- Frequency: how often would this skill fire? (`daily`, `weekly`, `occasional`)

### Build vs. Buy
- Could an existing skill be extended instead of building new?
- Could a shell script, alias, or Makefile target achieve 80% of the value?
- Could a CLAUDE.md rule handle this without a skill?
- What is the implementation cost? (`small` = hours, `medium` = a day,
  `large` = multiple days)

### Priority
- **Expected ROI**: annual time savings vs. build + maintenance cost
- **Rank** relative to other candidates

Push hard to extract candidates. If a session involved a multi-step manual workflow
that the agent repeated, ask whether it should be a skill — even if the time savings
are modest, cognitive overhead reduction matters. Aim for at least 2 candidates from
a full day of sessions.

Omit this section only if genuinely no session produced a viable candidate.

## Pipeline Candidates

When multiple skills were used together as a pipeline (e.g., brainstorm → plan →
subagent dispatch), evaluate whether the composition should be formalized:
- What skills formed the pipeline? How did they hand off?
- **Should this become a single orchestrator skill?** What would it look like?
  What would the trigger be?
- Could this pipeline apply to other task types? Which ones, and which wouldn't
  work?
- What task characteristics make this pipeline a good fit vs. overkill?

Also flag cases where a pipeline *should have been used* but wasn't — sessions
where multiple skills would have composed well but were used individually or not
at all.

Omit this section if no multi-skill pipelines were observed or missed.

## Extraction Hints

When summarizing each session, also capture:
- Every skill invocation: which skill, when in the session, what triggered it
- Moments where a skill could have helped but wasn't used — note the user
  message or agent action that was the missed signal
- Multi-step workflows the agent performed manually that map to existing skills
- Skill failures: skills that fired but produced poor results or were abandoned
- Pipeline patterns: sequences of skill invocations that worked together
- User statements about wanting automation ("I wish...", "this should be...",
  "can you just...")
- **Friction within successful skills**: steps that felt slow, outputs that
  needed manual reformatting, unnecessary questions the skill asked
- **Cross-session frequency signals**: has this skill gap appeared before?
  Is this a recurring miss or a one-off?
