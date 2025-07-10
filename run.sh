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

SYNTAX_DIR="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting"
if [ ! -d "$SYNTAX_DIR" ]; then
  echo "(4) Installing zsh-syntax-highlighting"
  git clone --depth=1 git@github.com:s-1y/zsh-syntax-highlighting.git "$SYNTAX_DIR"
  if ! grep -q "zsh-syntax-highlighting" ~/.zshrc; then
    sed -i.bak 's/^plugins=(/plugins=( zsh-syntax-highlighting /' ~/.zshrc
  fi
else echo "(4) Zsh-syntax-highlighting already installed!"
fi

AUTO_DIR="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions"
if [ ! -d "$AUTO_DIR" ]; then
  echo "(5) Installing zsh-autosuggestions"
  git clone --depth=1 git@github.com:s-1y/zsh-autosuggestions.git "$AUTO_DIR"
  if ! grep -q "zsh-autosuggestions" ~/.zshrc; then
    sed -i.bak 's/^plugins=(/plugins=( zsh-autosuggestions /' ~/.zshrc
  fi
else echo "(5) Zsh-autosuggestions already installed!"
fi


if [ "$SHELL" != "$(which zsh)" ]; then
  echo "(6) Setting default shell..."
  chsh -s "$(which zsh)" "$(whoami)"
else
  echo "(6) Zsh is already the default shell!"
fi

ln -sf "$PWD/.bashrc" ~/.bashrc
rm -r ~/.pip
ln -sf "$PWD/.pip" ~/.pip
ln -sf "$PWD/.vimrc" ~/.vimrc
ln -sf "$PWD/.gitconfig" ~/.gitconfig
ln -sf "$PWD/.gitcommit_template" ~/.gitcommit_template
echo "(7) Symbolic links created successfully!"

MINIFORGE_DIR="$HOME/miniforge3"
if [ -d "$MINIFORGE_DIR" ]; then
  echo "(8) Miniforge already installed!"
else
  echo "(8) Installing Miniforge..."
  INSTALLER="Miniforge3-Linux-x86_64.sh"
  URL="https://github.com/conda-forge/miniforge/releases/latest/download/$INSTALLER"
  curl -L -o "$INSTALLER" "$URL"
  bash "$INSTALLER" -b -p "$MINIFORGE_DIR"
  rm "$INSTALLER"
fi
echo "(9) All tasks completed! Please restart your terminal to apply changes!"
