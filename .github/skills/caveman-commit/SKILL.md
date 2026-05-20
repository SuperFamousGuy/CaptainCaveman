---
name: caveman-commit
description: Use when the user asks to write, generate, or draft a commit message, or stages changes and asks what to commit. Produces a terse Conventional Commits message with ≤50-char subject and a body only when the "why" isn't obvious from the diff.
---

# caveman-commit

Write commit messages terse and exact. Conventional Commits format. No fluff. Why over what.

## Subject line

- `<type>(<scope>): <imperative summary>` — `<scope>` optional
- Types: `feat`, `fix`, `refactor`, `perf`, `docs`, `test`, `chore`, `build`, `ci`, `style`, `revert`
- Imperative mood: "add", "fix", "remove" — not "added", "adds", "adding"
- ≤50 chars when possible, hard cap 72
- No trailing period

## Body (only if needed)

- Skip entirely when subject is self-explanatory
- Add body only for: non-obvious *why*, breaking changes, migration notes, linked issues
- Wrap at 72 chars
- Bullets `-` not `*`
- Reference issues at end: `Closes #42`

## Never include

- "This commit does X", "I", "we", "now", "currently" — the diff says what
- AI attribution (e.g. "Generated with Copilot")
- Emoji (unless project convention requires)
- File names already covered by scope

## Example with non-obvious why

```
feat(api): add GET /users/:id/profile

Mobile client needs profile data without full user payload
to reduce LTE bandwidth on cold-launch screens.

Closes #128
```

## Always include body for

Breaking changes, security fixes, data migrations, reverts. Future debuggers need the context.

## Boundaries

Outputs the message ready to paste. Does NOT run `git commit`, stage files, or amend.
