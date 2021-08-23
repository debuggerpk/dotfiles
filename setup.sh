#!/usr/bin/env bash
echo "Install Homebrew (https://brew.sh)"
/bin/bash <(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)
## install & activate zplug
echo "Install zplug"
curl -sL --proto-redir -all,https https://raw.githubusercontent.com/zplug/installer/master/installer.zsh | zsh
## clone dotfiles to $HOME/dotfiles
echo "Preparing"
git clone git@github.com:debuggerpk/dotfiles.git ~/dotfiles

## Backup Existing .zshrc, and create a link to ~/dotfiles/.zshrc in $HOME
[ -s "${HOME}/.zshrc" ] && mv ${HOME}/.zshrc ${HOME}/.zshrc.bck
ln -s ${HOME}/dotfiles/.zshrc ${HOME}/.zshrc

## install all packages via brew
echo "Package Installation via HomeBrewu"
CURRENT_DIR=`pwd`
export CLOUDSDK_PYTHON='/usr/bin/python3'
cd ${HOME}/dotfiles
brew bundle
cd ${CURRENT_DIR}

## install other packages
# install nvm
echo "Preparing Dev Environment"
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.38.0/install.sh | bash
# install rust
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
