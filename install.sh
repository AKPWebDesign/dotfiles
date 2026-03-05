#!/bin/bash

CURRENT_DIR=`dirname -- "$( readlink -f -- "$0"; )"`

# ensure brew is on PATH when script is run from .zshrc after a pull
if ! command -v brew >/dev/null 2>&1; then
  if [ "$(uname)" = "Darwin" ] && [ -x /opt/homebrew/bin/brew ]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  elif [ -x /home/linuxbrew/.linuxbrew/bin/brew ]; then
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
  fi
fi

# create local env files
touch $CURRENT_DIR/.config/dotfiles/.env-local
touch $CURRENT_DIR/.config/dotfiles/.env-op-service-account

# create local bin folder in case it doesn't exist
mkdir -p $HOME/.local/bin

# install homebrew
NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
if [ "$(uname)" == "Darwin" ]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
else
  eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
fi

# gotta do stow and git-crypt early so files are in their final locations
brew install stow git-crypt
stow . -t "$HOME"

source $HOME/.config/dotfiles/.env

if [ "$(uname)" == "Darwin" ]; then
  brew install 1password-cli gnupg
fi

# skip 1Password/gpg/ssh/git-crypt when run after a pull (op session not available in that context)
if [ -z "$DOTFILES_AFTER_PULL" ]; then
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
fi

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

# install rust
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
source $HOME/.cargo/env # ensure cargo is available for the rest of the install script

# install packages from homebrew
brew install \
  tmux thefuck hub lsd deno llvm \
  golang highlight jq fzf gh bat \
  fd ripgrep volta delta tmux

# oh-my-tmux
git clone --single-branch https://github.com/gpakosz/.tmux.git $HOME/.oh-my-tmux
mkdir -p $HOME/.config/tmux
ln -s -f $HOME/.oh-my-tmux/.tmux.conf $HOME/.config/tmux/tmux.conf

if [ "$(uname)" == "Darwin" ]; then
  brew install --cask font-fira-code-nerd-font font-jetbrains-mono-nerd-font
fi

# set up go folders
mkdir -p $HOME/.go/{bin,src,pkg}
