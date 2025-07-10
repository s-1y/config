#!/bin/bash
set -e

if ! command -v zsh > /dev/null; then
  echo "(1) Installing zsh..."
  sudo apt update && sudo apt install -y zsh
else
  echo "(1) Zsh already installed!"
fi

if [ ! -d "$HOME/.oh-my-zsh" ]; then
  echo "(2) Installing oh-my-zsh.."
  git clone git@github.com:s-1y/oh-my-zsh.git ~/.oh-my-zsh
  cp ~/.oh-my-zsh/templates/zshrc.zsh-template ~/.zshrc
else
  echo "(2) Oh-my-zsh already installed!"
fi

P10K_DIR="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"
if [ ! -d "$P10K_DIR" ]; then
  echo "(3) Installing powerlevel10k theme..."
  git clone --depth=1 git@github.com:s-1y/powerlevel10k.git "$P10K_DIR"
    if grep -q '^ZSH_THEME=' "$HOME/.zshrc"; then
      sed -i.bak 's|^ZSH_THEME=.*|ZSH_THEME="powerlevel10k/powerlevel10k"|' "$HOME/.zshrc"
    else echo 'ZSH_THEME="powerlevel10k/powerlevel10k"' >> "$HOME/.zshrc"
  fi
else 
  echo "(3) Powerlevel10k already installed!"
fi

if [ "$SHELL" != "$(which zsh)" ]; then
  echo "(4) Setting default shell..."
  chsh -s "$(which zsh)" "$(whoami)"
else
  echo "(4) Zsh is already the default shell"
fi

ln -sf "$PWD/.bashrc" ~/.bashrc
rm -r ~/.pip
ln -sf "$PWD/.pip" ~/.pip
ln -sf "$PWD/.vimrc" ~/.vimrc
ln -sf "$PWD/.gitconfig" ~/.gitconfig
ln -sf "$PWD/.gitcommit_template" ~/.gitcommit_template
echo "(5) Symbolic links created successfully!"

echo "(6) All tasks completed!"
