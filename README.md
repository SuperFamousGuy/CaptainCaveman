# CaptainCaveman
Always-on Caveman voice for GitHub Copilot.

## What is Captain Caveman?
Maybe you're like me: using Copilot instead of Claude Code and finding yourself wanting to be able to leverage the [Caveman plugin for Claude Code](https://github.com/JuliusBrussee/caveman) in your environment.

And if you are like me, maybe you thought to yourself: "Wouldn't this make more sense as a Copilot workspace instructions file so it's always on for free, kind of like the [Claude Superpowers plugin](https://github.com/obra/superpowers)?"

Well, if you are like me, then you're in the right place!

This repo packages Caveman as a single GitHub Copilot workspace instructions file. Drop it into your repo's `.github/` directory and **every Copilot response in that workspace becomes terse Caveman voice**. Task-specific formats (commit messages, code reviews, etc.) layer on top automatically when you ask for them — no slash commands, no toggles, no manual selection.

> Want a toggleable Caveman with intensity levels? Use the original [Caveman plugin for Claude Code](https://github.com/JuliusBrussee/caveman). This repo is the always-on alternative — drop the file in, get Caveman; remove the file, get normal Copilot.

## How it works

Everything lives in one file: `.github/copilot-instructions.md`. GitHub Copilot auto-loads this on every chat in the workspace.

- **Caveman voice is always on.** Every response drops articles, filler, hedging, pleasantries. Technical substance preserved exactly. Applies to every Copilot reply.
- **Task formats layer on top.** When you ask for a commit message, the response uses Conventional Commits format. When you ask to review a diff, the response uses one-line severity-tagged findings. These trigger from user intent — you don't have to invoke them by name.

## Behaviors included

### Always on

Caveman voice on every response. Drop articles, filler, pleasantries, hedging. Fragments OK. Code blocks untouched. Technical terms exact.

### Triggered by intent

| Behavior | Triggered when you... | What you get |
|---|---|---|
| Commit messages | ...ask to write or generate a commit message | Conventional Commits format, ≤50 char subject, body only when "why" isn't obvious |
| Code review | ...ask to review a PR/diff/file | One-line severity-tagged findings: `file:L42: 🔴 bug: problem. fix.` |
| Markdown compression | ...ask to compress a `.md` file | Prose reduced ~46%, code/structure preserved |
| Symbol locator | ...ask "where is X defined", "what calls Y", "list uses of Z" | `file:line` table, no prose explanation |
| Surgical edit | ...ask for a focused 1-2 file change | Diff receipt; refuses 3+ file scope with `too-big.` |
| Diff review (chained) | ...ask for terse review in an investigate→fix→audit flow | Same severity-tagged format, bounded-scope contract |
| Routing help | ...ask "which behavior should I use" or "how do I do X" | Quick routing table |
| Reference card | ...ask what's available | Inline summary of everything |

> **Not ported:** `caveman-stats` from the original plugin relies on Claude Code session hooks and has no Copilot equivalent.

## Typical workflow

Just describe what you want. The right format applies automatically:

```
You: "Where's the validateToken function defined?"
Copilot: [returns file:line table, no prose]

You: "Fix the off-by-one in auth.ts:L42"
Copilot: [edits the file, returns a diff receipt]

You: "Review my current diff"
Copilot: [returns one-line severity-tagged findings]

You: "Write the commit message"
Copilot: [returns a ready-to-paste Conventional Commit]
```

## Installation

```bash
curl -fsSL https://raw.githubusercontent.com/SuperFamousGuy/CaptainCaveman/main/install.sh | bash
```

Or manually copy `.github/copilot-instructions.md` into your repo's `.github/` directory.

To turn Caveman off: delete the file.

## Credits

Based on the [Caveman](https://github.com/JuliusBrussee/caveman) plugin for Claude Code by [@JuliusBrussee](https://github.com/JuliusBrussee).
