# Anthropic skill-authoring best practices (summary + link)

This file is a paraphrased summary of Anthropic's "Skill authoring best practices" documentation.

**Canonical source:** [Anthropic docs — Skill authoring best practices](https://docs.anthropic.com/en/docs/agents-and-tools/skills/best-practices)
*(If the URL has moved, search `docs.anthropic.com` for "skill authoring best practices".)*

The principles below are paraphrased pointers, not Anthropic's wording. For exact guidance, read the source above.

---

## Make skills discoverable

- The `description` field is the discovery surface. It's what the agent reads to decide whether to load your skill. Write it as **triggering conditions** (start with "Use when…") — not as a workflow summary.
- Avoid summarizing the steps in the description; if the description fully describes the procedure, the agent will follow the description and skip the body.
- Cover concrete symptoms, error messages, and synonyms a user might phrase the problem with.

## Write skills like reference documentation

- Skills are reusable references, not narratives of how you solved a problem once.
- Lead with overview + when-to-use, then the core pattern, then a quick-reference table, then implementation details.
- Put heavy reference content (long API docs, large code samples) in supporting files alongside `SKILL.md` rather than inline.

## Use small, focused skills over large ones

- One responsibility per skill. Cross-reference related skills by name.
- A skill that tries to cover every adjacent topic loses discoverability and pressure-tests poorly.

## Test skills like code

- Don't ship a skill until you've seen an agent fail without it.
- Run baseline pressure scenarios with no skill loaded. Document the rationalizations agents reach for.
- Write the skill that closes those specific rationalization paths. Re-test under pressure until the agent reliably complies.
- See the local `testing-skills-with-subagents.md` reference in this directory for the full TDD-for-skills methodology.

## Keep skills technology-agnostic when you can

- Frame triggers around the problem (race conditions, flaky tests, leaked file handles) rather than language-specific APIs (`setTimeout`, `asyncio.sleep`).
- If the skill is genuinely technology-specific, make that explicit in the trigger so it doesn't fire on unrelated tasks.

## Common authoring mistakes

- Description that's actually a workflow summary → agent skips the body.
- Imperative wording in the description ("You MUST…") → matches less reliably than declarative "Use when…".
- Narrative storytelling in the body → harder to scan, lower follow-through.
- Inline reference content > ~50 lines → split into a supporting file.

## Frontmatter contract (quick reminder)

```yaml
---
name: lowercase-with-hyphens
description: Use when <triggering conditions and symptoms>
---
```

- `name` and `description` are required; both fit under 1024 chars combined.
- See [agentskills.io/specification](https://agentskills.io/specification) for the full schema, including optional fields like `allowed-tools`.

---

*This file is a paraphrased summary. For full authoritative guidance see [Anthropic's skill-authoring best practices](https://docs.anthropic.com/en/docs/agents-and-tools/skills/best-practices).*
