
source $HOME/.dotfiles/zsh/antigen.zsh
source $HOME/.dotfiles/zsh/aliases.zsh

# Load the oh-my-zsh's library.
antigen use oh-my-zsh

# Bundles from the default repo (robbyrussell's oh-my-zsh).
antigen bundle git
antigen bundle pip
antigen bundle docker
antigen bundle zpm-zsh/ls
antigen bundle docker-compose
antigen bundle command-not-found

# Syntax highlighting bundle.
antigen bundle zsh-users/zsh-syntax-highlighting

# Load the theme.
antigen theme obraun

# Tell Antigen that you're done.
antigen apply
