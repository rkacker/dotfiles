# ── Default directory ────────────────────────────────────────────────
cd ~/code

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
alias find='fd'

# ── Git safeguards ───────────────────────────────────────────────────
alias gst='git status'
alias glog='git log --oneline --graph --decorate --all'
alias gpushf='git push --force-with-lease'   # safe force push

# ── Python (uv) ──────────────────────────────────────────────────────
alias python='python3'
alias pip='uv pip'
# Use: `uv python install 3.13` to manage versions
# Use: `uv venv` to create virtual envs
# Use: `uv tool install <pkg>` for global CLI tools

# ── Sandbox ──────────────────────────────────────────────────────────
export SANDBOX="$HOME/sandbox"
mkdir -p "$SANDBOX"

# ── Utilities ────────────────────────────────────────────────────────
alias rebash='source ~/.zshrc'

# ── Plugins (via Homebrew) ───────────────────────────────────────────
source "$(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
source "$(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"

# ── fzf ──────────────────────────────────────────────────────────────
source "$(brew --prefix)/opt/fzf/shell/key-bindings.zsh"
source "$(brew --prefix)/opt/fzf/shell/completion.zsh"

# ── zoxide (smarter cd) ──────────────────────────────────────────────
eval "$(zoxide init zsh)"

# ── Completions ──────────────────────────────────────────────────────
autoload -Uz compinit && compinit

# ── uv completions ───────────────────────────────────────────────────
eval "$(uv generate-shell-completion zsh)"

# ── Starship prompt ──────────────────────────────────────────────────
eval "$(starship init zsh)"
