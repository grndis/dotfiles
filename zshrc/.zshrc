################################################################
# Shell Options
################################################################
setopt globdots

FUNCNEST=1000

################################################################
# Early Performance Setup
################################################################
skip_global_compinit=1

################################################################
# Environment Variables Cache
################################################################
# Cache expensive pass operations to avoid multiple external calls.
# Regenerated when .zshrc is newer than the cache file.
if [[ ! -f ~/.zsh_env_cache ]] || [[ ~/.zshrc -nt ~/.zsh_env_cache ]]; then
    # Call each pass entry exactly once, then reuse for aliases
    _gkey="$(pass show Development/Gemini/GEMINI_API_KEY 2>/dev/null || echo '')"
    _ctoken="$(pass show Development/GitHub/COPILOT_TOKEN 2>/dev/null || echo '')"
    _otoken="$(pass show Development/OpenRouter/OPENROUTER_TOKEN 2>/dev/null || echo '')"
    _cendpoint="$(pass show url/copilot_endpoint 2>/dev/null || echo '')"
    _wendpoint="$(pass show url/openai_workers 2>/dev/null || echo '')"
    _ggemini="$(pass show gcloud/gemini 2>/dev/null || echo '')"
    _pendpoint="$(pass show Development/custom/PROXY_ENDPOINT 2>/dev/null || echo '')"
    _papi="$(pass show Development/custom/PROXY_API 2>/dev/null || echo '')"
    _qendpoint="$(pass show Development/custom/QWEN_WORKER_ENDPOINT 2>/dev/null || echo '')"
    _qapi="$(pass show Development/custom/QWEN_WORKER_API 2>/dev/null || echo '')"
    _aapi="$(pass show Development/custom/ALIBABA_API 2>/dev/null || echo '')"
    _oapi="$(pass show Development/custom/OLLAMA_API 2>/dev/null || echo '')"

    cat > ~/.zsh_env_cache <<ENV_CACHE
# Cached environment variables - regenerated when .zshrc changes
export GEMINI_API_KEY="${_gkey}"
export LLM_KEY="${_ctoken}"
export API_KEY="${_ctoken}"
export COPILOT_TOKEN="${_ctoken}"
export OPENROUTER_KEY="${_otoken}"
export LUMEN_API_KEY="${_otoken}"
export COPILOT_API_ENDPOINT="${_cendpoint}"
export GEMINI_ENDPOINT="${_wendpoint}"
export GCLOUD_GEMINI="${_ggemini}"
export PROXY_ENDPOINT="${_pendpoint}"
export PROXY_API="${_papi}"
export QWEN_WORKER_ENDPOINT="${_qendpoint}"
export QWEN_WORKER_API="${_qapi}"
export ALIBABA_API="${_aapi}"
export OLLAMA_API="${_oapi}"
ENV_CACHE

    unset _gkey _ctoken _otoken _cendpoint _wendpoint _ggemini
    unset _pendpoint _papi _qendpoint _qapi _aapi _oapi
fi
source ~/.zsh_env_cache

################################################################
# Basic Environment Variables
################################################################
export EDITOR=nvim
export VISUAL=nvim
export PYENV_ROOT="$HOME/.pyenv"
export XDG_CONFIG_HOME="$HOME/.config"

if [[ "$(uname)" = "Darwin" ]]; then
    export PNPM_HOME="$HOME/Library/pnpm"
else
    export PNPM_HOME="$HOME/.local/share/pnpm"
fi

export ATAC_THEME=$HOME/.config/atac/themes/theme.toml
export ATAC_KEY_BINDINGS=$HOME/.config/atac/key_bindings/vim.toml
export AIDER_DARK_MODE=true
export AIDER_MODEL=gemini-2.5-pro
export CLAUDE_POWERLINE_THEME=dark
export CLAUDE_POWERLINE_STYLE=tokyo-night
export CLAUDE_POWERLINE_CONFIG=$HOME/.claude/claude-powerline/config.json
export ANTHROPIC_BASE_URL=https://ollama.com
export ANTHROPIC_MODEL="deepseek-v4-flash:cloud"
export ANTHROPIC_AUTH_TOKEN="$OLLAMA_API"
export ASK_SH_API_KEY="$OLLAMA_API"
export ASK_SH_API_MODEL="deepseek-v4-flash:cloud"
export ASK_SH_API_ENDPOINT="https://ollama.com/v1/chat/completions"
export ASK_SH_ANSWER_LANGUAGE="english"
export ASK_SH_TIMEOUT=60
export ASK_SH_DEBUG=false

################################################################
# PATH Setup
################################################################
path=(
    "$PNPM_HOME"
    "$HOME/.local/bin"
    "$PYENV_ROOT/bin"
    $path
)
if [[ "$(uname)" = "Darwin" ]]; then
    path+=("$HOME/.composer/vendor/bin" "/usr/local/elasticsearch/bin")
fi
export PATH

################################################################
# Zinit
################################################################
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"

