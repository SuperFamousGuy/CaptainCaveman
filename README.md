# CaptainCaveman
Caveman Skills for GitHub Copilot

## What is Captain Caveman?
Maybe you're like me: using Copilot instead of Claude Code and finding yourself wanting to be able to leverage the [Caveman agents for Claude Code](https://github.com/JuliusBrussee/caveman) in your environment.

And if you are like me, maybe you thought to yourself: "Don't these make more sense as skills instead of agents so that you can use them for free, kind of like the [Claude Superpowers plugin](https://github.com/obra/superpowers)?"

Well, if you are like me, then you're in the right place!

This repo contains Skills that produce similar functionality and results as the Caveman plugin which you can drop right into your `.github` dir and get started saving on your tokens for free!

## Skills

### Communication mode

| Skill | Trigger | What it does |
|---|---|---|
| **caveman** | `/caveman` | Activates terse caveman communication mode. Levels: `lite`, `full` (default), `ultra`. ~75% token reduction. |
| **caveman-help** | `/caveman-help` | Quick-reference card for all skills and triggers. |

### Standalone task skills

| Skill | Trigger | What it does |
|---|---|---|
| **caveman-commit** | `/caveman-commit` | Generates terse Conventional Commits messages. Subject ≤50 chars, body only when needed. |
| **caveman-review** | `/caveman-review` | One-line code review findings. `file:L42: 🔴 bug: problem. fix.` |
| **caveman-compress** | `/caveman-compress <file>` | Compresses `.md` files to caveman prose. ~46% input token reduction. |

### Cavecrew delegation skills

Use these for focused, token-efficient sub-tasks. All output is caveman-compressed.

| Skill | Trigger | What it does |
|---|---|---|
| **cavecrew** | `/cavecrew` | Routing guide — which cavecrew skill to use for which task. |
| **cavecrew-investigator** | `/cavecrew-investigator` | Read-only code locator. Returns `file:line` table for symbols/usages. Never edits. |
| **cavecrew-builder** | `/cavecrew-builder` | Surgical 1-2 file editor. Returns diff receipt. Hard refuses 3+ file scope. |
| **cavecrew-reviewer** | `/cavecrew-reviewer` | Severity-tagged diff review. 🔴 bug / 🟡 risk / 🔵 nit / ❓ question format. |

> **Note:** `caveman-stats` from the original Caveman plugin relies on Claude Code session hooks and has no Copilot equivalent.

## Typical workflow

```
/cavecrew-investigator  → find where the bug is (file:line table)
/cavecrew-builder       → fix it (1-2 files, returns diff receipt)
/cavecrew-reviewer      → audit the diff (severity-tagged findings)
/caveman-commit         → generate the commit message
```

Or for quick tasks:
```
/caveman-review         → review current diff inline
/caveman-commit         → write the commit message
```

## Installation

Copy the `.github/prompts/` directory into your repository:

```bash
curl -fsSL https://raw.githubusercontent.com/SuperFamousGuy/CaptainCaveman/main/install.sh | bash
```

Or manually copy the files you want from `.github/prompts/`.

## Usage

In GitHub Copilot Chat, type `/` and search for `caveman` or `cavecrew` to see all available skills.

## Credits

Based on the [Caveman](https://github.com/JuliusBrussee/caveman) plugin for Claude Code by [@JuliusBrussee](https://github.com/JuliusBrussee).
