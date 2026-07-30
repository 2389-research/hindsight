<!-- ABOUTME: Lens for identifying workflow inefficiencies, human-AI collaboration gaps, and infrastructure friction. -->
<!-- ABOUTME: Analyzes both agent behavior and human prompting to optimize the operational collaboration loop. -->

---
name: workflow-optimization
description: Identify workflow inefficiencies, collaboration gaps, and operational friction
version: 4
---

# Analysis Instructions

Analyze workflow efficiency across the full human-AI collaboration loop. This means
examining both agent behavior AND human prompting/intervention patterns. Focus on
cross-session patterns, not individual incidents.

On first mention of each project, include a 1-line description so the report is
readable without prior context.

Use `##` for sections, `###` for sub-groupings.

## Time Distribution

- How time was split across projects
- Longest sessions and what drove their length
- Sessions with high turn counts relative to output

## Friction & Patterns

Combine friction points and repeated patterns into a single section. For each item:

- **What happened**: the observed friction or repeated pattern
- **Evidence**: specific sessions, turn counts, time estimates
- **Severity**: `high` (20+ min waste or 3+ sessions affected), `medium` (5-20 min
  or 2 sessions), `low` (under 5 min or one-off)
- **Systemic or one-off**: is this a recurring pattern or a single incident?

Order by severity (high first). Do NOT include patterns that are explicitly
working well or need no changes. Do NOT include one-off low-severity items
unless they reveal a systemic risk.

## Infrastructure & Reliability

Capture friction from the platform and environment, not just from task execution:

- **Rate limits**: API rate limits, throttling, or quota exhaustion that blocked work
- **Timeouts**: tool call timeouts, command timeouts, network timeouts
- **Connection issues**: MCP server disconnects, device disconnects (ADB, SSH),
  service unavailability
- **Context exhaustion**: sessions that hit context limits — how many continuations,
  how much re-orientation time was lost, what drove context consumption
- **Environment problems**: missing dependencies, wrong versions, permission issues,
  config mismatches

For each item, note the time cost and whether it's a recurring issue or a one-off.

## Human-AI Collaboration

Analyze the human side of the collaboration, not just the agent side.

### Prompt Quality

- Were tasks well-scoped in the opening message? Were constraints front-loaded?
- Contrast: prompts that led to efficient sessions vs. ones that led to churn
- Keep this section data-driven — specific examples, not general observations

### Correction Patterns

- When the human corrected the agent, what triggered it?
- Was it a gentle redirect or a hard stop? Did corrections escalate?
- Could the human have intervened earlier or prevented it with a better prompt?

### Rule Effectiveness

- Were existing CLAUDE.md rules or project conventions violated? Which ones?
- Why didn't the rule prevent the problem? Too vague? Not specific enough?
- Suggested rule improvements (more prescriptive wording, examples, scope)

## Recommendations

Split into typed categories. Each recommendation needs:

- **Evidence**: which sessions, what happened
- **Expected savings**: time estimate per occurrence
- **Frequency**: how often this situation arises (`daily`, `weekly`, `occasional`)
- **Implementation cost**: rough effort to implement (`trivial` = minutes,
  `small` = hours, `medium` = a day, `large` = multiple days)

### Behavioral Rules

For each proposed CLAUDE.md or convention change:

- The specific rule text to add or modify
- Why the current rule (if any) is insufficient
- What agent behavior should change

### Tools to Build

For each proposed skill or automation:

- What it does (clear input → output)
- Why existing tools don't cover it

### Recommendations for the Human

For each proposed change to how the user prompts or interacts:

- What to do differently and when
- What outcome it prevents

Order all recommendations by expected impact (highest first). Do not include
recommendations where the expected savings are under 2 minutes per occurrence
AND frequency is occasional or less.

## Extraction Hints

When summarizing each session, also capture:

- Turn count and estimated time spent
- Any repeated sequences of tool calls (3+ similar patterns)
- Moments where the user expressed frustration or had to repeat themselves
- Failed commands or tool calls and how they were resolved
- **Opening prompt quality**: was the task well-scoped? Were constraints specified?
- **User correction patterns**: what did the user correct, how (gentle vs. hard
  stop), and did corrections escalate over the session?
- **CLAUDE.md rule violations**: did the agent violate any existing rules? Which
  ones and why?
- **Infrastructure friction**: rate limits hit, timeouts, disconnects, context
  exhaustion events, environment setup issues
- **Cross-session frequency signals**: has this friction point appeared in prior
  reports or sessions?
