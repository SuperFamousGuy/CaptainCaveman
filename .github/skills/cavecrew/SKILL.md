---
name: cavecrew
description: Use when the user asks "which caveman skill should I use", "how do I use this", "what's the right skill for X", or is mid-workflow and unsure what behavior to apply next. Routes the request to the appropriate caveman/cavecrew skill.
---

# cavecrew

Routing guide for CaptainCaveman task skills.

## Which skill to use

| Task | Apply skill |
|---|---|
| "Where is X defined / what calls Y / list uses of Z" | `cavecrew-investigator` |
| Surgical edit, ≤2 files, scope obvious | `cavecrew-builder` |
| Review diff for bugs (terse, severity-tagged), standalone | `caveman-review` |
| Review diff inside a chained workflow | `cavecrew-reviewer` |
| Review with prose rationale + alternatives | Standard Copilot Chat (no caveman skill) |
| New feature / 3+ files / cross-cutting refactor | Standard Copilot Chat |
| Generate a commit message | `caveman-commit` |
| Compress a markdown file | `caveman-compress` |
| Show all skills | `caveman-help` |

## Chaining pattern (most common)

1. `cavecrew-investigator` → find the site
2. `cavecrew-builder` → fix it
3. `cavecrew-reviewer` → audit the diff
4. `caveman-commit` → write the commit message
