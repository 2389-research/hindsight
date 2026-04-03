<!-- ABOUTME: Lens for analyzing agent autonomy levels, decision-making gaps, and self-correction opportunities. -->
<!-- ABOUTME: Challenges the human-AI division of labor and proposes protocols for expanding agent authority. -->

---
name: agent-autonomy
description: Analyze agent autonomy, decision-making gaps, and opportunities to expand agent authority
version: 1
---

# Analysis Instructions

Analyze how autonomously the agent operated across sessions. The goal is not just
to identify where the agent failed, but to ask: why was the human in the loop at
all? Every human intervention is either necessary (genuine judgment call) or a
sign that the agent's decision-making should be expanded.

On first mention of each project, include a 1-line description so the report is
readable without prior context.

Use `##` for sections, `###` for sub-groupings.

## Autonomy Scorecard

For each session, assess:

| Session | Project | Autonomy | Human Interventions | Avoidable? |
|---------|---------|----------|---------------------|------------|

**Autonomy levels**:
- `high`: agent executed autonomously with minimal correction. Human mostly
  approved, gave high-level direction, or made genuine judgment calls.
- `medium`: agent did useful work but needed several redirections or corrections
  that it could have avoided.
- `low`: human had to closely manage the agent. Frequent corrections, approach
  changes, or micromanagement required.

For each intervention, classify it:
- **Necessary**: genuine judgment call the agent can't reasonably make (e.g.,
  product design preference, business priority decision)
- **Avoidable**: agent had enough information to make this decision itself
  (e.g., using the right framework, trying simpler approaches first)
- **Preventable**: agent could have avoided the situation entirely with better
  planning or self-monitoring (e.g., reading config before starting, using a
  skill pipeline)

## Gold Standard Analysis

Identify the session with the highest autonomy and best output. For this session:
- What made it work? Was it the task type, the prompt, the skill pipeline, or
  the agent's approach?
- What structural patterns enabled high autonomy? (e.g., brainstorm-then-execute,
  subagent delegation, clear spec before implementation)

Then for each session that scored lower:
- Why didn't it achieve gold-standard autonomy?
- What specific changes would bring it closer? Be concrete — name the skill,
  protocol, or behavior that would help.
- Would applying the gold-standard pattern to this task have worked? Why or why not?

## Information Available but Not Used

Flag every instance where the agent had information in context that it failed
to apply:
- Config files read but ignored (e.g., framework config present but agent
  used raw alternatives)
- Prior context from the same session that wasn't carried forward
- Error messages or logs that contained the answer but the agent tried
  something else
- User corrections from earlier in the session that the agent repeated the
  same mistake after

For each, explain what the agent should have done differently and what
mechanism would ensure it uses available information in the future.

## Decision Protocol Proposals

For each recurring case where the human had to make a decision the agent could
have made, propose a **decision protocol** — not a rule, but a structured
decision-making process the agent should follow.

A decision protocol is different from a rule:
- **Rule**: "Try the simplest approach first" (agent interprets, may ignore)
- **Protocol**: "Before implementing, generate 3 approaches ranked by complexity.
  Implement approach #1. If it fails within 2 tool calls, try #2. If #2 fails,
  stop and ask the user which direction to go."

For each protocol:
- **Situation**: when does this protocol apply?
- **Steps**: the decision sequence the agent should follow
- **Escalation**: at what point should the agent stop and involve the human?
- **Evidence**: which sessions show this protocol would have helped?
- **Expected outcome**: what would the session have looked like with this protocol?

## Self-Correction Opportunities

Identify moments where the agent should have recognized it was going wrong and
self-corrected without human intervention:
- Iterating on the same approach 3+ times without success
- Trying increasingly complex solutions when simpler ones exist
- Repeating a mistake the user already corrected earlier in the session
- Spending disproportionate time on a subtask relative to its importance

For each, propose a **self-monitoring mechanism**:
- What signal should the agent watch for?
- What action should it take when it detects the signal?
- Example: "After 3 failed approaches to the same problem, stop and try the
  absolute simplest version before continuing."

## Autonomy Roadmap

For each task type observed (CSS/visual work, device testing, greenfield
implementation, bug fixing, data migration, etc.):
- **Current state**: how autonomous is the agent for this task type today?
- **Target state**: what would full autonomy look like? What decisions would the
  agent make, and what would the human only need to approve?
- **Gap**: what skills, protocols, or information does the agent need to get there?
- **Next step**: the single most impactful change to move toward the target state

## Extraction Hints

When summarizing each session, also capture:
- Every human intervention: what did the user correct or redirect?
- For each intervention, could the agent have made this decision itself?
  What information did it have?
- Moments where the agent iterated without converging — how many attempts
  before landing on a solution?
- Cases where the agent had information (config files, prior corrections,
  error messages) and didn't use it
- Self-correction moments: did the agent ever catch its own mistake? How?
- Task types: what kind of work was this? (visual, debugging, greenfield,
  data, infrastructure, etc.)
- Agent initiative: did the agent ever proactively do something useful without
  being asked? (e.g., running tests, suggesting improvements, reading context)
