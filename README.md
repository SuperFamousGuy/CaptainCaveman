# CaptainCaveman
Always-on Caveman voice for GitHub Copilot.

## What is Captain Caveman?
Maybe you're like me: using Copilot instead of Claude Code and finding yourself wanting to be able to leverage the [Caveman plugin for Claude Code](https://github.com/JuliusBrussee/caveman) in your environment.

And if you are like me, maybe you thought to yourself: "Wouldn't this make more sense as a Copilot workspace instructions file so it's always on for free?"

Well, if you are like me, then you're in the right place!

This repo packages Caveman as a single GitHub Copilot workspace instructions file. Drop it into your repo's `.github/` directory and **every Copilot response in that workspace becomes terse Caveman voice**. Task-specific formats (commit messages, code reviews, etc.) layer on top automatically when you ask for them — no slash commands, no toggles, no manual selection.

> Want a toggleable Caveman with intensity levels? Use the original [Caveman plugin for Claude Code](https://github.com/JuliusBrussee/caveman). This repo is the always-on alternative — drop the file in, get Caveman; remove the file, get normal Copilot.

## How it works

CaptainCaveman uses two complementary Copilot mechanisms, wired together so the skills fire **everywhere** without slash commands or manual invocation:

1. **`.github/copilot-instructions.md`** — auto-loaded by every Copilot client on every chat. Holds the **always-on caveman voice** plus an **automatic skill-invocation dispatcher** table that tells Copilot which skill to load for which kind of task.
2. **`.github/skills/<name>/SKILL.md`** — Copilot [agent skills](https://docs.github.com/en/copilot/how-tos/copilot-on-github/customize-copilot/customize-cloud-agent/add-skills). Each skill has a `description` field that tells Copilot when to load it. Bounded task behaviors (commit messages, terse reviews, surgical edits, symbol locators, debugging, TDD, etc.) live here as the **single source of truth** for their content.

### Why the dispatcher exists

Copilot's native agent-skill auto-loading only fires in **cloud agent, Copilot CLI, and VS Code agent mode**. In regular Copilot Chat / inline chat / github.com chat / JetBrains / completions, Copilot doesn't automatically scan `.github/skills/*/SKILL.md`. The dispatcher table in `copilot-instructions.md` closes that gap — Copilot reads it on every chat in any context and follows the "if user about to do X, invoke skill Y" routing.

**Net result:** drop these files into your `.github/` and the skills fire automatically in every Copilot client. No prompts, no slash commands, no toggles.

## Caveman skills

### Always on (in `copilot-instructions.md`)

Caveman voice on every response. Drop articles, filler, pleasantries, hedging. Fragments OK. Code blocks untouched. Technical terms exact.

### Agent skills (in `.github/skills/`)

These trigger automatically when their `description` matches your request. No invocation needed.

| Skill | Use when you... |
|---|---|
| `caveman-commit` | ...ask to write/generate a commit message |
| `caveman-review` | ...ask to review a PR, diff, or file |
| `caveman-compress` | ...ask to compress a `.md` or `.txt` file |
| `caveman-help` | ...ask what skills are available |
| `cavecrew-investigator` | ...ask "where is X defined", "what calls Y", "list uses of Z" |
| `cavecrew-builder` | ...ask for a focused 1-2 file edit |
| `cavecrew-reviewer` | ...want a bounded-scope diff review (investigate→fix→audit flow) |
| `cavecrew` | ...ask which skill to use |

> **Not ported:** `caveman-stats` from the original plugin relies on Claude Code session hooks and has no Copilot equivalent.

## Agent skills (from Superpowers)

Additional skills ported from [obra/superpowers](https://github.com/obra/superpowers) ship as Copilot [agent skills](https://docs.github.com/en/copilot/how-tos/copilot-on-github/customize-copilot/customize-cloud-agent/add-skills) under `.github/skills/`. These work with **Copilot cloud agent, the GitHub Copilot CLI, and agent mode in Visual Studio Code**.

### Skills trigger automatically — you don't need to do anything special

Each skill's `description` field tells Copilot when to load it. Ask your agent to debug a failing test and `systematic-debugging` activates. Ask it to implement a feature and `test-driven-development` and `brainstorming` activate. Your Copilot agent just has Superpowers.

The `using-captaincaveman` meta-skill instructs Copilot to invoke skills aggressively — "if there is even a 1% chance a skill might apply, you MUST invoke it" — matching the enforcement philosophy of upstream Superpowers' `using-superpowers` skill.

### Skill catalog

| Skill | Use when... |
|---|---|
| **using-captaincaveman** | Always — meta-skill that enforces aggressive skill invocation |
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

> **Not ported from Superpowers:** `subagent-driven-development` relies on Claude Code's `Task` tool throughout and doesn't translate cleanly. Use it with [obra/superpowers](https://github.com/obra/superpowers) directly if you need that workflow.

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
