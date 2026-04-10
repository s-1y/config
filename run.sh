#!/bin/bash
set -e
 
# ─────────────────────────────────────────────
#  Helper: ask user yes/no, return 0=yes 1=no
# ─────────────────────────────────────────────
ask() {
  local prompt="$1"
  while true; do
    read -r -p "$prompt [yes/no] " ans
    case "${ans,,}" in
      yes|y) return 0 ;;
      no|n)  return 1 ;;
      *)     echo "  Please answer yes or no." ;;
    esac
  done
}
 
# ─────────────────────────────────────────────
#  Helper: on failure, ask whether to skip
# ─────────────────────────────────────────────
failed_skip() {
  local step="$1"
  echo "  ✗ Step $step failed."
  if ask "  Skip step $step and continue?"; then
    echo "  → Skipping step $step."
    return 0
  else
    echo "  Aborting."
    exit 1
  fi
}
 
echo ""
echo "======================================================"
echo "        Ubuntu Environment Setup Script"
echo "======================================================"
echo ""
 
# ══════════════════════════════════════════════
# (1) zsh
# ══════════════════════════════════════════════
echo "--- (1) zsh ---"
if command -v zsh > /dev/null 2>&1; then
  echo "  ✓ zsh is already installed. Skipping."
else
  echo "  zsh is not installed."
  if ask "  Install zsh? (requires sudo)"; then
    if sudo apt update && sudo apt install -y zsh; then
      echo "  ✓ zsh installed successfully."
    else
      failed_skip "1"
    fi
  else
    echo "  → Skipping zsh installation."
  fi
fi
 
# ══════════════════════════════════════════════
# (2) oh-my-zsh
# ══════════════════════════════════════════════
echo ""
echo "--- (2) oh-my-zsh ---"
if [ -d "$HOME/.oh-my-zsh" ]; then
  echo "  ✓ oh-my-zsh is already installed. Skipping."
else
  echo "  oh-my-zsh is not installed."
  if ask "  Install oh-my-zsh?"; then
    if git clone https://github.com/s-1y/oh-my-zsh.git ~/.oh-my-zsh && \
       cp ~/.oh-my-zsh/templates/zshrc.zsh-template ~/.zshrc; then
      echo "  ✓ oh-my-zsh installed and ~/.zshrc initialized."
    else
      failed_skip "2"
    fi
  else
    echo "  → Skipping oh-my-zsh installation."
  fi
fi
 
# ══════════════════════════════════════════════
# (3) powerlevel10k
# ══════════════════════════════════════════════
echo ""
echo "--- (3) powerlevel10k theme ---"
P10K_DIR="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"
if [ -d "$P10K_DIR" ]; then
  echo "  ✓ powerlevel10k is already installed. Skipping."
else
  echo "  powerlevel10k theme is not installed."
  if ask "  Install powerlevel10k?"; then
    if git clone --depth=1 https://github.com/s-1y/powerlevel10k.git "$P10K_DIR"; then
      if grep -q '^ZSH_THEME=' "$HOME/.zshrc"; then
        sed -i.bak 's|^ZSH_THEME=.*|ZSH_THEME="powerlevel10k/powerlevel10k"|' "$HOME/.zshrc"
      else
        echo 'ZSH_THEME="powerlevel10k/powerlevel10k"' >> "$HOME/.zshrc"
      fi
      echo "  ✓ powerlevel10k installed and ZSH_THEME set in ~/.zshrc."
    else
      failed_skip "3"
    fi
  else
    echo "  → Skipping powerlevel10k installation."
  fi
fi
 
# ══════════════════════════════════════════════
# (4) zsh-syntax-highlighting
# ══════════════════════════════════════════════
echo ""
echo "--- (4) zsh-syntax-highlighting ---"
SYNTAX_DIR="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting"
if [ -d "$SYNTAX_DIR" ]; then
  echo "  ✓ zsh-syntax-highlighting is already installed. Skipping."
else
  echo "  zsh-syntax-highlighting plugin is not installed."
  if ask "  Install zsh-syntax-highlighting?"; then
    if git clone --depth=1 https://github.com/s-1y/zsh-syntax-highlighting.git "$SYNTAX_DIR"; then
      if ! grep -q "zsh-syntax-highlighting" ~/.zshrc; then
        sed -i.bak 's/^plugins=(/plugins=( zsh-syntax-highlighting /' ~/.zshrc
      fi
      echo "  ✓ zsh-syntax-highlighting installed and added to plugins in ~/.zshrc."
    else
      failed_skip "4"
    fi
  else
    echo "  → Skipping zsh-syntax-highlighting installation."
  fi
fi
 
