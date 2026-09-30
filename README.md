# dotfiles

macOS terminal setup for Python-centric development. Each top-level folder is a
[GNU Stow](https://www.gnu.org/software/stow/) package whose contents mirror `$HOME`;
`install.sh` symlinks them into place.

## What's in it

| Package    | Installs to                          | What it does                                                                 |
|------------|--------------------------------------|------------------------------------------------------------------------------|
| `zsh`      | `~/.zshrc`, `~/.zprofile`, `~/.inputrc` | History, safety aliases, uv/Python, fzf, zoxide, autosuggestions, highlighting |
| `starship` | `~/.config/starship.toml`            | Minimal single-line prompt: path, git branch, git status                     |
| `git`      | `~/.config/git/config`, `~/.config/git/ignore` | Defaults, `gh:` URL shorthand, aliases (`go`, `fc`, `fm`, `dm`), global ignore |
| `npm`      | `~/.npmrc`                           | `ignore-scripts=true` so installs can't run lifecycle scripts                |
| `claude`   | `~/.claude/settings.json`, `CLAUDE.md`, `output-styles/` | Claude Code settings, global instructions, the Crisp output style |
| `agents`   | `~/.agents/.skill-lock.json`, `~/.agents/skills/` | Shared skill root for Claude Code and Cursor: lock file plus home-grown skills |
| `cursor`   | `~/.cursor/mcp.json`, `~/.cursor/rules/`, Cursor `User/` | MCP servers, user rule (links to the global `CLAUDE.md`), editor settings, keybindings |
| `iterm2/`  | (not stowed) iTerm2 custom prefs folder | Profile with Monaspice Nerd Font, colors, gestures. Loaded via `defaults`  |
| `Brewfile` | Homebrew                             | Every dependency, including Cursor, the Claude desktop app, and `gitleaks`  |

## Install

```bash
git clone https://github.com/rkacker/dotfiles.git ~/code/dotfiles
cd ~/code/dotfiles
./install.sh
```

`install.sh` is idempotent and location-independent. It adopts any Cursor or Claude app
already in `/Applications` into Homebrew, runs `brew bundle`, restows each package, prompts
once for your git identity, points iTerm2 at `iterm2/`, installs fzf keybindings, installs
Claude Code with its self-updater on, restores skills, registers MCP servers, installs
Cursor extensions, and enables the repo's pre-commit hook. Re-run it after pulling changes
or adding a package. For a non-interactive run:

```bash
GIT_USER_NAME="Your Name" GIT_USER_EMAIL="you@example.com" ./install.sh
```

## Layout

```
dotfiles/
  Brewfile                  # Homebrew dependencies
  install.sh                # Idempotent setup script
  .githooks/pre-commit      # gitleaks scan of staged changes
  AGENTS.md                 # Agent instructions for this repo (CLAUDE.md imports it)
  agents/.agents/           # Shared skills root: lock file + home-grown skills
  claude/.claude/           # Claude Code settings, global CLAUDE.md, output styles
  cursor/                   # Cursor MCP config, user rule, editor settings
  cursor-extensions.txt     # Cursor extensions, reinstalled by install.sh
  git/.config/git/          # Git config + global ignore
  iterm2/                   # iTerm2 preferences (XML plist, written by iTerm2)
  npm/.npmrc                # npm hardening
  starship/.config/         # Starship prompt config
  zsh/.zshrc                # Interactive shell config
  zsh/.zprofile             # Login shell: Homebrew shellenv, PATH
  zsh/.inputrc              # Readline config
```

## Claude Code and Cursor

Both tools share one set of instructions, skills, and MCP servers:

- Instructions: `claude/.claude/CLAUDE.md` is Claude Code's global file and is symlinked
  as Cursor's user rule (`~/.cursor/rules/global.mdc`, hence the frontmatter). Per
  project, write `AGENTS.md` and make `CLAUDE.md` contain `@AGENTS.md`.
- Skills: `~/.agents/skills` is the single root. Cursor reads it natively; Claude Code
  reads `~/.claude/skills`, so `install.sh` links each skill there. Third-party skills
  are reinstalled from the tracked lock file with `npx skills`; home-grown ones live in
  `agents/.agents/skills/`. Add a skill with `npx skills add <owner/repo> -g` and commit
  the lock file change.
- MCP servers: `cursor/.cursor/mcp.json` is the one definition. Cursor reads it directly;
  `install.sh` registers the same entries in Claude Code at user scope. Prefer OAuth
  HTTP servers so no keys are stored. Servers you connect on claude.ai appear only in
  Claude Code and are not in this file.
- Claude Code is installed by the native installer, not Homebrew, so its built-in
  updater keeps it current. Its state file `~/.claude.json` is never tracked.

## Machine-local overrides

Anything private or machine-specific stays out of the repo. Three hooks exist for it,
all matched by the `*.local` ignore rule:

- `~/.zshrc.local` is sourced at the end of `.zshrc` (work env vars, private aliases).
- `~/.config/git/config.local` holds `user.name` and `user.email`, plus anything else
  per-machine (signing key, credential helper). `install.sh` creates it; the tracked git
  config includes it and carries no identity of its own.
- `~/.claude/settings.local.json` is Claude Code's own per-machine override file.

## How live edits flow back

Two files in this repo are written by the apps that use them, so `git status` will show
changes you didn't type:

- `claude/.claude/settings.json` is a symlink target. Claude Code writes settings changes
  (model, output style, permissions) straight into it.
- `iterm2/com.googlecode.iterm2.plist` is rewritten by iTerm2 on quit. It is XML and
  diffable; review the diff before committing. Don't hand-edit it.
- `agents/.agents/.skill-lock.json` is rewritten by `npx skills` on add or update.
- Cursor's `settings.json` and `keybindings.json` are written by Cursor's settings UI.

## Secrets policy

The repo is meant to be public. `install.sh` sets `core.hooksPath` to `.githooks`, whose
`pre-commit` runs `gitleaks` against staged changes and blocks the commit on a hit. To scan
the full history at any time:

```bash
gitleaks git --redact -v .
```

API keys, tokens, passwords, and machine-specific values (identity, paths, hostnames)
never belong here. iTerm2 keeps its AI API key in the macOS Keychain, not in the plist.
