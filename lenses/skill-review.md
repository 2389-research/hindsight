<!-- ABOUTME: Lens for auditing skill usage, diagnosing missed triggers, and specifying new skills. -->
<!-- ABOUTME: Produces actionable skill-building briefs with trigger conditions, specs, and ROI analysis. -->

---
name: skill-review
description: Audit skill usage, diagnose missed triggers, and specify new skill candidates
version: 1
---

# Analysis Instructions

Analyze how Claude Code skills were used (or not used) across sessions. The goal
is to produce actionable output for skill builders: what to fix, what to build,
and what to leave alone.

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

### What should the corrected trigger look like?
- Propose a specific trigger pattern (file presence, user message pattern,
  agent action, project state)
- Show the before/after: current trigger vs. proposed trigger
- If the current trigger is unknown, note that and propose what it should be

## Skill Successes

Document skills that worked well — what made them succeed:
- What was the task? What skill fired?
- Why did the trigger work correctly?
- Did the skill's output quality match expectations?
- Is this a reusable pattern (skill composition, pipeline) worth documenting?

Keep this section brief. Success stories earn 2-3 sentences each, not full analyses.

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

Omit this section if no session produced a viable skill candidate.

## Skill Composition Patterns

When multiple skills were used together as a pipeline (e.g., brainstorm → plan →
subagent dispatch), document the composition:
- What skills formed the pipeline?
- How did they hand off to each other?
- Could this pipeline be applied to other task types?
- What task characteristics make this pipeline a good fit?

Omit this section if no multi-skill pipelines were observed.

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
