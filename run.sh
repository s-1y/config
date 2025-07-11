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


if [ "$(getent passwd "$USER" | cut -d: -f7)" != "$(which zsh)" ]; then
  echo "(6) Setting default shell..."
  chsh -s "$(which zsh)" "$(whoami)"
else
  echo "(6) Zsh is already the default shell!"
fi

rm -rf ~/.pip
ln -sf "$PWD/.pip" ~/.pip
ln -sf "$PWD/.vimrc" ~/.vimrc
ln -sf "$PWD/.gitconfig" ~/.gitconfig
ln -sf "$PWD/.gitcommit_template" ~/.gitcommit_template
echo "(7) Symbolic links created successfully!"

MINIFORGE_DIR="$HOME/miniforge3"
if [ -d "$MINIFORGE_DIR" ] ||
   [ -d "$HOME/anaconda3" ] ||
   [ -d "HOME/miniconda3"] ||
   command -v conda &>/dev/null; then
  echo "(8) Conda already installed!"
else
  echo "(8) Installing Miniforge..."
  INSTALLER="Miniforge3-Linux-x86_64.sh"
  URL="https://github.com/conda-forge/miniforge/releases/latest/download/$INSTALLER"
  curl -L -o "$INSTALLER" "$URL"
  bash "$INSTALLER" -p "$MINIFORGE_DIR"
  rm "$INSTALLER"
fi

source "$MINIFORGE_DIR/etc/profile.d/conda.sh"

if ! conda list -n base | grep -q '^mamba\s'; then
    echo "(9) Installing mamba..."
    conda install -n base -c conda-forge mamba -y
else
    echo "(9) Mamba is already installed"
fi

KEY="alias c='conda'"
ALIASES=(
    "alias c='conda'"
    "alias ca='conda activate'"
    "alias cd='conda deactivate'"
    "alias cl='conda list'"
    "alias cc='conda create -n'"
    "alias ci='conda install'"
    "alias cer='conda env remove -n'"
    "alias m='mamba'"
    "alias ma='mamba activate'"
    "alias md='mamba deactivate'"
    "alias ml='mamba list'"
    "alias mi='mamba install'"
    "alias mc='mamba create -n'"
    "alias mer='mamba env remove -n'"
)
if ! grep -qF "$KEY" ~/.zshrc; then
  echo "(10) Adding conda/mamba liases to ~/.zshrc..."
  echo "" >> ~/.zshrc
  echo "# Conda shortcuts [auto-added]" >> ~/.zshrc
  for alias_line in "${ALIASES[@]}"; do
    echo "$alias_line" >> ~/.zshrc
  done
else
  echo "(10) Conda aliases already exists!"
fi

FONT_NAME="MesloLGS"
FONT_DIR="$HOME/.local/share/fonts"
MESLO_URL_BASE="https://github.com/romkatv/powerlevel10k-media/raw/master/"
FONTS=(
  "MesloLGS%20NF%20Regular.ttf"
  "MesloLGS%20NF%20Bold.ttf"
  "MesloLGS%20NF%20Italic.ttf"
  "MesloLGS%20NF%20Bold%20Italic.ttf"

)
if fc-list | grep -qi "$FONT_NAME"; then
  echo "(11) Font '$FONT_NAME' already installed!"
else
  echo "(11) Installing font '$FONT_NAME'..."

  mkdir -p "$FONT_DIR"

  for font in "${FONTS[@]}"; do
    wget --show-progress "${MESLO_URL_BASE}${font}" -O "$FONT_DIR/$(echo "$font" | sed 's/%20/ /g')"
  done
  fc-cache -fv > /dev/null
  echo "Fonts installed successfully!"
fi

echo "(√) All tasks completed! Please restart your terminal to apply changes!"