if [ ! -d "$ZINIT_HOME" ]; then
   mkdir -p "$(dirname $ZINIT_HOME)"
   git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi

source "${ZINIT_HOME}/zinit.zsh"

################################################################
# Zinit Plugins - Optimized Loading Order
################################################################
# Essential: load immediately
zinit ice depth=1
zinit light jeffreytse/zsh-vi-mode

# Interactive: load async for faster startup
zinit ice lucid wait'0a'
zinit light Aloxaf/fzf-tab

zinit ice lucid wait'0b'
zinit snippet OMZP::fzf

zinit ice lucid wait'0c'
zinit light zsh-users/zsh-syntax-highlighting

zinit ice lucid wait'0d'
zinit light zsh-users/zsh-completions

zinit ice lucid wait'0e' atload'_zsh_autosuggest_start'
zinit light zsh-users/zsh-autosuggestions

################################################################
# ZVM Custom Config
################################################################
ZVM_VI_ESCAPE_BINDKEY=^[
ZVM_VI_SURROUND_BINDKEY='s-prefix'
ZVM_LINE_INIT_MODE=$ZVM_MODE_INSERT
ZVM_INSERT_MODE_CURSOR=$ZVM_CURSOR_BLINKING_BEAM
ZVM_SYSTEM_CLIPBOARD_ENABLED=true

# Starship integration - load after ZVM initialization
zvm_after_init_commands+=('if command -v starship >/dev/null 2>&1; then eval "$(starship init zsh)"; fi')

if [[ "$TERM" != "xterm-kitty" ]]; then
  icur=$(zvm_cursor_style $ZVM_INSERT_MODE_CURSOR)
  ncur=$(zvm_cursor_style $ZVM_NORMAL_MODE_CURSOR)
  vcur=$(zvm_cursor_style $ZVM_VISUAL_MODE_CURSOR)
  vlcur=$(zvm_cursor_style $ZVM_VISUAL_LINE_MODE_CURSOR)
  ZVM_INSERT_MODE_CURSOR=$icur'\e\e]12;#9ECE6A\a'
  ZVM_NORMAL_MODE_CURSOR=$ncur'\e\e]12;#a3aed2\a'
  ZVM_VISUAL_MODE_CURSOR=$vcur'\e\e]12;#c678dd\a'
  ZVM_VISUAL_LINE_MODE_CURSOR=$vlcur'\e\e]12;#c678dd\a'
fi
ZVM_VI_HIGHLIGHT_FOREGROUND=#cccccc
ZVM_VI_HIGHLIGHT_BACKGROUND=#534557
ZVM_VI_HIGHLIGHT_EXTRASTYLE=bold
ZVM_TERM=xterm-256color
ZVM_VI_EDITOR='nvim'

# zsh-vi-mode: navigate zellij panes with Ctrl+H/J/K/L in normal mode
function _zellij_nav_left()  { zellij action move-focus left; }
function _zellij_nav_down()  { zellij action move-focus down; }
function _zellij_nav_up()    { zellij action move-focus up; }
function _zellij_nav_right() { zellij action move-focus right; }
zle -N _zellij_nav_left
zle -N _zellij_nav_down
zle -N _zellij_nav_up
zle -N _zellij_nav_right

zvm_after_lazy_keybindings_commands+=(
  'zvm_bindkey vicmd "^H" _zellij_nav_left'
  'zvm_bindkey vicmd "^J" _zellij_nav_down'
  'zvm_bindkey vicmd "^K" _zellij_nav_up'
  'zvm_bindkey vicmd "^L" _zellij_nav_right'
)

typeset -A ZSH_HIGHLIGHT_STYLES
ZSH_HIGHLIGHT_STYLES[path]='none'

################################################################
# Shell Integrations - Cached Init for Speed
################################################################
# Cache init script output to avoid spawning subprocesses every shell start.
# Regenerate cache when tool version changes or cache file is missing.

# --- zoxide ---
if command -v zoxide >/dev/null 2>&1 && [ "$CLAUDECODE" != "1" ]; then
    _zoxide_cache="${XDG_CACHE_HOME:-$HOME/.cache}/zsh/zoxide_init.zsh"
    if [[ ! -f "$_zoxide_cache" ]] || [[ "$(zoxide --version 2>/dev/null)" != "$(head -1 "$_zoxide_cache" 2>/dev/null | sed 's/# //')" ]]; then
        mkdir -p "$(dirname "$_zoxide_cache")"
        echo "# $(zoxide --version 2>/dev/null)" > "$_zoxide_cache"
        zoxide init --cmd cd zsh >> "$_zoxide_cache"
    fi
    source "$_zoxide_cache"
fi

# --- atuin ---
if command -v atuin >/dev/null 2>&1; then
    _atuin_cache="${XDG_CACHE_HOME:-$HOME/.cache}/zsh/atuin_init.zsh"
    if [[ ! -f "$_atuin_cache" ]] || [[ "$(atuin --version 2>/dev/null)" != "$(head -1 "$_atuin_cache" 2>/dev/null | sed 's/# //')" ]]; then
        mkdir -p "$(dirname "$_atuin_cache")"
        echo "# $(atuin --version 2>/dev/null)" > "$_atuin_cache"
        atuin init zsh >> "$_atuin_cache"
    fi
    source "$_atuin_cache"
fi

# --- pyenv ---
if command -v pyenv >/dev/null 2>&1; then
    _pyenv_cache="${XDG_CACHE_HOME:-$HOME/.cache}/zsh/pyenv_init.zsh"
    if [[ ! -f "$_pyenv_cache" ]] || [[ "$(pyenv --version 2>/dev/null)" != "$(head -1 "$_pyenv_cache" 2>/dev/null | sed 's/# //')" ]]; then
        mkdir -p "$(dirname "$_pyenv_cache")"
        echo "# $(pyenv --version 2>/dev/null)" > "$_pyenv_cache"
        pyenv init --no-rehash - >> "$_pyenv_cache"
    fi
    source "$_pyenv_cache"
fi

################################################################
# History
################################################################
HISTSIZE=50000
HISTFILE=~/.zsh_history
SAVEHIST=$HISTSIZE
HISTDUP=erase
setopt appendhistory
setopt sharehistory
setopt hist_ignore_space
setopt hist_ignore_all_dups
setopt hist_save_no_dups
setopt hist_find_no_dups

################################################################
# Keybindings
################################################################
bindkey '^p' history-search-backward
bindkey '^n' history-search-forward
bindkey '^[w' kill-region
bindkey '\e[109;5u' accept-line
bindkey '^h' backward-delete-char

################################################################
# Completions
################################################################
# Zellij Completion Function
_zellij() {
    local -a sessions
    if (( CURRENT == 3 && (words[2] == "a" || words[2] == "attach" || words[2] == "kill-session") )); then
        sessions=(${(f)"$(zellij ls 2>/dev/null | sed 's/\x1b\[[0-9;]*[mG]//g' | awk '{print $1}')"})
        compadd -a sessions
    elif (( CURRENT == 2 )); then
        compadd "a" "attach" "ls" "list-sessions" "kill-session" "kill-all-sessions" "options"
    fi
}

# Optimized compinit with caching
_compdump_path="${ZDOTDIR:-$HOME}/.zcompdump"
if [[ ! -f "$_compdump_path" || "$HOME/.zshrc" -nt "$_compdump_path" ]]; then
    autoload -Uz compinit
    compinit -d "$_compdump_path"
    zinit cdreplay -q
else
    autoload -Uz compinit
    compinit -C -d "$_compdump_path"
fi

compdef _zellij zellij z

################################################################
# Completion Styling
################################################################
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu no
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls --color $realpath'
zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'ls --color $realpath'

################################################################
# Aliases
################################################################
alias vim='nvim'
alias v='nvim'
alias vi='nvim'
alias c='clear'
alias f='yazi'
alias ls='eza --color=always --git --icons=always'
alias z='zellij'

################################################################
# Yazi with cd integration
################################################################
y() {
    local cwd
    cwd=$(yazi "$@" --cwd-file=-)
    if [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
        cd -- "$cwd"
    fi
}

################################################################
# Platform-specific (macOS only)
################################################################
if [[ "$(uname)" = "Darwin" ]]; then
    # Homebrew
    # if [[ -f "/opt/homebrew/bin/brew" ]]; then
    #     eval "$(/opt/homebrew/bin/brew shellenv)"
    # fi

    # Bun completions
    [ -s "/Users/grandis/.bun/_bun" ] && source "/Users/grandis/.bun/_bun"
    export BUN_INSTALL="$HOME/.bun"
    export PATH="$BUN_INSTALL/bin:$PATH"

    # Google Cloud SDK
    [ -f '/Users/grandis/google-cloud-sdk/path.zsh.inc' ] && source '/Users/grandis/google-cloud-sdk/path.zsh.inc'
    [ -f '/Users/grandis/google-cloud-sdk/completion.zsh.inc' ] && source '/Users/grandis/google-cloud-sdk/completion.zsh.inc'

    # acme.sh
    # [ -f "/Users/grandis/.acme.sh/acme.sh.env" ] && source "/Users/grandis/.acme.sh/acme.sh.env"

    # Elasticsearch
    # path+=("/usr/local/elasticsearch/bin")
fi

################################################################
# Claude CLI with CCS Proxy shortcuts
################################################################
qw() {
    if ! command -v ccs >/dev/null 2>&1; then
        command claude "$@"
        return $?
    fi
    ccs proxy start qwen >/dev/null 2>&1 || return $?
    eval "$(ccs proxy activate qwen)" || return $?
    command claude "$@"
}
km() {
    if ! command -v ccs >/dev/null 2>&1; then
        command claude "$@"
        return $?
    fi
    ccs proxy start km >/dev/null 2>&1 || return $?
    eval "$(ccs proxy activate km)" || return $?
    command claude "$@"
}