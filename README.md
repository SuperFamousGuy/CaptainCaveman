# CaptainCaveman
Always-on Caveman voice + Superpowers engineering skills for GitHub Copilot.

## What is CaptainCaveman?

CaptainCaveman = drop-in workspace bundle for GitHub Copilot. Ports two Claude Code plugins into Copilot-native form:

- **Caveman** (terse-output mode) — from [JuliusBrussee/caveman](https://github.com/JuliusBrussee/caveman)
- **Superpowers** (engineering-workflow skills) — from [obra/superpowers](https://github.com/obra/superpowers)

Two artifacts:

| Path | Role |
|---|---|
| `.github/copilot-instructions.md` | Always-on caveman voice + dispatcher table mapping user intent → skill name |
| `.github/skills/<name>/SKILL.md` × 21 | Skill bodies as Copilot agent skills |

Net effect: drop files into `.github/`, Copilot becomes terse on every response and gains 21 task behaviors — commit messages, code review, symbol locator, surgical edits, systematic debugging, TDD, plan writing, parallel-task dispatch, worktree workflow, and more. Skills auto-fire on intent. No slash commands, no toggles, no prompting. Remove files → normal Copilot.

The pitch in one line: **your coding agent just has Caveman and Superpowers.**

> Want a toggleable Caveman with intensity levels instead of always-on? Use the original [Caveman plugin for Claude Code](https://github.com/JuliusBrussee/caveman).

## How it works

Two routes to skill invocation, same SKILL.md bodies as source of truth:

- **Native agent-skill auto-load** — Copilot cloud agent, the Copilot CLI, and VS Code agent mode read `.github/skills/<name>/SKILL.md` directly and load skills whose `description` matches the task.
- **Dispatcher table in `copilot-instructions.md`** — covers every other Copilot client (regular Chat, JetBrains, inline, github.com chat, completions). Copilot reads the dispatcher on every chat and follows the "if user about to do X, invoke skill Y" routing.

The always-on caveman voice also lives in `copilot-instructions.md` and applies to every response in every Copilot client.

The `using-captaincaveman` meta-skill enforces the aggressive-invocation philosophy from upstream Superpowers — *"if there is even a 1% chance a skill might apply, you MUST invoke it."*

## Skills

### Always on (from `copilot-instructions.md`)

Caveman voice on every response. Drop articles, filler, pleasantries, hedging. Fragments OK. Code blocks untouched. Technical terms exact. Auto-clarity exception for security warnings, destructive ops, and any place where compression risks misreading.

### Caveman / cavecrew skills (8)

Ported from [JuliusBrussee/caveman](https://github.com/JuliusBrussee/caveman). Bounded, format-specific outputs.

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

### Superpowers skills (13)

Ported from [obra/superpowers](https://github.com/obra/superpowers). Engineering-workflow discipline.

| Skill | Use when you... |
|---|---|
| `using-captaincaveman` | Always — meta-skill that enforces aggressive skill invocation |
| `brainstorming` | ...start any creative work, to explore intent before implementation |
| `dispatching-parallel-agents` | ...face 2+ independent tasks that don't share state or dependencies |
| `executing-plans` | ...have a written plan to execute with review checkpoints |
| `finishing-a-development-branch` | ...have implementation complete and tests passing, ready to merge/PR |
| `receiving-code-review` | ...work through review feedback with rigor instead of performative agreement |
| `requesting-code-review` | ...are about to merge and want the work verified against requirements |
| `systematic-debugging` | ...hit any bug, test failure, or unexpected behavior, before proposing fixes |
| `test-driven-development` | ...are about to write implementation code for any feature or bugfix |
| `using-git-worktrees` | ...start feature work that needs isolation from the current workspace |
| `verification-before-completion` | ...are about to claim work is complete — run the verification first |
| `writing-plans` | ...have a spec or requirements for a multi-step task, before touching code |
| `writing-skills` | ...are creating, editing, or verifying an agent skill |

> **Not ported from Superpowers:** `subagent-driven-development` relies on Claude Code's `Task` tool throughout and doesn't translate cleanly. Use it with [obra/superpowers](https://github.com/obra/superpowers) directly if you need that workflow.

Skill content preserved verbatim from upstream (MIT, © 2025 Jesse Vincent). See `LICENSE-superpowers` for the original license text.

## Typical workflow

Just describe what you want — the right format applies automatically:

```
You: "Where's the validateToken function defined?"
Copilot: [cavecrew-investigator returns a file:line table, no prose]

You: "Fix the off-by-one in auth.ts:L42"
Copilot: [test-driven-development engages, cavecrew-builder edits the file, returns receipt]

You: "Review my current diff"
Copilot: [caveman-review returns one-line severity-tagged findings]

You: "Is this ready to merge?"
Copilot: [verification-before-completion + finishing-a-development-branch run their checks]

You: "Write the commit message"
Copilot: [caveman-commit returns a ready-to-paste Conventional Commit]
```

## Installation

> **Run this from the root of your repository.** The installer writes paths relative to the current working directory. If you run it from a subdirectory, a stray `.github/` folder will be created there instead of in the one Copilot reads — and the install will be silently ineffective.

```bash
curl -fsSL https://raw.githubusercontent.com/SuperFamousGuy/CaptainCaveman/main/install.sh | bash
```

The installer does two things:

### Step 0 — Legacy cleanup

Removes leftover files from the earliest (PR #2) installer iteration that used slash-invoked prompt files:

- Deletes any `.github/prompts/{caveman,cavecrew}-*.prompt.md` files from that era.
- If `.github/prompts/` is then empty, removes the directory.
- No-op when those files aren't present.

### Part 1 — `.github/copilot-instructions.md` (additive, non-destructive)

Never overwrites your *user-authored* instructions. Manages a marker-delimited CaptainCaveman block inside the file. Cases:

- **No existing file?** Creates it with the CaptainCaveman block wrapped in marker comments.
- **Pre-marker, fully-managed legacy file?** Detected when the file's first non-blank line starts with `# CaptainCaveman` (the H1 used by the original installer before markers existed). The whole file is replaced with the current marker-wrapped Superpowered block.
- **Existing file without CaptainCaveman content?** Appends the marker-wrapped block to the end. Your existing content stays untouched at the top.
- **Existing file with CaptainCaveman already installed (markers present)?** Updates the content between the markers in place. Anything outside the markers is preserved. Re-running is idempotent.
- **Broken state (only one marker)?** Refuses to modify the file and exits with a clear error.

### Part 2 — `.github/skills/<name>/SKILL.md` (best-effort)

Enumerates skill files via the GitHub git-trees API and downloads each one, including supporting files like `brainstorming/scripts/*` (visual-companion server + helpers), `systematic-debugging/find-polluter.sh`, and the worked examples under `writing-skills/examples/`. Requires `python3` for JSON parsing.

- If `python3` is missing, Part 2 is skipped with a warning. Part 1 still completes — you get the always-on voice and the dispatcher; agent-skill auto-load in agent contexts won't have local files to read, but the dispatcher still works.
- If the GitHub API is rate-limited or unreachable, Part 2 warns and skips. Part 1 still completes.
- Per-file download failures are reported but don't abort the install — re-run to retry.
- After download, the installer restores the executable bit on every `.sh` file under `.github/skills/` (`curl -o` doesn't preserve it). The visual-companion `start-server.sh` / `stop-server.sh` and `find-polluter.sh` are runnable as documented in their SKILL.md.

### Manual install

Copy `.github/copilot-instructions.md` and the `.github/skills/` tree from this repo into your repo's `.github/` directory yourself.

## Path conventions

A few skills assume specific paths under your repo root. These are created on first use by the skill (no installer setup needed), but it's worth knowing they exist:

- `docs/plans/YYYY-MM-DD-<feature>.md` — where `writing-plans` saves implementation plans
- `docs/specs/YYYY-MM-DD-<topic>-design.md` — where `brainstorming` saves design specs

If your repo already uses different conventions for plan/spec docs, override these in your workspace instructions and the skills will follow your lead (skills explicitly note user preferences take precedence).

## Project type detection

`using-git-worktrees` (Step 3 — project setup) and `finishing-a-development-branch` (Step 1 — verify tests) both auto-detect the project type from files in the repo root and run the appropriate install/test command. Supported out of the box:

| Files present | Setup command | Test command |
|---|---|---|
| `package.json` | `npm install` | `npm test` |
| `Cargo.toml` | `cargo build` | `cargo test` |
| `requirements.txt` / `pyproject.toml` | `pip install` / `poetry install` | `pytest` |
| `go.mod` | `go mod download` | `go test ./...` |
| `*.sln` / `*.csproj` / `*.fsproj` / `*.vbproj` / `global.json` | `dotnet restore` | `dotnet test` |
| `Gemfile` | `bundle install` | `bundle exec rspec` |
| `composer.json` | `composer install` | `vendor/bin/phpunit` |
| `pom.xml` / `build.gradle*` | `mvn dependency:resolve` / `./gradlew dependencies` | `mvn test` / `./gradlew test` |

Polyglot/monorepo? Each detected ecosystem runs its own setup and tests.

`writing-plans` complements this with **language-agnostic task templates plus worked test-runner examples** for Python/pytest, .NET/xUnit, Node/Vitest, Rust/cargo, and Go — so plan steps land with the right `pytest …` / `dotnet test --filter …` / `npm test …` invocation for your stack instead of a default Python pattern.

## Security considerations

The `brainstorming` skill's optional **visual-companion** mode spins up a local web server (`brainstorming/scripts/start-server.sh`) so you can preview HTML mockups in a browser. By default it binds to `127.0.0.1` and is safe.

If you switch it to `--host 0.0.0.0` (sometimes needed in remote/containerized setups), **the server becomes reachable from every network interface on the host with no authentication**. Only do this on a trusted network. For remote work, prefer **SSH port forwarding** (`ssh -L 8765:127.0.0.1:8765 user@remote-host`) and leave the server bound to localhost. See `visual-companion.md` in the skill directory for the full security note and safer alternatives.

## Uninstall

Delete the file (if CaptainCaveman is the only thing in `copilot-instructions.md`), or remove everything between the `<!-- BEGIN CAPTAINCAVEMAN -->` and `<!-- END CAPTAINCAVEMAN -->` markers. Optionally remove the `.github/skills/` tree.

## Credits

- [Caveman](https://github.com/JuliusBrussee/caveman) plugin for Claude Code by [@JuliusBrussee](https://github.com/JuliusBrussee) — source of caveman voice and the caveman/cavecrew task skills.
- [Superpowers](https://github.com/obra/superpowers) plugin for Claude Code by [@obra](https://github.com/obra) (Jesse Vincent) — source of the 13 engineering-workflow skills. Content preserved verbatim under the upstream MIT license (`LICENSE-superpowers`).
