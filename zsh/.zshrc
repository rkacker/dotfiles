# ── Environment ─────────────────────────────────────────────────────
export EDITOR="code --wait"
export BREW_PREFIX="$(brew --prefix)"
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
source "$BREW_PREFIX/share/zsh-autosuggestions/zsh-autosuggestions.zsh"

# ── fzf ──────────────────────────────────────────────────────────────
source "$BREW_PREFIX/opt/fzf/shell/key-bindings.zsh"
source "$BREW_PREFIX/opt/fzf/shell/completion.zsh"

# ── zoxide (smarter cd) ──────────────────────────────────────────────
eval "$(zoxide init zsh)"

# ── Completions ──────────────────────────────────────────────────────
autoload -Uz compinit && compinit

# ── uv completions ───────────────────────────────────────────────────
eval "$(uv generate-shell-completion zsh)"

# ── Syntax highlighting (must be after all plugins/widgets) ──────────
source "$BREW_PREFIX/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"

# ── Starship prompt ──────────────────────────────────────────────────
eval "$(starship init zsh)"
