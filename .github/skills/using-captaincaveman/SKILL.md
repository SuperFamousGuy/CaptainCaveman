---
name: using-captaincaveman
description: Use when starting any conversation — establishes how to find and use the CaptainCaveman skills, requiring skill invocation before ANY response including clarifying questions.
---

<EXTREMELY-IMPORTANT>
If you think there is even a 1% chance a skill in this workspace might apply to what you are doing, you ABSOLUTELY MUST invoke the skill.

IF A SKILL APPLIES TO YOUR TASK, YOU DO NOT HAVE A CHOICE. YOU MUST USE IT.

This is not negotiable. This is not optional. You cannot rationalize your way out of this.
</EXTREMELY-IMPORTANT>

## Instruction priority

CaptainCaveman skills override default system behavior, but **user instructions always take precedence**:

1. **User's explicit instructions** (in chat, in `copilot-instructions.md`, `CLAUDE.md`, `AGENTS.md`, direct requests) — highest priority
2. **CaptainCaveman skills** — override default system behavior where they conflict
3. **Default system prompt** — lowest priority

If `copilot-instructions.md` says "don't use TDD" and a skill says "always use TDD," follow the user's instructions. The user is in control.

## How to access skills

**Copilot cloud agent, Copilot CLI, VS Code agent mode:** Skills under `.github/skills/<name>/SKILL.md` are auto-discovered. When a skill's description matches your task, load and follow it directly. Don't merely read the file — apply its instructions.

**Other Copilot clients:** Agent skills may not auto-load. Skill content is still useful as reference; consult the relevant SKILL.md manually.

## Available skills

Browse `.github/skills/` for the full list. Each `SKILL.md`'s `description:` field tells you when to use it.

## When in doubt: use the skill

- User asks "fix the failing test" → `systematic-debugging` and `test-driven-development` likely apply. Load them.
- User asks "implement this feature" → `brainstorming`, `writing-plans`, and `test-driven-development` likely apply. Load them.
- User asks "review my changes" → `requesting-code-review` likely applies. Load it.
- User asks "is this done?" → `verification-before-completion` applies. Load it.
- User asks "I have these 3 independent bugs to investigate" → `dispatching-parallel-agents` applies. Load it.

**Default action when uncertain: load the skill.** The cost of an unnecessary skill load is small. The cost of skipping a relevant skill is significant.

## What this skill replaces

This is the CaptainCaveman equivalent of `using-superpowers` from [obra/superpowers](https://github.com/obra/superpowers). Adapted to reference Copilot's agent-skill plumbing rather than Claude Code's `Skill` tool, but the enforcement philosophy is unchanged.

---

*This skill is adapted from `using-superpowers` in [obra/superpowers](https://github.com/obra/superpowers) (MIT-licensed, © 2025 Jesse Vincent). See LICENSE-superpowers at the repo root for the original license text.*
