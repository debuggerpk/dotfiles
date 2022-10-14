# global variables
export CLICOLOR=1
export CLOUDSDK_PYTHON='/usr/bin/python3'
export KEYTIMEOUT=1
export LSCOLORS=GxFxCxDxBxegedabagaced

# history
export HISTSIZE=10000
export SAVEHIST=10000
setopt SHARE_HISTORY

# zsh utilities
if type brew &>/dev/null
then
  FPATH="$(brew --prefix)/share/zsh/site-functions:${FPATH}"
  autoload -Uz compinit
  compinit
fi
autoload -U +X bashcompinit && bashcompinit
autoload -U zmv

# node
export NVM_AUTO_USE=true
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm

# bun
export BUN_INSTALL="/Users/jay/.bun"

# python
eval "$(pyenv init --path)"
eval "$(pyenv virtualenv-init -)"

# go
export GOPATH=$HOME/go
export GOROOT="$(brew --prefix golang)/libexec"


# path
path+=(
  "$HOME/.yarn/bin"
  "$HOME/.config/yarn/global/node_modules/.bin"
  "$HOME/.cargo/bin"
  "$HOME/.poetry/bin"
  "$BUN_INSTALL/bin"
  "$GOPATH/bin"
)

source ~/.zplug/init.zsh

# load plugins
zplug "cpitt/zsh-dotenv",                       from:github
zplug "lukechilds/zsh-nvm",                     from:github
zplug "knu/zsh-manydots-magic",                 use:"manydots-magic"
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

# completions (that are not not found in brew completions)
## gcloud comletions
source "$(brew --prefix)/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/completion.zsh.inc"
## terraform completions
complete -o nospace -C /usr/local/bin/terraform terraform
## bun completions
[ -s "/Users/jay/.bun/_bun" ] && source "/Users/jay/.bun/_bun"

# iterm integration
test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh"

# aliases
alias vi="nvim"
alias vim="nvim"
alias dkrup="docker-compose up"
alias dkrdn="docker-compose down"
alias ls="lsd"

# starship
eval "$(starship init zsh)"
