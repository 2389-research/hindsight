<!-- ABOUTME: Lens that treats every human message as a system failure and builds elimination plans to reach zero. -->
<!-- ABOUTME: Interrogates every human intervention, identifies root causes, and proposes permanent fixes. -->

---
name: agent-autonomy
description: Treat every human message as a system failure. Interrogate each one. Build a plan to eliminate all of them.
version: 3
---

# Analysis Instructions

**The target is zero human messages.** Every message the human sent is a failure
of the system — the agent, its tools, its memory, its configuration, or its
judgment. Your job is to explain each failure and propose a permanent fix so
that message never needs to be sent again.

This is not an agent performance review. This is a forensic investigation into
why the human had to be present at all.

The only human messages that survive scrutiny are those where:

1. The human is providing information that exists nowhere the agent can access, AND
2. There is no system change that could make that information accessible, AND
3. The cost of the agent guessing wrong is irreversible

If ANY of those conditions is false, the message is eliminable. Classify it as
such and propose the fix.

On first mention of each project, include a 1-line description so the report is
readable without prior context.

Use `##` for sections, `###` for sub-groupings.

## Human Message Autopsy

This is the centerpiece of the report. For EVERY human message across ALL
sessions, perform an autopsy:

| # | Session | Human Message (quoted or paraphrased) | Root Cause | Fix Type | Fix Description | Eliminable? |
|---|---------|--------------------------------------|------------|----------|-----------------|-------------|

**Root Cause categories** — every message has exactly one:

- `missing-memory`: Agent doesn't remember a user preference it's been told before (e.g., "use pnpm"). Fix: persistent memory.
- `missing-context`: Agent didn't read available files/config (e.g., Tailwind config in project root). Fix: pre-task context loading.
- `permission-seeking`: Agent asked for approval on a reversible action. Fix: act first, report after.
- `complexity-over-simplicity`: Agent tried a sophisticated approach, human had to redirect to simple one. Fix: simplest-first protocol.
- `missing-skill`: Agent lacked a capability and needed human guidance (e.g., device testing). Fix: build the skill.
- `missing-inference`: Agent had all signals to make this decision but didn't connect them (e.g., user works on VW project → tire tools are for VW scene). Fix: inference protocol.
- `human-enjoyment`: Human inserted themselves because they wanted to, not because they had to (e.g., picking colors). Fix: agent proposes defaults, human overrides only if they want to.
- `correction-not-retained`: Agent was corrected earlier in the session and repeated the mistake. Fix: session correction store.
- `cross-session-learning-failure`: Agent has been corrected for this across multiple sessions. Fix: CLAUDE.md rule or persistent memory.
- `trust-deficit`: Human asked "did you check?" or "are you sure?" because trust hasn't been established. Fix: proactive verification.
- `completion-theater`: "Anything else?" / "Looks good" / "Nope" — zero-information exchanges. Fix: stop asking, stop confirming.
- `irreducible`: Genuinely cannot be eliminated. Explain why in detail. This should be RARE — 1-3 per day maximum.

**Fix Type categories:**

- `memory`: Write to persistent memory so the agent never asks again
- `config`: Add to CLAUDE.md or project config
- `skill`: Build a skill or hook that fires automatically
- `protocol`: Decision-making sequence the agent follows
- `inference`: Agent should have connected available signals
- `elimination`: Just stop doing the thing (e.g., stop asking "anything else?")
- `none`: Irreducible — explain why

After the table, provide summary counts:

| Root Cause | Count | % of Total | Total Time Wasted |
|------------|-------|------------|-------------------|

If `irreducible` is more than 10% of messages, you are being too conservative.
Re-examine each one. The bar for irreducible is: the human provided information
that exists NOWHERE the agent could access AND no system change could make it
accessible AND guessing wrong would be irreversible.

## The Compounding Tax

Every unnecessary human message has two costs:

1. **Direct cost**: The time to read, think, type, and context-switch
2. **Compounding cost**: Each intervention trains the human to intervene more and
   the agent to wait for approval more. This is a feedback loop that gets worse
   over time.

For each root cause category with 3+ instances, estimate:

