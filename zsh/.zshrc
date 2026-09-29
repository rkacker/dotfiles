# ── Environment ─────────────────────────────────────────────────────
export EDITOR="code --wait"
# HOMEBREW_PREFIX is exported by `brew shellenv` in .zprofile; fall back for non-login shells.
export BREW_PREFIX="${HOMEBREW_PREFIX:-$(brew --prefix 2>/dev/null || echo /opt/homebrew)}"
export UV_PYTHON_PREFERENCE="managed"
export PYTHONIOENCODING="UTF-8"

# ── History ──────────────────────────────────────────────────────────
HISTFILE="$HOME/.zsh_history"
HISTSIZE=10000
SAVEHIST=10000
setopt HIST_IGNORE_DUPS HIST_IGNORE_SPACE SHARE_HISTORY

# ── Safety ───────────────────────────────────────────────────────────
setopt RM_STAR_WAIT          # wait 10s before executing rm *
alias rm='rm -i'             # prompt before every delete
alias cp='cp -i'             # prompt before overwrite
alias mv='mv -i'             # prompt before overwrite

# ── Modern CLI ───────────────────────────────────────────────────────
alias ls='eza --color=never'
alias ll='eza -la --color=never --git'
alias cat='bat --paging=never'
alias ffd='fd'

# ── Python (uv) ──────────────────────────────────────────────────────
alias python='python3'
alias pip='uv pip'

# ── Sandbox ──────────────────────────────────────────────────────────
export SANDBOX="$HOME/sandbox"
[[ -o interactive ]] && mkdir -p "$SANDBOX"

# ── Utilities ────────────────────────────────────────────────────────
alias rebash='source ~/.zshrc'

# ── Plugins (via Homebrew) ───────────────────────────────────────────
# Guarded so a fresh machine (before `brew bundle`) gets a working shell, not errors.
[[ -r "$BREW_PREFIX/share/zsh-autosuggestions/zsh-autosuggestions.zsh" ]] &&
  source "$BREW_PREFIX/share/zsh-autosuggestions/zsh-autosuggestions.zsh"

# ── fzf ──────────────────────────────────────────────────────────────
[[ -r "$BREW_PREFIX/opt/fzf/shell/key-bindings.zsh" ]] && source "$BREW_PREFIX/opt/fzf/shell/key-bindings.zsh"
[[ -r "$BREW_PREFIX/opt/fzf/shell/completion.zsh" ]] && source "$BREW_PREFIX/opt/fzf/shell/completion.zsh"

# ── zoxide (smarter cd) ──────────────────────────────────────────────
(( $+commands[zoxide] )) && eval "$(zoxide init zsh)"

# ── Completions ──────────────────────────────────────────────────────
# Rebuild the completion dump at most once a day; otherwise trust the cache (-C).
autoload -Uz compinit
if [[ -n "$HOME"/.zcompdump(#qN.mh+24) ]]; then
  compinit
else
  compinit -C
fi

# ── uv completions ───────────────────────────────────────────────────
(( $+commands[uv] )) && eval "$(uv generate-shell-completion zsh)"

# ── Syntax highlighting (must be after all plugins/widgets) ──────────
[[ -r "$BREW_PREFIX/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ]] &&
  source "$BREW_PREFIX/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"

# ── Starship prompt ──────────────────────────────────────────────────
(( $+commands[starship] )) && eval "$(starship init zsh)"

# ── Machine-local overrides (gitignored; work env vars, private aliases) ─
if [[ -r "$HOME/.zshrc.local" ]]; then
  source "$HOME/.zshrc.local"
fi
