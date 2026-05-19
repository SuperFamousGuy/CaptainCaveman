# CaptainCaveman
Caveman Skills for GitHub Copilot

## What is Captain Caveman?
Maybe you're like me: using Copilot instead of Claude Code and finding yourself wanting to be able to leverage the [Caveman agents for Claude Code](https://github.com/JuliusBrussee/caveman) in your environment.

And if you are like me, maybe you thought to yourself: "Don't these make more sense as skills instead of agents so that you can use them for free, kind of like the [Claude Superpowers plugin](https://github.com/obra/superpowers)?"

Well, if you are like me, then you're in the right place!

This repo contains Skills that produce similar functionality and results as the Caveman plugin, packaged as a Copilot workspace instructions file. Drop it into your repo's `.github/` directory and **caveman voice turns on permanently** for that workspace. Task skills (commit messages, reviews, etc.) auto-activate based on what you ask — no slash commands, no toggles.

> Want a toggleable caveman with intensity levels? Use the original [Caveman plugin for Claude Code](https://github.com/JuliusBrussee/caveman). This repo is the always-on alternative — drop the file in, get caveman; remove it, get normal Copilot.

## How it works

The skills live in a single file: `.github/copilot-instructions.md`. GitHub Copilot auto-loads this on every chat in the workspace.

- **Caveman voice is always on.** Every response is terse, no fluff, technical substance preserved. No way to toggle from inside chat.
- **Task skills layer on top.** Ask "write a commit" → caveman-commit format applies. Ask "review this diff" → caveman-review format applies. These trigger based on user intent.

## Skills

### Always-on: caveman voice

Drop articles, filler, hedging, pleasantries. Fragments OK. Technical terms exact. Code unchanged. Applied to every response in the workspace.

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
