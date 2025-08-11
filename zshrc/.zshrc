###############################################################
# Shell Options
################################################################
setopt globdots  #include hidden files in globbing

# Increase function nesting limit to prevent starship/zvm conflicts
FUNCNEST=1000

################################################################
# Early Performance Setup
################################################################
# Skip global compinit for faster startup
skip_global_compinit=1

################################################################
# MacOS Homebrew
################################################################
# if [[ -f "/opt/homebrew/bin/brew" ]] then
#   eval "$(/opt/homebrew/bin/brew shellenv)"
# fi

################################################################
# Environment Variables Cache
################################################################
# Cache expensive pass operations to avoid multiple external calls
if [[ ! -f ~/.zsh_env_cache ]] || [[ ~/.zshrc -nt ~/.zsh_env_cache ]]; then
    echo "# Cached environment variables - regenerated when .zshrc changes" > ~/.zsh_env_cache
    echo "export GEMINI_API_KEY=\"$(pass show Development/Gemini/GEMINI_API_KEY 2>/dev/null || echo '')\"" >> ~/.zsh_env_cache
    echo "export LLM_KEY=\"$(pass show Development/GitHub/COPILOT_TOKEN 2>/dev/null || echo '')\"" >> ~/.zsh_env_cache
    echo "export OPENAI_API_BASE=\"$(pass show url/copilot_endpoint 2>/dev/null || echo '')\"" >> ~/.zsh_env_cache
    echo "export OPENAI_API_KEY=\"$(pass show Development/OpenRouter/OPENROUTER_TOKEN 2>/dev/null || echo '')\"" >> ~/.zsh_env_cache
    echo "export API_KEY=\"$(pass show Development/GitHub/COPILOT_TOKEN 2>/dev/null || echo '')\"" >> ~/.zsh_env_cache
    echo "export COPILOT_TOKEN=\"$(pass show Development/GitHub/COPILOT_TOKEN 2>/dev/null || echo '')\"" >> ~/.zsh_env_cache
    echo "export OPENAI_KEY=\"$(pass show Development/GitHub/COPILOT_TOKEN 2>/dev/null || echo '')\"" >> ~/.zsh_env_cache
    echo "export OPENROUTER_KEY=\"$(pass show Development/OpenRouter/OPENROUTER_TOKEN 2>/dev/null || echo '')\"" >> ~/.zsh_env_cache
    echo "export LUMEN_API_KEY=\"$(pass show Development/OpenRouter/OPENROUTER_TOKEN 2>/dev/null || echo '')\"" >> ~/.zsh_env_cache
    echo "export COPILOT_API_ENDPOINT=\"$(pass show url/copilot_endpoint 2>/dev/null || echo '')\"" >> ~/.zsh_env_cache
    echo "export OPENAI_API_ENDPOINT=\"$(pass show url/openai_workers 2>/dev/null || echo '')\"" >> ~/.zsh_env_cache
    echo "export GEMINI_ENDPOINT=\"$(pass show url/openai_workers 2>/dev/null || echo '')\"" >> ~/.zsh_env_cache
    echo "export ANTHROPIC_AUTH_TOKEN=\"$(pass show Development/GitHub/COPILOT_TOKEN 2>/dev/null || echo '')\"" >> ~/.zsh_env_cache
    echo "export GCLOUD_GEMINI=\"$(pass show gcloud/gemini 2>/dev/null || echo '')\"" >> ~/.zsh_env_cache
fi
source ~/.zsh_env_cache

################################################################
# Basic Environment Variables
################################################################
export PNPM_HOME="$HOME/Library/pnpm"
export EDITOR=nvim
export VISUAL=nvim
export PYENV_ROOT="$HOME/.pyenv"
export XDG_CONFIG_HOME="$HOME/.config"
export ATAC_THEME=$HOME/.config/atac/themes/theme.toml
export ATAC_KEY_BINDINGS=$HOME/.config/atac/key_bindings/vim.toml
export AIDER_DARK_MODE=true
export AIDER_MODEL=gemini-2.5-pro
export OPENAI_BASE_URL=https://openrouter.ai/api/v1
export OPENAI_MODEL="qwen/qwen3-coder"

################################################################
# PATH Setup
################################################################
path=(
    "$PNPM_HOME"
    "$HOME/.local/bin"
    "$HOME/.composer/vendor/bin"
    "/usr/local/elasticsearch/bin"
    "$PYENV_ROOT/bin"
    $path
)
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
# Load essential plugins immediately
zinit ice depth=1
zinit light jeffreytse/zsh-vi-mode

