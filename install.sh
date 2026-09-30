#!/usr/bin/env bash
# Idempotent setup: Homebrew packages, stow packages into $HOME, machine-specific
# values into untracked local files, iTerm2 prefs, Claude Code + Cursor tooling
# (skills, MCP servers, extensions), and the secrets pre-commit hook.
# Prerequisites (by hand): Homebrew, Cursor, Claude desktop app. See README "New machine".
set -euo pipefail

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$DOTFILES"
export PATH="$HOME/.local/bin:$PATH"

if ! command -v brew >/dev/null 2>&1; then
  echo "Homebrew not found. Install it from https://brew.sh and re-run." >&2
  exit 1
fi

# Cursor and the Claude desktop app self-update and are installed by hand (see README).
for app in Cursor Claude; do
  [[ -d "/Applications/$app.app" ]] || echo "Note: /Applications/$app.app not found. Install it from the vendor site; re-run to install its extensions/config."
done

echo "Installing Homebrew packages..."
brew bundle --file="$DOTFILES/Brewfile"

echo "Stowing dotfiles..."
for pkg in zsh git starship npm claude agents cursor; do
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

echo "Installing Claude Code..."
if ! command -v claude >/dev/null 2>&1; then
  curl -fsSL https://claude.ai/install.sh | bash
fi
# Keep the native installer's self-updater on (state lives in ~/.claude.json, never tracked).
CLAUDE_JSON="$HOME/.claude.json"
if [[ -f "$CLAUDE_JSON" ]]; then
  tmp="$(mktemp)"; jq '.autoUpdates = true' "$CLAUDE_JSON" > "$tmp" && mv "$tmp" "$CLAUDE_JSON"
else
  echo '{"autoUpdates": true}' > "$CLAUDE_JSON"
fi

# Third-party skills: ~/.agents/skills is the shared root (Cursor reads it natively).
# The lock file is tracked; contents are reinstalled from it with the skills CLI.
LOCK="$HOME/.agents/.skill-lock.json"
if [[ -f "$LOCK" ]] && command -v npx >/dev/null 2>&1; then
  echo "Restoring agent skills from $LOCK..."
  jq -r '.skills | to_entries | group_by(.value.source)
         | .[] | "\(.[0].value.source) \([.[].key] | join(" "))"' "$LOCK" |
  while read -r source names; do
    # shellcheck disable=SC2086  # names is intentionally word-split
    npx -y skills add "$source" -g -y -s $names </dev/null
  done
fi
# Claude Code reads ~/.claude/skills; link every shared skill there.
mkdir -p "$HOME/.claude/skills"
for skill in "$HOME"/.agents/skills/*/; do
  name="$(basename "$skill")"
  [[ -e "$HOME/.claude/skills/$name" ]] || ln -s "../../.agents/skills/$name" "$HOME/.claude/skills/$name"
done
# Cursor reads ~/.agents/skills natively; drop the duplicate links the skills CLI adds.
[[ -d "$HOME/.cursor/skills" ]] && find "$HOME/.cursor/skills" -maxdepth 1 -type l -delete

# MCP servers: cursor/.cursor/mcp.json is the single definition. Cursor reads it via stow;
# Claude Code gets the same entries registered at user scope.
if command -v claude >/dev/null 2>&1; then
  echo "Registering MCP servers in Claude Code..."
  jq -r '.mcpServers | keys[]' cursor/.cursor/mcp.json | while read -r name; do
    # Cursor's shape omits "type" for remote servers; Claude Code requires it.
    json="$(jq -c --arg n "$name" \
      '.mcpServers[$n] | if has("url") and (has("type") | not) then . + {type: "http"} else . end' \
      cursor/.cursor/mcp.json)"
    claude mcp remove -s user "$name" >/dev/null 2>&1 || true
    claude mcp add-json -s user "$name" "$json" >/dev/null
    echo "  $name"
  done
fi

echo "Installing Cursor extensions..."
CODE_BIN="/Applications/Cursor.app/Contents/Resources/app/bin/code"
if [[ -x "$CODE_BIN" ]]; then
  installed="$("$CODE_BIN" --list-extensions)"
  while read -r ext; do
    [[ -z "$ext" ]] && continue
    grep -qxF "$ext" <<<"$installed" || "$CODE_BIN" --install-extension "$ext"
  done < cursor-extensions.txt
fi

echo "Enabling secrets pre-commit hook for this repo..."
git -C "$DOTFILES" config core.hooksPath .githooks

echo "Done. Open a new iTerm2 window to see the new config."
