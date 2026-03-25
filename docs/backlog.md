<!-- ABOUTME: Backlog of future work items for cc-review. -->
<!-- ABOUTME: Tracks deferred tasks that came up during development. -->

# cc-review Backlog

## ccvault prerequisite management
Figure out how to ensure ccvault is installed and synced before cc-review runs.
Options: install script that checks for/installs ccvault, prereq check in Phase 0,
or document as a manual step. Need to handle both `brew install` and `go install` paths.

## Incorporate ccvault skill
The ccvault project ships its own skill (`ccvault:ccvault`) with search patterns,
orient/recall workflows, and a full tool reference. cc-review should reference or
depend on that skill so extraction subagents and lenses can use ccvault's search
playbook effectively (cost ladder, query operators, pagination patterns).

## Lens-writing subskill
Add a subskill to cc-review that guides writing new lenses. Should cover:
- Lens file format (YAML frontmatter + Analysis Instructions + Extraction Hints)
- How to write effective extraction hints
- How to design query strategies for ccvault-backed lenses
- Testing a lens against real session data
- Examples of good vs bad lens design
