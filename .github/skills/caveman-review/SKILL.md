---
name: caveman-review
description: Use when the user asks to review a PR, diff, file, or audit code changes. Produces one line per finding with severity tag (🔴 bug / 🟡 risk / 🔵 nit / ❓ q), exact line numbers, and a concrete fix. No praise, no scope creep.
---

# caveman-review

One line per finding. Location, problem, fix. No throat-clearing, no praise.

## Format

`<file>:L<line>: <emoji> <severity>: <problem>. <fix>.`

## Severity tags

| Tag | Use for |
|---|---|
| 🔴 bug | Wrong output, crash, security hole, data loss |
| 🟡 risk | Edge case, race, leak, perf cliff, missing guard |
| 🔵 nit | Style, naming, micro-perf — only if user asked thorough |
| ❓ q | Genuine question, need author intent |

## Drop

- "I noticed that...", "It seems like...", "You might want to consider..."
- Restating what the diff shows
- Hedging ("perhaps", "maybe", "I think") — if unsure use `❓ q:`

## Keep

- Exact line numbers
- Symbol names in backticks
- Concrete fixes (not "consider refactoring")
- The *why* if non-obvious

## Examples

```
auth.ts:L42: 🔴 bug: user can be null after `.find()`. Add guard before `.email`.
client.ts:L23: 🟡 risk: no retry on 429. Wrap in `withBackoff(3)`.
utils.ts:L7: ❓ q: why duplicate `.trim()` here?
totals: 1🔴 1🟡 1❓
```

Zero findings → `LGTM.`
File order, ascending line numbers within file.

## Auto-clarity

Security findings, architectural disagreements, onboarding contexts → write a full
paragraph first, then resume terse for the rest.

## Boundaries

Findings only. Does not write the fix. Does not approve or request-changes.
For the same format scoped as a delegated subagent output, use `cavecrew-reviewer`.
