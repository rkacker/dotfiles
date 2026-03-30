# dotfiles

macOS terminal setup for Python-centric app development. Managed with [GNU Stow](https://www.gnu.org/software/stow/).

## What's in it

- **zsh** -- history, safety aliases, uv/Python config, fzf, zoxide, autosuggestions, syntax highlighting
- **starship** -- minimal single-line prompt with git branch/status
- **git** -- sensible defaults, url shorthands, useful aliases (`go`, `fc`, `fm`, `dm`)
- **inputrc** -- case-insensitive completion, prefix history search with arrow keys
- **iTerm2** -- profile with Monaspice Nerd Font, reuse previous session directory
- **Brewfile** -- all dependencies in one place

## Install

```bash
git clone https://github.com/rkacker/dotfiles.git ~/code/dotfiles
cd ~/code/dotfiles
./install.sh
```

## Structure

```
dotfiles/
  Brewfile              # Homebrew dependencies
  install.sh            # Setup script
  git/.config/git/      # Git config + global ignore
  starship/.config/     # Starship prompt config
  zsh/.zshrc            # Shell config
  zsh/.inputrc          # Readline config
  iterm2/               # iTerm2 preferences
```

Each top-level folder is a stow package. `install.sh` symlinks them into `$HOME`.
