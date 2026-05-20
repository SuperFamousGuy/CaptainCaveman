# CaptainCaveman
Always-on Caveman voice for GitHub Copilot.

## What is Captain Caveman?
Maybe you're like me: using Copilot instead of Claude Code and finding yourself wanting to be able to leverage the [Caveman plugin for Claude Code](https://github.com/JuliusBrussee/caveman) in your environment.

And if you are like me, maybe you thought to yourself: "Wouldn't this make more sense as a Copilot workspace instructions file so it's always on for free?"

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

## Agent skills (from Superpowers)

Additional skills ported from [obra/superpowers](https://github.com/obra/superpowers) ship as Copilot [agent skills](https://docs.github.com/en/copilot/how-tos/copilot-on-github/customize-copilot/customize-cloud-agent/add-skills) under `.github/skills/`. These work with **Copilot cloud agent, the GitHub Copilot CLI, and agent mode in Visual Studio Code**.

Each skill is auto-loaded by name when the description matches your task — no manual invocation required.

| Skill | Use when... |
|---|---|
| **brainstorming** | Starting any creative work — features, components, behavior changes — to explore intent before implementation |
| **dispatching-parallel-agents** | Facing 2+ independent tasks that don't share state or dependencies |
| **executing-plans** | You have a written plan to execute with review checkpoints |
| **finishing-a-development-branch** | Implementation complete, tests pass, ready to merge/PR/clean up |
| **receiving-code-review** | Working through review feedback with rigor instead of performative agreement |
| **requesting-code-review** | Before merging — to verify the work meets requirements |
| **systematic-debugging** | Any bug, test failure, or unexpected behavior, before proposing fixes |
| **test-driven-development** | Implementing any feature or bugfix — write the test first |
| **using-git-worktrees** | Starting feature work that needs isolation from the current workspace |
| **verification-before-completion** | About to claim work is complete — run the verification first |
| **writing-plans** | You have a spec or requirements for a multi-step task, before touching code |
| **writing-skills** | Creating, editing, or verifying agent skills |

> **Not ported from Superpowers:** `subagent-driven-development` and `using-superpowers` rely on Claude Code's `Task` and `Skill` tool plumbing too deeply to translate cleanly. Use them with [obra/superpowers](https://github.com/obra/superpowers) directly if you need that workflow.

Skill content is preserved verbatim from upstream (MIT-licensed, © 2025 Jesse Vincent). See `LICENSE-superpowers` for the original license.

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

> **Run this from the root of your repository.** The installer writes to `.github/copilot-instructions.md` relative to the current working directory. If you run it from a subdirectory, a new `.github/` folder will be created there instead of in the one Copilot reads — and the install will be silently ineffective.

```bash
curl -fsSL https://raw.githubusercontent.com/SuperFamousGuy/CaptainCaveman/main/install.sh | bash
```

The installer is **additive and non-destructive** — it never overwrites your existing instructions:

- **No existing file?** Creates `.github/copilot-instructions.md` with the CaptainCaveman block wrapped in marker comments.
- **Existing file without CaptainCaveman?** Appends the marker-wrapped block to the end. Your existing content stays untouched at the top.
- **Existing file with CaptainCaveman already installed?** Updates the content between the markers in place. Anything outside the markers is preserved. Re-running is idempotent.
- **Broken state (only one marker)?** Refuses to modify the file and exits with an error so you can fix it manually.

You can also just copy `.github/copilot-instructions.md` from this repo into your repo's `.github/` directory yourself.

To uninstall: delete the file (if CaptainCaveman is the only thing in it), or remove everything between the `<!-- BEGIN CAPTAINCAVEMAN -->` and `<!-- END CAPTAINCAVEMAN -->` markers.

## Credits

Based on the [Caveman](https://github.com/JuliusBrussee/caveman) plugin for Claude Code by [@JuliusBrussee](https://github.com/JuliusBrussee).
