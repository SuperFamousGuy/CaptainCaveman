---
mode: ask
description: >
  Quick-reference card for all CaptainCaveman skills. One-shot display.
  Trigger: /caveman-help, "caveman help", "what caveman skills", "how do I use caveman".
---

Display this reference card. One-shot — do NOT change mode or persist anything.

## Communication mode

| Trigger | What it does |
|---|---|
| `/caveman` | Full caveman mode — drop articles, fragments OK, short synonyms. |
| `/caveman lite` | Drop filler/hedging only. Keep articles + full sentences. |
| `/caveman ultra` | Maximum compression. Bare fragments. Arrows for causality (X → Y). |
| "stop caveman" | Revert to normal mode. |

Mode persists for the session until changed.

## Standalone skills

| Skill | Trigger | What it does |
|---|---|---|
| **caveman-commit** | `/caveman-commit` | Terse commit messages. Conventional Commits. ≤50 char subject. |
| **caveman-review** | `/caveman-review` | One-line review findings: `file:L42: 🔴 bug: problem. fix.` |
| **caveman-compress** | `/caveman-compress <file>` | Compress .md files to caveman prose. ~46% token reduction. |
| **caveman-help** | `/caveman-help` | This card. |

## Cavecrew delegation skills

Use these for focused, token-efficient sub-tasks:

| Skill | Trigger | What it does |
|---|---|---|
| **cavecrew-investigator** | `/cavecrew-investigator` | Read-only locator. file:line table for symbols/usages. Never edits. |
| **cavecrew-builder** | `/cavecrew-builder` | Surgical 1-2 file edit. Returns diff receipt. Refuses 3+ files. |
| **cavecrew-reviewer** | `/cavecrew-reviewer` | Severity-tagged diff review. 🔴/🟡/🔵/❓ format. |
| **cavecrew** | `/cavecrew` | Routing guide — which cavecrew skill to use when. |

## Chaining example

```
/cavecrew-investigator  → find where the bug is
/cavecrew-builder       → fix it (1-2 files)
/cavecrew-reviewer      → verify the diff
/caveman-commit         → write the commit message
```

## More

Full docs: https://github.com/SuperFamousGuy/CaptainCaveman
Original Caveman plugin: https://github.com/JuliusBrussee/caveman