# ══════════════════════════════════════════════
# (5) zsh-autosuggestions
# ══════════════════════════════════════════════
echo ""
echo "--- (5) zsh-autosuggestions ---"
AUTO_DIR="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions"
if [ -d "$AUTO_DIR" ]; then
  echo "  ✓ zsh-autosuggestions is already installed. Skipping."
else
  echo "  zsh-autosuggestions plugin is not installed."
  if ask "  Install zsh-autosuggestions?"; then
    if git clone --depth=1 https://github.com/s-1y/zsh-autosuggestions.git "$AUTO_DIR"; then
      if ! grep -q "zsh-autosuggestions" ~/.zshrc; then
        sed -i.bak 's/^plugins=(/plugins=( zsh-autosuggestions /' ~/.zshrc
      fi
      echo "  ✓ zsh-autosuggestions installed and added to plugins in ~/.zshrc."
    else
      failed_skip "5"
    fi
  else
    echo "  → Skipping zsh-autosuggestions installation."
  fi
fi
 
# ══════════════════════════════════════════════
# (6) Set default shell to zsh
# ══════════════════════════════════════════════
echo ""
echo "--- (6) Default shell ---"
if [ "$(getent passwd "$USER" | cut -d: -f7)" = "$(which zsh 2>/dev/null)" ]; then
  echo "  ✓ zsh is already the default shell. Skipping."
else
  echo "  Default shell is not zsh."
  if ask "  Set zsh as the default shell? (uses chsh, may require sudo)"; then
    if chsh -s "$(which zsh)" "$(whoami)"; then
      echo "  ✓ Default shell set to zsh. Takes effect on next login."
    else
      failed_skip "6"
    fi
  else
    echo "  → Skipping default shell change."
  fi
fi
 
# ══════════════════════════════════════════════
# (7) Symbolic links + config descriptions
# ══════════════════════════════════════════════
echo ""
echo "--- (7) Symbolic links (.pip / .vimrc / .gitconfig / .gitcommit_template) ---"
 
LINKS_OK=true
for f in .pip .vimrc .gitconfig .gitcommit_template; do
  target="$HOME/$f"
  source="$PWD/$f"
  if [ -L "$target" ] && [ "$(readlink "$target")" = "$source" ]; then
    : # already correct
  else
    LINKS_OK=false
    break
  fi
done
 
if $LINKS_OK; then
  echo "  ✓ All symbolic links already exist and are correct. Skipping."
else
  echo "  Some symbolic links are missing or incorrect."
  if ask "  Create/update symbolic links? (will overwrite existing files in ~/)"; then
    rm -rf ~/.pip
    ln -sf "$PWD/.pip" ~/.pip
    ln -sf "$PWD/.vimrc" ~/.vimrc
    ln -sf "$PWD/.gitconfig" ~/.gitconfig
    ln -sf "$PWD/.gitcommit_template" ~/.gitcommit_template
    echo "  ✓ Symbolic links created."
    echo ""
    echo "  ┌─ .vimrc highlights ──────────────────────────────────┐"
    echo "  │  jk          → Exit insert mode (replaces ESC)       │"
    echo "  │  Syntax highlight, line numbers, tab=4 spaces        │"
    echo "  │  Auto-indent, UTF-8, case-insensitive search         │"
    echo "  │  Bracket match highlight (showmatch)                 │"
    echo "  └──────────────────────────────────────────────────────┘"
    echo ""
    echo "  ┌─ .gitconfig aliases ─────────────────────────────────┐"
    echo "  │  a           → git add                               │"
    echo "  │  ci          → git commit                            │"
    echo "  │  co          → git checkout                          │"
    echo "  │  st          → git status                            │"
    echo "  │  br          → git branch                            │"
    echo "  │  ps          → git push                              │"
    echo "  │  pu          → git pull                              │"
    echo "  │  pom         → git push origin main                  │"
    echo "  │  l           → oneline log with decorations          │"
    echo "  │  lg          → colorful graph log with author/time   │"
    echo "  │  Default editor: vim  |  Default branch: main        │"
    echo "  │  Commit template: ~/.gitcommit_template              │"
    echo "  └──────────────────────────────────────────────────────┘"
  else
    echo "  → Skipping symbolic links."
  fi
fi
 
# ══════════════════════════════════════════════
# (8) Miniforge3
# ══════════════════════════════════════════════
echo ""
echo "--- (8) Miniforge3 ---"
INSTALLER="Miniforge3-Linux-x86_64.sh"
URL="https://github.com/conda-forge/miniforge/releases/latest/download/$INSTALLER"
INSTALL_MINIFORGE=false
MINIFORGE_DIR=""
 
