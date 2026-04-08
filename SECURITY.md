# Security Policy

## Reporting a Vulnerability

If you discover a security vulnerability in hindsight, please report it privately to:

**security@2389.ai**

Please do not report security vulnerabilities through public GitHub issues.

Include in your report:

- A description of the vulnerability
- Steps to reproduce
- The potential impact
- Any suggested mitigation (optional)

We will acknowledge receipt within a few business days and work with you on a resolution timeline.

## Scope

Hindsight is a Claude Code plugin that reads session log data via [ccvault](https://github.com/2389-research/ccvault) and produces markdown reports. Security concerns in scope include:

- Plugin code that could execute unintended commands or access unintended data
- Lens files that could trigger prompt injection through crafted session content
- Scripts in `scripts/` that could be exploited

Concerns outside the scope of this repo (e.g., Claude Code itself, ccvault, the Claude API) should be reported to the respective projects.
