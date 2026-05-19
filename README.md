# CaptainCaveman
Caveman Skills for GitHub Copilot

## What is Captain Caveman?
Maybe you're like me: using Copilot instead of Claude Code and finding yourself wanting to be able to leverage the [Caveman agents for Claude Code](https://github.com/JuliusBrussee/caveman) in your environment.

And if you are like me, maybe you thought to yourself: "Don't these make more sense as skills instead of agents so that you can use them for free, kind of like the [Claude Superpowers plugin](https://github.com/obra/superpowers)?"

Well, if you are like me, then you're in the right place!

This repo contains Skills that produce similar functionality and results as the Caveman agents which you can drop right into your `.github` dir and get started saving on your tokens for free!

## Skills

| Skill | Description |
|---|---|
| `cavecrew-builder` | Surgical 1-2 file editor. Typo fixes, single-function rewrites, mechanical renames. Hard refuses 3+ file scope. |
| `cavecrew-investigator` | Read-only code locator. Find where symbols are defined, what calls them, list all usages. Never edits. |
| `cavecrew-reviewer` | Diff/file reviewer. One finding per line, severity-tagged (🔴 bug / 🟡 risk / 🔵 nit / ❓ question). No praise, no scope creep. |

All three use terse "caveman" output to minimize token usage in follow-up context.

## Installation

Copy the `.github/prompts/` directory into your repository:

```bash
curl -fsSL https://raw.githubusercontent.com/SuperFamousGuy/CaptainCaveman/main/install.sh | bash
```

Or manually copy the files you want:

```
.github/
  prompts/
    cavecrew-builder.prompt.md
    cavecrew-investigator.prompt.md
    cavecrew-reviewer.prompt.md
```

## Usage

In GitHub Copilot Chat, select a skill from the prompt picker or type `/` and search for `cavecrew`:

- **`/cavecrew-builder`** — `Fix the typo on line 42 of auth.ts`
- **`/cavecrew-investigator`** — `Where is the validateToken function defined?`
- **`/cavecrew-reviewer`** — `Review my current diff`

## Credits

Based on the [Caveman](https://github.com/JuliusBrussee/caveman) plugin for Claude Code by [@JuliusBrussee](https://github.com/JuliusBrussee).