if ask "  Install Miniforge3?"; then
  read -r -p "  Enter install directory [~/miniforge3]: " MF_DIR_IN
  [ -n "$MF_DIR_IN" ] || MF_DIR_IN="~/miniforge3"
  eval "MINIFORGE_DIR=\"$MF_DIR_IN\""
 
  if [ -d "$MINIFORGE_DIR" ]; then
    echo "  ✓ Miniforge3 already exists at $MINIFORGE_DIR. Skipping download and install."
    INSTALL_MINIFORGE=true
  else
    echo "  Installing Miniforge3 to $MINIFORGE_DIR... (Press enter to use default path)"
    if curl -L -o "$INSTALLER" "$URL" && bash "$INSTALLER" -p "$MINIFORGE_DIR"; then
      rm -f "$INSTALLER"
      echo "  ✓ Miniforge3 installed at $MINIFORGE_DIR."
      INSTALL_MINIFORGE=true
    else
      rm -f "$INSTALLER"
      failed_skip "8"
    fi
  fi
else
  echo "  → Skipping Miniforge3 installation."
fi
 
# ══════════════════════════════════════════════
# (9) mamba
# ══════════════════════════════════════════════
echo ""
echo "--- (9) mamba ---"
if [ "$INSTALL_MINIFORGE" = true ] && [ -n "$MINIFORGE_DIR" ] && [ -d "$MINIFORGE_DIR" ]; then
  # shellcheck source=/dev/null
  source "$MINIFORGE_DIR/etc/profile.d/conda.sh" 2>/dev/null || true
  if conda list -n base 2>/dev/null | grep -q '^mamba\s'; then
    echo "  ✓ mamba is already installed in base environment. Skipping."
  else
    echo "  mamba is not installed in the base environment."
    if ask "  Install mamba into conda base?"; then
      if conda install -n base -c conda-forge mamba -y; then
        echo "  ✓ mamba installed in base environment."
      else
        failed_skip "9"
      fi
    else
      echo "  → Skipping mamba installation."
    fi
  fi
else
  echo "  Miniforge3 not installed — skipping mamba."
fi
 
# ══════════════════════════════════════════════
# (10) conda / mamba aliases
# ══════════════════════════════════════════════
echo ""
echo "--- (10) conda/mamba aliases ---"
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
 
if grep -qF "$KEY" ~/.zshrc 2>/dev/null; then
  echo "  ✓ conda/mamba aliases already exist in ~/.zshrc. Skipping."
else
  echo "  conda/mamba aliases not found in ~/.zshrc."
  if ask "  Add conda/mamba shortcut aliases to ~/.zshrc?"; then
    {
      echo ""
      echo "# Conda/Mamba shortcuts [auto-added]"
      for alias_line in "${ALIASES[@]}"; do
        echo "$alias_line"
      done
    } >> ~/.zshrc
    echo "  ✓ Aliases added to ~/.zshrc."
    echo ""
    echo "  ┌─ conda aliases ──────────────────────────────────────┐"
    echo "  │  c   → conda          ca  → conda activate           │"
    echo "  │  cdd → conda deact.   cl  → conda list               │"
    echo "  │  cc  → conda create   ci  → conda install            │"
    echo "  │  cer → env remove     cel → env list                 │"
    echo "  └──────────────────────────────────────────────────────┘"
    echo "  ┌─ mamba aliases ──────────────────────────────────────┐"
    echo "  │  m   → mamba          ma  → mamba activate           │"
    echo "  │  md  → mamba deact.   ml  → mamba list               │"
    echo "  │  mc  → mamba create   mi  → mamba install            │"
    echo "  │  mer → env remove     mel → env list                 │"
    echo "  └──────────────────────────────────────────────────────┘"
  else
    echo "  → Skipping alias setup."
  fi
fi
 
# ══════════════════════════════════════════════
# (11) tmux
# ══════════════════════════════════════════════
echo ""
echo "--- (11) tmux ---"
TMUX_INSTALLED=false
if command -v tmux &> /dev/null; then
  echo "  ✓ tmux is already installed. Skipping."
  TMUX_INSTALLED=true
else
  echo "  tmux is not installed."
  if ask "  Install tmux via apt? (requires sudo)"; then
    if sudo apt-get install -y tmux; then
      echo "  ✓ tmux installed via apt."
      TMUX_INSTALLED=true
    else
      echo "  ✗ apt install failed."
      if ask "  Try installing tmux via conda instead?"; then
        if conda install -c conda-forge tmux -y 2>/dev/null || \
           mamba install -c conda-forge tmux -y 2>/dev/null; then
          echo "  ✓ tmux installed via conda."
          TMUX_INSTALLED=true
        else
          echo "  ✗ conda install also failed."
          if ask "  Skip tmux and continue?"; then
            echo "  → Skipping tmux installation."
          else
            echo "  Aborting."
            exit 1
          fi
        fi
      else
        if ask "  Skip tmux and continue?"; then
          echo "  → Skipping tmux installation."
        else
          echo "  Aborting."
          exit 1
        fi
      fi
    fi
  else
    echo "  → Skipping tmux installation."
  fi
