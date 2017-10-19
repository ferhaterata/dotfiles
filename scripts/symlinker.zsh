#!/bin/zsh

echo "\nSymlinking all dotfiles"

# Glob hidden files
setopt glob_dots

# Symlink all home directory dotfiles
ln -svf $DOTREPO/home/* $HOME

# Symlink all configuration folders to .config
ln -svf $DOTREPO/config/* $HOME/.config

# Symlink all ZSH_CUSTOM files
ln -svf $DOTREPO/zsh_custom/* $HOME/.oh-my-zsh/custom
