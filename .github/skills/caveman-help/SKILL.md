---
name: caveman-help
description: Use when the user asks "what caveman skills are there", "caveman help", "show me what's available", or "list the skills". Displays a one-shot reference card of the CaptainCaveman skill catalog.
---

# caveman-help

Display this reference card. One-shot — do NOT change mode or persist anything.

## Always on (in `.github/copilot-instructions.md`)

Caveman voice — every Copilot response in this workspace is terse. No toggle, no slash command. Drop the file from `.github/` if you want it off; use the original [Caveman plugin](https://github.com/JuliusBrussee/caveman) if you want a toggleable version with intensity levels.

## Standalone task skills

| Skill | What it does |
|---|---|
| `caveman-commit` | Terse Conventional Commits messages. ≤50-char subject. |
| `caveman-review` | One-line severity-tagged review findings. |
| `caveman-compress` | Compresses `.md` / `.txt` files to caveman prose. |
| `caveman-help` | This card. |

## Cavecrew (token-efficient sub-tasks)

| Skill | What it does |
|---|---|
| `cavecrew-investigator` | Read-only `file:line` locator. Never edits. |
| `cavecrew-builder` | Surgical 1-2 file edit. Returns diff receipt. |
| `cavecrew-reviewer` | Bounded-scope diff review. Same severity tags as `caveman-review`. |
| `cavecrew` | Routing guide. |

## Superpowers (from `obra/superpowers`)

Additional agent skills under `.github/skills/`: brainstorming, dispatching-parallel-agents, executing-plans, finishing-a-development-branch, receiving-code-review, requesting-code-review, systematic-debugging, test-driven-development, using-captaincaveman, using-git-worktrees, verification-before-completion, writing-plans, writing-skills.

## Docs

Full docs: https://github.com/SuperFamousGuy/CaptainCaveman
