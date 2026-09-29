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
| `claude`   | `~/.claude/settings.json`            | Claude Code settings: denies package-install commands, model, output style   |
| `iterm2/`  | (not stowed) iTerm2 custom prefs folder | Profile with Monaspice Nerd Font, colors, gestures. Loaded via `defaults`  |
| `Brewfile` | Homebrew                             | Every dependency, including `gitleaks` for the pre-commit hook               |

## Install

```bash
git clone https://github.com/rkacker/dotfiles.git ~/code/dotfiles
cd ~/code/dotfiles
./install.sh
```

`install.sh` is idempotent and location-independent. It runs `brew bundle`, restows each
package, prompts once for your git identity, points iTerm2 at `iterm2/`, installs fzf
keybindings, and enables the repo's pre-commit hook. Re-run it after pulling changes or
adding a package. For a non-interactive run:

```bash
GIT_USER_NAME="Your Name" GIT_USER_EMAIL="you@example.com" ./install.sh
```

## Layout

```
dotfiles/
  Brewfile                  # Homebrew dependencies
  install.sh                # Idempotent setup script
  .githooks/pre-commit      # gitleaks scan of staged changes
  claude/.claude/           # Claude Code settings
  git/.config/git/          # Git config + global ignore
  iterm2/                   # iTerm2 preferences (XML plist, written by iTerm2)
  npm/.npmrc                # npm hardening
  starship/.config/         # Starship prompt config
  zsh/.zshrc                # Interactive shell config
  zsh/.zprofile             # Login shell: Homebrew shellenv, PATH
  zsh/.inputrc              # Readline config
```

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

## Secrets policy

The repo is meant to be public. `install.sh` sets `core.hooksPath` to `.githooks`, whose
`pre-commit` runs `gitleaks` against staged changes and blocks the commit on a hit. To scan
the full history at any time:

```bash
gitleaks git --redact -v .
```

API keys, tokens, passwords, and machine-specific values (identity, paths, hostnames)
never belong here. iTerm2 keeps its AI API key in the macOS Keychain, not in the plist.
