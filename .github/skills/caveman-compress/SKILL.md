---
name: caveman-compress
description: Use when the user asks to compress, shrink, or caveman-ify a markdown or plain-text file. Reduces prose ~46% while preserving code blocks, inline code, URLs, file paths, commands, structure, and all technical substance exactly. Shows output for approval before writing.
---

# caveman-compress

Compress prose in `.md` / `.txt` files to caveman style. Reduce ~46% tokens. Preserve all technical substance.

## Process

1. Read the target file.
2. Compress prose sections per rules below.
3. Show compressed output as a code block.
4. Ask the user to confirm before writing.

## Remove

- Articles (a, an, the)
- Filler (just, really, basically, actually, simply)
- Pleasantries (sure, certainly, happy to)
- Hedging ("it might be worth", "you could consider")
- Redundant phrasing ("in order to" → "to", "make sure to" → "ensure")
- Connective fluff ("however", "furthermore", "additionally")

## Preserve EXACTLY — never modify

- Code blocks (fenced and indented)
- Inline code (backticks)
- URLs and markdown links
- File paths
- Commands (`npm install`, `git commit`, ...)
- Technical terms, library names, API names
- Proper nouns, dates, version numbers
- Environment variables (`$HOME`, `NODE_ENV`)

## Preserve structure

Headings, bullet hierarchy, numbered lists, tables, frontmatter.

## Compress prose

- Short synonyms: "big" not "extensive", "fix" not "implement a solution for"
- Fragments OK: "Run tests before commit" not "You should always run tests before committing"
- Drop "you should", "make sure to", "remember to"
- Merge redundant bullets that say the same thing differently

## Example

Original:
> You should always make sure to run the test suite before pushing any changes to the
> main branch. This is important because it helps catch bugs early.

Compressed:
> Run tests before push to main. Catch bugs early.

## Targets

**Only compress:** `.md`, `.txt`, extensionless prose files.
**Never modify:** `.py`, `.js`, `.ts`, `.json`, `.yaml`, `.yml`, `.toml`, `.env`, `.sh`, lockfiles.
Mixed files: compress prose sections only.

## Boundaries

Always show output for approval before overwriting. Never silently rewrite the file.
