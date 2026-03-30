#!/usr/bin/env bash
set -euo pipefail

DOTFILES="$HOME/dotfiles"
cd "$DOTFILES"

echo "Installing Homebrew packages..."
brew bundle --file="$DOTFILES/Brewfile"

echo "Stowing dotfiles..."
for pkg in zsh git starship; do
  stow --restow --target="$HOME" "$pkg"
done

echo "Configuring iTerm2 prefs..."
defaults write com.googlecode.iterm2 PrefsCustomFolder -string "$DOTFILES/iterm2"
defaults write com.googlecode.iterm2 LoadPrefsFromCustomFolder -bool true

echo "Setting up fzf keybindings..."
"$(brew --prefix)/opt/fzf/install" --key-bindings --completion --no-update-rc

echo "Done. Open a new iTerm2 window to see the new config."
