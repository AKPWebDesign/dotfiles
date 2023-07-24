#!/bin/bash

CURRENT_DIR=`dirname -- "$( readlink -f -- "$0"; )"`

# create required secret file
touch `dirname $0`/.env-secret

# install homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
if [ "$(uname)" == "Darwin" ]; then
  eval "$(/opt/homebrew/bin/brew shellenv)" # make mac homebrew available
else
  eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)" # in case we're on linux instead
fi

# install oh-my-zsh
sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

# remove oh-my-zsh default .zshrc, link to our own
rm -f ~/.zshrc && ln -s `dirname $0`/.zshrc ~/.zshrc

# install powerlevel10k
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k

# install zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions

# install nvm
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh | bash

# install packages from homebrew
brew install tmux thefuck hub lsd deno llvm golang highlight jq fzf gh bat fd ripgrep

if [ "$(uname)" == "Darwin" ]; then
  brew tap homebrew/cask-fonts && brew install --cask font-fira-code-nerd-font
fi

# set up go folders
mkdir -p $HOME/.go/{bin,src,pkg}
