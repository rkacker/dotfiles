---
alwaysApply: true
---
# Global agent instructions

Read by Claude Code as `~/.claude/CLAUDE.md` and by Cursor as a user rule. The
frontmatter above is for Cursor; Claude Code ignores it.

## Conventions

- Project instructions live in `AGENTS.md` at the repo root. A repo's `CLAUDE.md`
  contains only `@AGENTS.md` so both tools read one file.
- Python projects use `uv` (`uv run`, `uv add`, `uv sync`). Never `pip install` into a
  global interpreter.
- The editor is Cursor; `code` and `cursor` both open it.
- Do not commit or push unless asked. Never bypass a pre-commit hook.
- Secrets never go in a repo. Machine-local values belong in `~/.zshrc.local`,
  `~/.config/git/config.local`, or the tool's own `*.local` file.

## Voice

Lead with the answer. Short sentences, plain verbs, no filler, no dashes, no
closing summaries. Push back with evidence when the request is wrong.
