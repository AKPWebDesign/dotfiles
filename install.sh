#!/bin/bash

CURRENT_DIR=`dirname -- "$( readlink -f -- "$0"; )"`

# create local env files
touch $CURRENT_DIR/.config/dotfiles/.env-local
touch $CURRENT_DIR/.config/dotfiles/.env-op-service-account

# create local bin folder in case it doesn't exist
mkdir -p $HOME/.local/bin

# install homebrew
NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
if [ "$(uname)" == "Darwin" ]; then
  eval "$(/opt/homebrew/bin/brew shellenv)" # make mac homebrew available
else
  eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)" # in case we're on linux instead
fi

# gotta do stow and git-crypt early so files are in their final locations
brew install stow git-crypt
stow .

source $HOME/.config/dotfiles/.env

if [ "$(uname)" == "Darwin" ]; then
  brew install 1password-cli gnupg
fi

# set up gpg key password caching and import gpg key
export GPG_TTY=$(tty)
source $HOME/.config/dotfiles/.gpg
op read op://secrets/gpg/private.key | gpg --import --batch --passphrase $(op read op://secrets/gpg/password)

# install ssh key
mkdir -p $HOME/.ssh
op read op://secrets/ssh/private_key > $HOME/.ssh/id_ed25519
chmod 600 $HOME/.ssh/id_ed25519

# git-crypt should be ready to go now
git-crypt unlock

# install oh-my-zsh
sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

# oh-my-zsh probably moved our .zshrc, let's put it back.
rm -f $HOME/.zshrc $HOME/.zshrc.pre-oh-my-zsh
stow . -t $HOME

# install powerlevel10k
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k

# install zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions

# install fzf-tab
git clone https://github.com/Aloxaf/fzf-tab ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/fzf-tab

# install nvm
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh | bash

# install tailscale
curl -fsSL https://tailscale.com/install.sh | sh

# install packages from homebrew
brew install \
  tmux thefuck hub lsd deno llvm \
  golang highlight jq fzf gh bat \
  fd ripgrep volta delta tmux
  
# oh-my-tmux
git clone --single-branch https://github.com/gpakosz/.tmux.git $HOME/.tmux
ln -s -f $HOME/.tmux/.tmux.conf $HOME/.tmux.conf

if [ "$(uname)" == "Darwin" ]; then
  brew install --cask font-fira-code-nerd-font font-jetbrains-mono-nerd-font
fi

# set up go folders
mkdir -p $HOME/.go/{bin,src,pkg}
