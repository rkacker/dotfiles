#!/usr/bin/env bash
# Idempotent setup: installs Homebrew packages, symlinks stow packages into $HOME,
# collects machine-specific values (git identity) into untracked local files,
# points iTerm2 at the repo's prefs, and wires the secrets pre-commit hook.
set -euo pipefail

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$DOTFILES"

if ! command -v brew >/dev/null 2>&1; then
  echo "Homebrew not found. Install it from https://brew.sh and re-run." >&2
  exit 1
fi

echo "Installing Homebrew packages..."
brew bundle --file="$DOTFILES/Brewfile"

echo "Stowing dotfiles..."
for pkg in zsh git starship npm claude; do
  stow --restow --target="$HOME" "$pkg"
done

# Machine-specific values are never tracked. They live in ~/.config/git/config.local,
# which the tracked git config includes. Set GIT_USER_NAME / GIT_USER_EMAIL to run
# non-interactively; otherwise this prompts once and skips on later runs.
LOCAL_GIT="$HOME/.config/git/config.local"
if ! git config --file "$LOCAL_GIT" user.email >/dev/null 2>&1; then
  echo "Configuring git identity (saved to $LOCAL_GIT, not the repo)..."
  mkdir -p "$(dirname "$LOCAL_GIT")"
  name="${GIT_USER_NAME:-}"
  email="${GIT_USER_EMAIL:-}"
  [[ -n "$name" ]]  || read -rp "  Git user.name: " name
  [[ -n "$email" ]] || read -rp "  Git user.email: " email
  git config --file "$LOCAL_GIT" user.name "$name"
  git config --file "$LOCAL_GIT" user.email "$email"
fi

echo "Configuring iTerm2 prefs..."
defaults write com.googlecode.iterm2 PrefsCustomFolder -string "$DOTFILES/iterm2"
defaults write com.googlecode.iterm2 LoadPrefsFromCustomFolder -bool true

echo "Setting up fzf keybindings..."
"$(brew --prefix)/opt/fzf/install" --key-bindings --completion --no-update-rc

echo "Enabling secrets pre-commit hook for this repo..."
git -C "$DOTFILES" config core.hooksPath .githooks

echo "Done. Open a new iTerm2 window to see the new config."
