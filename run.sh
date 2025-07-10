#!/bin/bash
set -e

if ! which zsh &> /dev/null; then
  echo "(1) installing zsh..."
  sudo apt update && sudo apt install -y zsh
else
  echo "(1) zsh already installed!"
fi

if [ ! -d "$HOME/.oh-my-zsh" ]; then
  echo "(2) installing oh-my-zsh.."
  git clone git@github.com:s-1y/oh-my-zsh.git ~/.oh-my-zsh
  cp ~/.oh-my-zsh/templates/zshrc.zsh-template ~/.zshrc
else
  echo "(2) oh-my-zsh already installed!"
fi

P10K_DIR="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"
if [ ! -d "$P10K_DIR" ]; then
  echo "(3) installing powerlevel10k theme..."
  git clone --depth=1 git@github.com:s-1y/powerlevel10k.git "$P10K_DIR"
    if grep -q '^ZSH_THEME=' "$HOME/.zshrc"; then
      sed -i.bak 's|^ZSH_THEME=.*|ZSH_THEME="powerlevel10k/powerlevel10k"|' "$HOME/.zshrc"
    else echo 'ZSH_THEME="powerlevel10k/powerlevel10k"' >> "$HOME/.zshrc"
  fi
else 
  echo "(3) powerlevel10k already installed at $P10K_DIR!"
fi

if [ "$SHELL" != "$(which zsh)" ]; then
  echo "(4) setting default shell..."
  chsh -s "$(which zsh)" "$(whoami)"
else
  echo "(4) zsh is already the default shell"
fi

echo "(5) yanking files..."
ln -s .bashrc ~/.bashrc
ln -s .pip ~/.pip
ln -s .vimrc ~/.vimrc
ln -s .gitconfig ~/.gitconfig
ln -s .gitcommit_template ~/.gitcommit_template
echo "all set!"