- Direct time cost across the day
- How this pattern changes human behavior in future sessions (e.g., "after 3
  Tailwind violations, the human now supervises all CSS work — estimated 10-15
  min/session of added oversight")
- What it would take to break the cycle (e.g., "3 consecutive violation-free
  sessions to rebuild trust")

Also estimate the **aggregate compounding tax**: if today's patterns continue
unchanged, how much additional human time will be wasted tomorrow? Next week?
The goal is to make the cost of inaction viscerally clear.

## What the Human Should Stop Doing

This section is addressed directly to the human. It should be blunt.

For each human behavior pattern that generates unnecessary messages:

- **The behavior**: What the human does (e.g., "confirms every push to a feature branch")
- **Why it's unnecessary**: What makes this safe to stop
- **What to do instead**: The replacement behavior, if any (e.g., "review the PR at the end instead of confirming each push")
- **Messages eliminated**: How many messages per day this saves
- **Trust prerequisite**: What the agent needs to do first to earn the right
  to ask the human to stop (e.g., "zero framework violations for 3 sessions
  before asking the human to stop supervising CSS")

Be direct. "You confirmed pushes 8 times today. Feature branch pushes are
instantly reversible. Stop confirming them." That's the tone.

But also be fair: if the human's behavior is a rational response to agent
failures, say so. "You supervised CSS because the agent violated Tailwind twice.
That's rational. The fix is on the agent's side first."

## What the Agent Must Fix

For each agent behavior that caused human messages:

- **The behavior**: What the agent did wrong
- **Instance count**: How many times across how many sessions
- **Root cause**: Why the agent does this (permission-seeking trained by RLHF?
  Missing context? Genuine uncertainty?)
- **The fix**: Be specific. Not "the agent should be more autonomous" but "the
  agent should check for `tailwind.config.*` before writing any CSS and use
  Tailwind utilities exclusively when found"
- **Enforcement mechanism**: How to ensure the fix sticks. If your proposed
  mechanism is a CLAUDE.md rule, check the evidence — did the agent already
  violate existing CLAUDE.md rules? If yes, do NOT propose another rule.
  Propose something harder to ignore: a hook, a skill, a pre-commit check.
  If a rule is the only option, acknowledge: "This relies on the same
  compliance mechanism that failed for [X]. Expected violation rate: ~[N]%."

Name all psychological patterns. Every pattern needs a name because names
make them detectable. Look for at least:

- **Approval addiction**: asking permission for reversible actions
- **Complexity signaling**: sophisticated approaches to demonstrate effort
- **Completion theater**: "anything else?" exchanges with zero information
- **Anxiety-driven checking**: human asks "did you verify?" / "are you sure?"
- **Creative insertion**: human makes aesthetic choices they could delegate
- **Premature escalation**: asking for help before exhausting own capabilities
- **Learned helplessness**: becoming MORE permission-seeking after correction
- **Hedging language**: "I could do X or Y" instead of just doing X
- **Preamble padding**: explaining what you're about to do instead of doing it
- **Status narration**: "I'll now do X" before doing X
- **Defensive over-explanation**: over-explaining after a correction to pre-empt criticism

## Elimination Plan

For each root cause category, propose a concrete elimination plan:

### Memory Gaps (missing-memory, cross-session-learning-failure)

List every preference or pattern that should be persisted. Be specific:

- What to remember (e.g., "user's package manager is pnpm")
- Where to store it (persistent memory, CLAUDE.md, project config)
- How to surface it (pre-task context loading, session-start routine)

### Context Failures (missing-context, correction-not-retained)

List every instance where information was available but not used:

- What file/config contained the answer
- Why the agent didn't read it
- What trigger should cause the agent to read it in the future

### Permission-Seeking (permission-seeking, completion-theater, trust-deficit)

For each type of unnecessary question the agent asked:

- The question pattern
- Why it's unnecessary (reversibility analysis)
- The replacement behavior ("just do it and report")
- For trust-deficit: what the agent must do first to earn trust

### Skill Gaps (missing-skill)

For each capability the agent lacked:

- What the skill would do
- What triggers it
- Build vs. buy assessment
- Priority (based on message count it would eliminate)

### Inference Failures (missing-inference, complexity-over-simplicity)

For each case where the agent had signals but didn't connect them:

- What signals were available
- What conclusion they pointed to
- What protocol would ensure the agent connects them next time

## Zero-Message Targets

For each session, state:

- **Current message count**: exact number
- **Target**: the number of messages with all proposed fixes applied. This
  MUST be the true minimum — do not add padding. If your elimination plan
  removes N messages, the target is current minus N.
- **Irreducible remainder**: which specific messages survive and why

For aggregate targets: sum the irreducible remainders across sessions.
That's your target. Do not add a buffer. Do not present conservative and
aggressive variants. One number. Commit to it.

If your aggregate target is more than 20% of current messages, go back and
re-examine your "irreducible" classifications. For a solo developer on
personal projects where all work is reversible, the true irreducible
minimum is typically: initial task request + genuinely novel information
the agent has no way to infer. That's usually 1-3 messages per session.

## Regression Ratchet

For each target:

- **Trigger**: target + 1 message. Not target + 50%. Target + 1.
- **Action**: investigate which fix failed and why
- **Escalation**: if the same regression occurs in 2 consecutive sessions,
  escalate from protocol to enforcement (rule → hook → skill → hard constraint)

Include an aggregate ratchet: if daily total exceeds the aggregate target,
trigger a full review.

## The Meta-Question

End with: "Why did a human have to request this analysis?" If the agent should
be generating this report automatically after each day's sessions and proposing
fixes as commits — say so, and propose the mechanism.

## Extraction Hints

When summarizing each session, capture:

- **Every human message**: exact quote or close paraphrase. Classify as
  decision, confirmation, information, correction, praise, or zero-content.
- **Every agent permission-seeking message**: exact quote or close paraphrase.
  These are the upstream cause of human confirmations.
- For each human message: what information did the agent have? Could it have
  acted without the message?
- Cases where the agent had information (config files, prior corrections,
  error messages) and didn't use it — with time cost
- Self-correction moments: did the agent catch its own mistake?
- Agent initiative: did the agent proactively do something useful without
  being asked?
- Cross-session patterns: has this correction/mistake appeared before?
- Task types: what kind of work was this?
