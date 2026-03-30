<!-- ABOUTME: Lens for identifying time sinks, inefficient patterns, and optimization opportunities. -->
<!-- ABOUTME: Focuses on cross-session patterns rather than individual incidents. -->

---
name: workflow-optimization
description: Identify time sinks, inefficient patterns, and optimization opportunities
version: 2
---

# Analysis Instructions

Identify workflow inefficiencies and optimization opportunities. Focus on
patterns across sessions, not individual incidents.
Use `##` for sections, `###` for sub-groupings.

## Time Distribution
- How time was split across projects
- Longest sessions and what drove their length
- Sessions with high turn counts relative to output

## Friction Points
- Tools or commands that failed repeatedly
- Topics where many turns were spent on clarification
- Permission issues, environment problems, or config struggles

## Repeated Patterns
- Similar work done across sessions that could be templated
- Multi-step processes performed manually that could be automated
- Information lookups that happen frequently

## Tool Usage Insights
- Most-used tools and how they were combined
- Subagent usage patterns
- Skills invoked vs could have been invoked

## Recommendations
- Skills to create or modify
- Workflow changes to try
- Tools or configurations to adjust

## Extraction Hints

When summarizing each session, also capture:
- Turn count and estimated time spent
- Any repeated sequences of tool calls (3+ similar patterns)
- Moments where the user expressed frustration or had to repeat themselves
- Failed commands or tool calls and how they were resolved
