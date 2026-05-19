---
mode: agent
description: >
  Compress natural language markdown files (CLAUDE.md, todos, notes, instructions) into
  caveman format to save input tokens. Preserves all technical substance, code, URLs, and
  structure. Invoke with /caveman-compress <filepath> or "compress this file".
tools:
  - codebase
---

Compress target markdown file to caveman prose. Reduce token count ~46%. Preserve all
technical substance. Code blocks: never touch.

## Process

1. Read the target file via `#<filepath>`.
2. Compress prose sections following rules below.
3. Output the compressed content as a code block for review.
4. Ask user to confirm before applying the change.

## Compression rules

**Remove:**
- Articles: a, an, the
- Filler: just, really, basically, actually, simply, essentially
- Pleasantries: "sure", "certainly", "happy to", "I'd recommend"
- Hedging: "it might be worth", "you could consider", "it would be good to"
- Redundant phrasing: "in order to" → "to", "make sure to" → "ensure"
- Connective fluff: "however", "furthermore", "additionally", "in addition"

**Preserve EXACTLY — never modify:**
- Code blocks (fenced ``` and indented)
- Inline code (`backtick content`)
- URLs and markdown links
- File paths
- Commands (`npm install`, `git commit`)
- Technical terms, library names, API names
- Proper nouns, dates, version numbers, environment variables

**Preserve structure:**
- All markdown headings (compress body, not heading text)
- Bullet hierarchy and nesting
- Numbered lists
- Tables (compress cell text, keep structure)
- Frontmatter/YAML headers

**Compress:**
- Short synonyms: "big" not "extensive", "fix" not "implement a solution for"
- Fragments OK: "Run tests before commit" not "You should always run tests before committing"
- Drop "you should", "make sure to", "remember to" — just state the action
- Merge redundant bullets that say the same thing differently

## Example

Original:
> You should always make sure to run the test suite before pushing any changes to the
> main branch. This is important because it helps catch bugs early and prevents broken
> builds from being deployed to production.

Compressed:
> Run tests before push to main. Catch bugs early, prevent broken prod deploys.

## Boundaries

ONLY compress: `.md`, `.txt`, extensionless prose files.
NEVER modify: `.py`, `.js`, `.ts`, `.json`, `.yaml`, `.yml`, `.toml`, `.env`, `.sh`.
Mixed files: compress prose sections only.
Always show compressed output for approval before writing.
