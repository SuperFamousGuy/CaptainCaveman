---
mode: ask
description: >
  Decision guide for choosing which CaptainCaveman skill to use. Tells you WHEN to use
  cavecrew-investigator (locate code), cavecrew-builder (1-2 file edit), or
  cavecrew-reviewer (diff review) versus the standalone caveman-* skills. All cavecrew
  output is caveman-compressed to minimize context usage.
---

Cavecrew = three focused skills that emit caveman output. Same jobs as default Copilot
tasks; difference is output is compressed, so context stays lean across long sessions.

## Which skill to use

| Task | Use |
|---|---|
| "Where is X defined / what calls Y / list uses of Z" | `/cavecrew-investigator` |
| Surgical edit, ≤2 files, scope obvious | `/cavecrew-builder` |
| Review diff, branch, or file for bugs | `/cavecrew-reviewer` |
| Review with prose rationale + alternatives | Copilot Chat directly |
| New feature / 3+ files / cross-cutting refactor | Copilot Chat directly |
| Generate a commit message | `/caveman-commit` |
| Change response verbosity | `/caveman` |
| Review code changes terse | `/caveman-review` |
| Compress a markdown file | `/caveman-compress` |
| See all available skills | `/caveman-help` |

Rule of thumb: **if you want output in 1/3 the tokens, pick a cavecrew skill. If you want prose explanation, use Copilot Chat directly.**

## Output contracts

What to expect from each cavecrew skill:

**`/cavecrew-investigator`**
```
Defs:
- path:line — `symbol` — short note
Refs:
- path:line — `symbol` — short note
totals: 2 defs, 5 refs.
```
Zero hits → `No match.`

**`/cavecrew-builder`**
```
path:line-range — change ≤10 words.
verified: re-read OK.
```
Refusals: `too-big.` / `ambiguous.` (terminal first token).

**`/cavecrew-reviewer`**
```
path:line: 🔴 bug: problem. fix.
path:line: 🟡 risk: problem. fix.
totals: 1🔴 1🟡
```
Zero findings → `No issues.`

## Chaining pattern

Locate → fix → verify (most common):
1. `/cavecrew-investigator` — find the site.
2. `/cavecrew-builder` — edit 1-2 files.
3. `/cavecrew-reviewer` — audit the diff.

## What NOT to do

- Don't use `/cavecrew-builder` when you don't know the file — use `/cavecrew-investigator` first.
- Don't use `/cavecrew-builder` for 3+ file changes — it will refuse with `too-big.`
- Don't use `/cavecrew-reviewer` for architecture opinions — findings only, no rationale.
