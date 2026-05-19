# CaptainCaveman
Caveman Skills for GitHub Copilot

## What is Captain Caveman?
Maybe you're like me: using Copilot instead of Claude Code and finding yourself wanting to be able to leverage the [Caveman agents for Claude Code](https://github.com/JuliusBrussee/caveman) in your environment.

And if you are like me, maybe you thought to yourself: "Don't these make more sense as skills instead of agents so that you can use them for free, kind of like the [Claude Superpowers plugin](https://github.com/obra/superpowers)?"

Well, if you are like me, then you're in the right place!

This repo contains Skills that produce similar functionality and results as the Caveman plugin, packaged as a Copilot workspace instructions file. Drop it into your repo's `.github/` directory and Copilot will auto-activate the right skill based on what you ask — no slash commands required.

## How it works

The skills live in a single file: `.github/copilot-instructions.md`. GitHub Copilot auto-loads this on every chat in the workspace. Each skill section inside has a **Trigger** clause telling Copilot when to apply that behavior based on your intent.

Ask "write a commit" → caveman-commit fires. Ask "review this diff" → caveman-review fires. Say "caveman mode" → terse responses turn on for the session. No slash commands, no manual selection.

## Skills

### Communication mode

| Skill | Triggered by | What it does |
|---|---|---|
| **caveman** | "caveman mode", "be brief", "less tokens" | Activates terse responses. Levels: lite, full (default), ultra. |

Stays active until you say "stop caveman" or "normal mode".

### Standalone task skills

| Skill | Triggered by | What it does |
|---|---|---|
| **caveman-commit** | Asking to write/generate a commit message | Conventional Commits format, ≤50 char subject |
| **caveman-review** | "review this PR", "review the diff", "audit this file" | One-line severity-tagged findings: `🔴 bug` / `🟡 risk` / `🔵 nit` / `❓ q` |
| **caveman-compress** | "compress this file" with a `.md` target | Reduces markdown prose ~46% while preserving code/structure |
| **caveman-help** | "what caveman skills are there", "show me what's available" | Quick reference card |

### Cavecrew skills (focused, token-efficient sub-tasks)

| Skill | Triggered by | What it does |
|---|---|---|
| **cavecrew-investigator** | "where is X defined", "what calls Y", "list uses of Z" | Read-only locator. Returns `file:line` table. Never edits. |
| **cavecrew-builder** | Surgical edit requests with obvious 1-2 file scope | Returns diff receipt. Hard refuses 3+ file scope. |
| **cavecrew-reviewer** | Focused diff review in a chained workflow | Same emoji format as caveman-review, bounded-scope contract |
| **cavecrew** | "which skill should I use", "how do I use this" | Routing guide |

> **Note:** `caveman-stats` from the original Caveman plugin relies on Claude Code session hooks and has no Copilot equivalent.

## Typical workflow

Just describe what you want — Copilot picks the right skill:

```
You: "Where's the validateToken function defined?"
→ cavecrew-investigator fires, returns file:line table

You: "Fix the off-by-one in auth.ts:L42"
→ cavecrew-builder fires, returns diff receipt

You: "Review my current diff"
→ caveman-review fires, returns severity-tagged findings

You: "Write the commit message"
→ caveman-commit fires, returns ready-to-paste Conventional Commit
```

## Installation

```bash
curl -fsSL https://raw.githubusercontent.com/SuperFamousGuy/CaptainCaveman/main/install.sh | bash
```

Or manually copy `.github/copilot-instructions.md` into your repo's `.github/` directory.

## Credits

Based on the [Caveman](https://github.com/JuliusBrussee/caveman) plugin for Claude Code by [@JuliusBrussee](https://github.com/JuliusBrussee).