# Load interactive plugins with wait for faster startup
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
ZVM_VI_SURROUND_BINDKEY='classic'
ZVM_LINE_INIT_MODE=$ZVM_MODE_INSERT
ZVM_INSERT_MODE_CURSOR=$ZVM_CURSOR_BLINKING_BEAM

# Starship integration - load after ZVM initialization
zvm_after_init_commands+=('if command -v starship >/dev/null 2>&1; then eval "$(starship init zsh)"; fi')

if [[ "$TERM" != "xterm-kitty" ]]; then
  local icur=$(zvm_cursor_style $ZVM_INSERT_MODE_CURSOR)
  local ncur=$(zvm_cursor_style $ZVM_NORMAL_MODE_CURSOR)
  local vcur=$(zvm_cursor_style $ZVM_VISUAL_MODE_CURSOR)
  local vlcur=$(zvm_cursor_style $ZVM_VISUAL_LINE_MODE_CURSOR)
  ZVM_INSERT_MODE_CURSOR=$icur'\e\e]12;#9ECE6A\a'
  ZVM_NORMAL_MODE_CURSOR=$ncur'\e\e]12;#a3aed2\a'
  ZVM_VISUAL_MODE_CURSOR=$vcur'\e\e]12;#c678dd\a'
  ZVM_VISUAL_LINE_MODE_CURSOR=$vlcur'\e\e]12;#c678dd\a'
fi
ZVM_VI_HIGHLIGHT_FOREGROUND=#cccccc
ZVM_VI_HIGHLIGHT_BACKGROUND=#534557
ZVM_VI_HIGHLIGHT_EXTRASTYLE=bold,underline
ZVM_TERM=xterm-256color
ZVM_VI_EDITOR='nvim'

################################################################
# Shell Integrations - Simple and Reliable
################################################################
# Load zoxide immediately for consistent performance
if command -v zoxide >/dev/null 2>&1; then
    eval "$(zoxide init --cmd cd zsh)"
fi

# Load atuin immediately
if command -v atuin >/dev/null 2>&1; then
    eval "$(atuin init zsh)"
fi

# Load pyenv immediately if available
if command -v pyenv >/dev/null 2>&1; then
    eval "$(pyenv init --no-rehash -)"
fi

################################################################
# History
################################################################
HISTSIZE=5000
HISTFILE=~/.zsh_history
SAVEHIST=$HISTSIZE
HISTDUP=erase
setopt appendhistory
setopt sharehistory
setopt hist_ignore_space
setopt hist_ignore_all_dups
setopt hist_save_no_dups
setopt hist_ignore_dups
setopt hist_find_no_dups

################################################################
# Keybindings
################################################################
bindkey '^p' history-search-backward
bindkey '^n' history-search-forward
bindkey '^[w' kill-region

################################################################
# Completions - Optimized
################################################################
# Zellij Completion Function
_zellij() {
    local -a sessions
    if (( CURRENT == 3 && (words[2] == "a" || words[2] == "attach" || words[2] == "kill-session") )); then
        # Get session names: strip color codes, then take the first column.
        sessions=(${(f)"$(zellij ls 2>/dev/null | sed 's/\x1b\[[0-9;]*[mG]//g' | awk '{print $1}')"})
        compadd -a sessions
    elif (( CURRENT == 2 )); then
        compadd "a" "attach" "ls" "list-sessions" "kill-session" "kill-all-sessions" "options"
    fi
}

# Optimized compinit with better caching
_compdump_path="${ZDOTDIR:-$HOME}/.zcompdump"
if [[ ! -f "$_compdump_path" || "$HOME/.zshrc" -nt "$_compdump_path" ]]; then
    autoload -Uz compinit
    compinit -d "$_compdump_path"
    # Rebuild zinit completion cache
    zinit cdreplay -q
else
    autoload -Uz compinit
    compinit -C -d "$_compdump_path"
fi

# Apply completions
compdef _zellij zellij z

################################################################
# Completion styling
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
alias a='atac'
alias z='zellij'
alias code='ccr code'
alias rovo='acli rovodev run'

