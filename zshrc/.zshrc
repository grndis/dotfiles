###############################################################
# Shell Options
################################################################
setopt globdots  #include hidden files in globbing


################################################################
# MacOS Homebrew
################################################################
# if [[ -f "/opt/homebrew/bin/brew" ]] then
#   eval "$(/opt/homebrew/bin/brew shellenv)"
# fi
#
################################################################
# Starship
################################################################
eval "$(starship init zsh)"


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
# Zinit Plugins
################################################################
zinit light Aloxaf/fzf-tab
zinit ice depth=1
zinit light jeffreytse/zsh-vi-mode
zinit ice lucid wait
zinit snippet OMZP::fzf
zinit ice lucid
zinit light zsh-users/zsh-syntax-highlighting
zinit ice lucid
zinit light zsh-users/zsh-completions
zinit ice lucid
zinit light zsh-users/zsh-autosuggestions


################################################################
# ZVM Custom Config
################################################################
ZVM_VI_ESCAPE_BINDKEY=^[
ZVM_VI_SURROUND_BINDKEY='classic'
ZVM_LINE_INIT_MODE=$ZVM_MODE_INSERT
ZVM_INSERT_MODE_CURSOR=$ZVM_CURSOR_BLINKING_BEAM
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
# Load completions
################################################################
autoload -Uz compinit
_compdump_path="${ZDOTDIR:-$HOME}/.zcompdump"
if [[ ! -f "$_compdump_path" || "$HOME/.zshrc" -nt "$_compdump_path" ]]; then
  compinit -d "$_compdump_path"
else
  compinit -C -d "$_compdump_path"
fi
zinit cdreplay -q
#

################################################################
# Keybindings
################################################################
bindkey -e
bindkey '^p' history-search-backward
bindkey '^n' history-search-forward
bindkey '^[w' kill-region


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
alias ls="eza --color=always --git --icons=always"
alias lazygit='lazygit --use-config-file=$HOME/.config/lazygit/theme.yml'
alias a='atac'
alias z='zellij'

################################################################
# Shell integrations
################################################################
eval "$(zoxide init --cmd cd zsh)"
eval "$(atuin init zsh)"

################################################################
# Export PATH
################################################################
# Function to get API key from Keychain, suppressing errors
# function get_api_key() {
#     security find-generic-password -a ${USER} -s "$1" -w 2>/dev/null
# }

export PNPM_HOME="$HOME/Library/pnpm"
export EDITOR=nvim
export VISUAL=nvim
export PYENV_ROOT="$HOME/.pyenv"
export XDG_CONFIG_HOME="$HOME/.config"
export ATAC_THEME=$HOME/.config/atac/themes/theme.toml
export ATAC_KEY_BINDINGS=$HOME/.config/atac/key_bindings/vim.toml
export GEMINI_API_KEY=$(pass show Development/Gemini/GEMINI_API_KEY)
export LLM_KEY=$(pass show Development/GitHub/COPILOT_TOKEN)
export OPENAI_API_BASE=$(pass show url/openai_workers)
export OPENAI_API_KEY=$(pass show Development/GitHub/COPILOT_TOKEN)
export COPILOT_TOKEN=$(pass show Development/GitHub/COPILOT_TOKEN)
export OPENAI_KEY=$(pass show Development/GitHub/COPILOT_TOKEN)
export COPILOT_API_ENDPOINT=$(pass show url/copilot_endpoint)
export OPENAI_API_ENDPOINT=$(pass show url/openai_workers)
export AIDER_DARK_MODE=true
export PATH="$PNPM_HOME:$PATH"
export PATH="$PATH:$HOME/.local/bin"
export PATH="$PATH:$HOME/.composer/vendor/bin"
export PATH="/usr/local/elasticsearch/bin:$PATH"
export PATH="$PYENV_ROOT/bin:$PATH"

# Lazy load nvm
lazynvm() {
  unset -f nvm node npm
  export NVM_DIR="$HOME/.nvm"
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
  [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
}

nvm() {
  lazynvm
  nvm "$@"
}

node() {
  lazynvm
  node "$@"
}

npm() {
  lazynvm
  npm "$@"
}

################################################################
## Pyenv setup
################################################################
if command -v pyenv 1>/dev/null 2>&1; then
  eval "$(pyenv init --no-rehash -)"
fi


################################################################
## Yazi setup
################################################################
y() {
  local cwd
  cwd=$(yazi "$@" --cwd-file=-)
  if [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
    cd -- "$cwd"
  fi
}



################################################################
# AI CLI Configuration
################################################################
if command -v ai &> /dev/null; then
    if [ ! -f ~/.ai-shell ]; then
        echo "First time setup: Configuring ai..."
        ai config set OPENAI_KEY="$COPILOT_TOKEN"
        ai config set OPENAI_API_ENDPOINT="$COPILOT_API_ENDPOINT"
        touch ~/.ai-shell
        echo "AI configuration completed."
    fi
fi

# opencode
export PATH=/Users/grandis/.opencode/bin:$PATH
