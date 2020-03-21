#!/usr/bin/env bash
# install brew
/bin/bash <(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)
# install & activate zplug
curl -sL --proto-redir -all,https https://raw.githubusercontent.com/zplug/installer/master/installer.zsh | zsh
source ~/.zplug/init.zsh

# clone dotfiles to $HOME/dotfiles
git clone git@github.com:getbreu/dotfiles.git ~/dotfiles

# Backup Existing .zshrc, and create a link to ~/dotfiles/.zshrc in $HOME
[ -s "${HOME}/.zshrc" ] && mv ${HOME}/.zshrc ${HOME}/.zshrc.bck
ln -s ${HOME}/dotfiles/.zshrc ${HOME}/.zshrc

# install all packages via brew
CURRENT_DIR=`pwd`
export CLOUDSDK_PYTHON='/usr/bin/python3'
cd ${HOME}/dotfiles
brew bundle
cd ${CURRENT_DIR}