fi
 
# ══════════════════════════════════════════════
# (12) oh-my-tmux
# ══════════════════════════════════════════════
echo ""
echo "--- (12) oh-my-tmux ---"
OH_MY_TMUX_DIR="$HOME/.oh-my-tmux"
OH_MY_TMUX_REPO="https://github.com/s-1y/.tmux.git"
 
if [ "$TMUX_INSTALLED" = false ]; then
  echo "  tmux not installed — skipping oh-my-tmux."
elif [ -d "$OH_MY_TMUX_DIR" ]; then
  echo "  ✓ oh-my-tmux is already installed. Skipping."
else
  echo "  oh-my-tmux is not installed."
  if ask "  Install oh-my-tmux?"; then
    if git clone --depth=1 "$OH_MY_TMUX_REPO" "$OH_MY_TMUX_DIR"; then
      [ -f "$HOME/.tmux.conf" ] && mv "$HOME/.tmux.conf" "$HOME/.tmux.conf.bak"
      ln -sf "$OH_MY_TMUX_DIR/.tmux.conf" "$HOME/.tmux.conf"
      cp "$OH_MY_TMUX_DIR/.tmux.conf.local" "$HOME/"
      echo "  ✓ oh-my-tmux installed, ~/.tmux.conf symlinked, .tmux.conf.local copied."
    else
      failed_skip "12"
    fi
  else
    echo "  → Skipping oh-my-tmux installation."
  fi
fi
 
# ══════════════════════════════════════════════
# (13) tmux custom keybindings & plugins
# ══════════════════════════════════════════════
echo ""
echo "--- (13) tmux custom keybindings & plugins ---"
TMUX_CONF_LOCAL="$HOME/.tmux.conf.local"
 
KEY_LINES=(
  "bind | split-window -h"
  "bind - split-window -v"
  "set -g @tmux-plugin-istat enable"
)
 
CONFIG_CONTENT='
# ====== Custom keybindings ======
# Prefix: Ctrl + a
set -g prefix C-a
bind C-a send-prefix
 
# Pane splitting
bind | split-window -h -c "#{pane_current_path}"  # vertical split
bind - split-window -v -c "#{pane_current_path}"  # horizontal split
 
# Window navigation
bind n next-window
bind p previous-window
 
# ====== Plugins ======
set -g @plugin "tmux-plugins/tpm"
set -g @plugin "tmux-plugins/tmux-net-speed"
set -g @plugin "tmux-plugins/tmux-cpu"
set -g @plugin "user/tmux-plugin-istat"
set -g @tmux-plugin-istat enable
set -g @plugin-network-format "▲ %s ▼ %s"
run "~/.tmux/plugins/tpm/tpm"
'
 
if [ "$TMUX_INSTALLED" = false ]; then
  echo "  tmux not installed — skipping custom config."
elif [ ! -f "$TMUX_CONF_LOCAL" ]; then
  echo "  ~/.tmux.conf.local not found — skipping custom config."
else
  config_exists=true
  for line in "${KEY_LINES[@]}"; do
    if ! grep -qF "$line" "$TMUX_CONF_LOCAL"; then
      config_exists=false
      break
    fi
  done
 
  if $config_exists; then
    echo "  ✓ tmux custom config already exists. Skipping."
  else
    echo "  tmux custom keybindings not found in ~/.tmux.conf.local."
    if ask "  Add custom keybindings and plugins to ~/.tmux.conf.local?"; then
      echo "$CONFIG_CONTENT" >> "$TMUX_CONF_LOCAL"
      echo "  ✓ tmux config added to ~/.tmux.conf.local."
      echo ""
      echo "  ┌─ tmux keybindings ───────────────────────────────────┐"
      echo "  │  Prefix          → Ctrl + a  (replaces Ctrl + b)     │"
      echo "  │  Prefix + |      → Split pane vertically             │"
      echo "  │  Prefix + -      → Split pane horizontally           │"
      echo "  │  Prefix + n      → Next window                       │"
      echo "  │  Prefix + p      → Previous window                   │"
      echo "  ├─ tmux plugins ───────────────────────────────────────┤"
      echo "  │  tpm             → Plugin manager                    │"
      echo "  │  tmux-net-speed  → Network speed in status bar       │"
      echo "  │  tmux-cpu        → CPU usage in status bar           │"
      echo "  │  tmux-plugin-istat → System stats display            │"
      echo "  └──────────────────────────────────────────────────────┘"
    else
      echo "  → Skipping tmux custom config."
    fi
  fi
fi
 
# ══════════════════════════════════════════════
# Done
# ══════════════════════════════════════════════
echo ""
echo "======================================================"
echo "  ✓ All steps completed!"
echo "  Please restart your terminal (or run: exec zsh)"
echo "  to apply all changes."
echo "======================================================"