################################################################
# Yazi setup with cd integration
################################################################
y() {
    local cwd
    cwd=$(yazi "$@" --cwd-file=-)
    if [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
        cd -- "$cwd"
    fi
}

################################################################
# Starship Integration with zsh-vi-mode
################################################################
# Starship is configured in ZVM section to prevent conflicts

################################################################
# AI CLI Setup
################################################################
# Initialize AI tools if needed
if command -v ai &> /dev/null; then
    if [ ! -f ~/.ai-shell ]; then
        echo "First time setup: Configuring ai..."
        ai config set OPENAI_KEY="$COPILOT_TOKEN"
        ai config set OPENAI_API_ENDPOINT="$COPILOT_API_ENDPOINT"
        touch ~/.ai-shell
        echo "AI configuration completed."
    fi
fi

################################################################
# Config File Management (moved to separate script)
################################################################
# Create configs only when tools are first used
_create_claude_config() {
    if [[ ! -f "$HOME/.claude-code-router/config.json" ]]; then
        mkdir -p "$HOME/.claude-code-router"
        cat > "$HOME/.claude-code-router/config.json" << EOF
{
  "LOG": false,
  "transformers": [
    {
      "path": "$HOME/.claude-code-router/plugins/gemini-cli.js",
      "options": {
        "project": "$GCLOUD_GEMINI"
      }
    }
  ],
  "Providers": [
    {
      "name": "gemini",
      "api_base_url": "https://generativelanguage.googleapis.com/v1beta/models/",
      "api_key": "$GEMINI_API_KEY",
      "models": ["gemini-2.5-pro", "gemini-2.5-flash"],
      "transformer": {
        "use": ["gemini"]
      }
    },
    {
      "name": "gemini-cli",
      "api_base_url": "https://cloudcode-pa.googleapis.com/v1internal",
      "api_key": "$GEMINI_API_KEY",
      "models": ["gemini-2.5-flash", "gemini-2.5-pro"],
      "transformer": {
        "use": ["gemini-cli"]
      }
    },
    {
      "name": "openrouter",
      "api_base_url": "https://openrouter.ai/api/v1/chat/completions",
      "api_key": "$OPENROUTER_KEY",
      "models": [
        "anthropic/claude-sonnet-4",
        "anthropic/claude-opus-4",
        "google/gemini-2.5-flash",
        "google/gemini-2.5-pro"
      ],
      "transformer": {
        "use": ["openrouter"]
      }
    },
    {
      "name": "copilot",
      "api_base_url": "https://api.githubcopilot.com/chat/completions",
      "api_key": "$COPILOT_TOKEN",
      "models": [
        "gemini-2.5-pro",
        "claude-sonnet-4",
        "gpt-4.1",
        "gpt-4o",
        "gpt-4o-mini"
      ],
      "transformer": {
        "use": ["copilot"]
      }
    }

  ],
  "Router": {
    "default": "gemini-cli,gemini-2.5-flash",
    "background": "gemini-cli,gemini-2.5-pro",
    "think": "gemini-cli,gemini-2.5-pro",
    "longContext": "gemini-cli,gemini-2.5-pro"
  }
}
EOF
    fi
}

# _create_lumen_config() {
#     if [[ ! -f "$HOME/.config/lumen/lumen.config.json" ]]; then
#         mkdir -p "$HOME/.config/lumen"
#         cat > "$HOME/.config/lumen/lumen.config.json" << EOF
# {
#   "provider": "openrouter",
#   "model": "google/gemini-2.5-flash-lite-preview-06-17",
#   "api_key": "$LUMEN_API_KEY",
#   "draft": {
#     "commit_types": {
#       "docs": "Documentation only changes",
#       "style": "Changes that do not affect the meaning of the code",
#       "refactor": "A code change that neither fixes a bug nor adds a feature",
#       "perf": "A code change that improves performance",
#       "test": "Adding missing tests or correcting existing tests",
#       "build": "Changes that affect the build system or external dependencies",
#       "ci": "Changes to our CI configuration files and scripts",
#       "chore": "Other changes that don't modify src or test files",
#       "revert": "Reverts a previous commit",
#       "feat": "A new feature",
#       "fix": "A bug fix"
#     }
#   }
# }
# EOF
#     fi
# }

# Override commands to create configs on first use
ccr() {
    _create_claude_config
    command ccr "$@"
}

# Unset any existing lumen alias before defining function
# unalias lumen 2>/dev/null
# lumen() {
#     _create_lumen_config
#     command lumen "$@"
# }
#
# The next line updates PATH for the Google Cloud SDK.
# if [ -f '/Users/grandis/google-cloud-sdk/path.zsh.inc' ]; then . '/Users/grandis/google-cloud-sdk/path.zsh.inc'; fi

# The next line enables shell command completion for gcloud.
# if [ -f '/Users/grandis/google-cloud-sdk/completion.zsh.inc' ]; then . '/Users/grandis/google-cloud-sdk/completion.zsh.inc'; fi
# . "/Users/grandis/.acme.sh/acme.sh.env"
export PATH="$HOME/.local/bin:$PATH"
