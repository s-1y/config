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
   [ -d "HOME/miniconda3" ] ||
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
    "alias cdd='conda deactivate'"
    "alias cl='conda list'"
    "alias cc='conda create -n'"
    "alias ci='conda install'"
    "alias cer='conda env remove -n'"
    "alias cel='conda env list'"
    "alias m='mamba'"
    "alias ma='mamba activate'"
    "alias md='mamba deactivate'"
    "alias ml='mamba list'"
    "alias mi='mamba install'"
    "alias mc='mamba create -n'"
    "alias mer='mamba env remove -n'"
    "alias mel='mamba env list'"
)
if ! grep -qF "$KEY" ~/.zshrc; then
  echo "(10) Adding conda/mamba aliases to ~/.zshrc..."
  echo "" >> ~/.zshrc
  echo "# Conda shortcuts [auto-added]" >> ~/.zshrc
  for alias_line in "${ALIASES[@]}"; do
    echo "$alias_line" >> ~/.zshrc
    echo "$alias_line"
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

if ! command -v tmux &> /dev/null; then
  echo "(12) Installing tmux"
  sudo apt-get install -y tmux
else
  echo "(12) Tmux already installed!"
fi


OH_MY_TMUX_DIR="$HOME/.oh-my-tmux"
OH_MY_TMUX_REPO="git@github.com:s-1y/.tmux.git"

if [ ! -d "$OH_MY_TMUX_DIR" ]; then
    echo "(13) Installing oh-my-tmux..."
    git clone --depth=1 "$OH_MY_TMUX_REPO" "$OH_MY_TMUX_DIR"
    if [ -f "$HOME/.tmux.conf" ]; then
        mv "$HOME/.tmux.conf" "$HOME/.tmux.conf.bak"
    fi
    ln -s -f "$OH_MY_TMUX_DIR/.tmux.conf" "$HOME/.tmux.conf"
    cp "$OH_MY_TMUX_DIR/.tmux.conf.local" "$HOME/"
else
    echo "(13) Oh-my-tmux already installed!"
fi

TMUX_CONF_LOCAL="$HOME/.tmux.conf.local"
KEY_LINES=(
  "bind | split-window -h"
  "bind - split-window -v"
  "set -g @tmux-plugin-istat enable"
)
CONFIG_CONTENT='
# ====== 自定义快捷键 ======
# 前缀键设为 Ctrl + a
set -g prefix C-a
bind C-a send-prefix

# 窗格操作
bind | split-window -h -c "#{pane_current_path}"  # 垂直分割
bind - split-window -v -c "#{pane_current_path}"  # 水平分割

# 窗口操作
# ===== 自定义插件 =====
bind n next-window
bind p previous-window
set -g @plugin "tmux-plugins/tpm"
set -g @plugin "tmux-plugins/tmux-net-speed"
set -g @plugin "tmux-plugins/tmux-cpu"
set -g @plugin "user/tmux-plugin-istat"  
set -g @tmux-plugin-istat enable
set -g @plugin-network-format "▲ %s ▼ %s"
run "~/.tmux/plugins/tpm/tpm"
'
config_exists=true
for line in "${KEY_LINES[@]}"; do
  if ! grep -qF "$line" "$TMUX_CONF_LOCAL"; then
    config_exists=false
	break
  fi
done
if $config_exists; then
  echo "(14) Tmux alias already exists!"
else
  echo "(14) Adding tmux alises..."
  echo "$CONFIG_CONTENT" >> "$TMUX_CONF_LOCAL"
fi

echo "(√) All tasks completed! Please restart your terminal to apply changes!"
