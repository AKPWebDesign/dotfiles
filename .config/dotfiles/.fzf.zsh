if [ "$(uname)" = "Darwin" ]; then
  export FZF_DIR="/opt/homebrew/opt/fzf"
else
  export FZF_DIR="/home/linuxbrew/.linuxbrew/opt/fzf"
fi

# Setup fzf
# ---------
if [[ ! "$PATH" == *$FZF_DIR* ]]; then
  PATH="${PATH:+${PATH}:}$FZF_DIR/bin"
fi

# Auto-completion
# ---------------
[[ $- == *i* ]] && source "$FZF_DIR/shell/completion.zsh" 2> /dev/null

# Key bindings
# ------------
source "$FZF_DIR/shell/key-bindings.zsh"
