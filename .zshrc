# global variables
export CLICOLOR=1
export CLOUDSDK_PYTHON='/usr/bin/python3'
export KEYTIMEOUT=1
export LSCOLORS=GxFxCxDxBxegedabagaced
export NVM_AUTO_USE=true
export NVM_DIR="$HOME/.nvm"

# history
export HISTSIZE=10000
export SAVEHIST=10000
setopt SHARE_HISTORY

# Auto Complete
autoload -Uz compinit && compinit

# node
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm

# python
eval "$(pyenv init --path)"
eval "$(pyenv virtualenv-init -)"

# completions
## assuming zsh installs 
for f (/usr/local/share/zsh/site-functions/*(.N)) source $f

# path
path+=(
  "$HOME/.yarn/bin"
  "$HOME/.config/yarn/global/node_modules/.bin"
  "$HOME/.cargo/bin"
)

# load zplug
source ~/.zplug/init.zsh

# load plugins
zplug "cpitt/zsh-dotenv",                       from:github
zplug "lukechilds/zsh-nvm",                     from:github
zplug "knu/zsh-manydots-magic",                 use:"manydots-magic"
zplug "zsh-users/zsh-completions",              from:github
zplug "zsh-users/zsh-history-substring-search", defer:1
zplug "zsh-users/zsh-syntax-highlighting",      defer:1
zplug "zsh-users/zsh-autosuggestions",          defer:1

# zplug init
if ! zplug check --verbose; then
  printf "Install? [y/N]: "
  if read -q; then
      echo; zplug install
  fi
fi

zplug load --verbose

# zplug plugin configurations
if zplug check zsh-users/zsh-autosuggestions; then
  ZSH_AUTOSUGGEST_CLEAR_WIDGETS+=(history-substring-search-up history-substring-search-down)
  ZSH_AUTOSUGGEST_CLEAR_WIDGETS=("${(@)ZSH_AUTOSUGGEST_CLEAR_WIDGETS:#(up|down)-line-or-history}")
fi

bindkey -v

if zplug check zsh-users/zsh-history-substring-search; then
  bindkey '^[[A' history-substring-search-up
  bindkey '^[[B' history-substring-search-down
fi

# starship
eval "$(starship init zsh)"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion