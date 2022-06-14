#!/bin/bash

# create required secret file
touch `dirname $0`/.env-secret

# install homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
eval "$(/opt/homebrew/bin/brew shellenv)"

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
brew install tmux thefuck hub lsd deno llvm golang highlight jq
brew tap homebrew/cask-fonts && brew install --cask font-fira-code-nerd-font

# set up go folders
mkdir -p $HOME/.go/{bin,src,pkg}
