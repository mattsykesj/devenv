#!/bin/bash

# Fail on errors
set -e

# Update system packages
echo "Updating system..."
sudo apt update && sudo apt upgrade -y

# Install dependencies
echo "Installing core dependencies..."
sudo apt install -y \
  zsh curl git wget build-essential \
  ninja-build gettext cmake unzip \
  autoconf automake pkg-config libtool \
  tmux fzf ripgrep fd-find bat

# Install Zsh & Oh My Zsh
echo "Installing Zsh and Oh My Zsh..."
if [ ! -d "$HOME/.oh-my-zsh" ]; then
  sudo chsh -s $(which zsh) $USER
  curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh | bash
fi

# Install Dracula Theme for Oh My Zsh
echo "Installing Dracula theme for Oh My Zsh..."
if [ ! -d "$HOME/.oh-my-zsh/custom/themes/dracula" ]; then
  git clone https://github.com/dracula/zsh.git "$HOME/.oh-my-zsh/custom/themes/dracula"
  ln -sf "$HOME/.oh-my-zsh/custom/themes/dracula/dracula.zsh-theme" "$HOME/.oh-my-zsh/custom/themes/dracula.zsh-theme"
fi

# Set Dracula theme in .zshrc
echo "Setting Zsh theme to Dracula..."
sed -i 's/ZSH_THEME=".*"/ZSH_THEME="dracula"/g' "$HOME/.zshrc"

# Create ~/.local/bin directory if it doesn't exist
mkdir -p ~/.local/bin

# Create symlinks for fd and bat
echo "Creating symlinks for fd and bat..."
ln -sf $(which fdfind) ~/.local/bin/fd
ln -sf $(which batcat) ~/.local/bin/bat

# Ensure ~/.local/bin is in PATH
if ! echo $PATH | grep -q "$HOME/.local/bin"; then
  echo 'export PATH=$HOME/.local/bin:$PATH' >> ~/.zshrc
  export PATH=$HOME/.local/bin:$PATH
fi

# Install Neovim from source
echo "Cloning and building Neovim..."
if [ ! -d "$HOME/neovim" ]; then
  git clone --depth 1 --branch stable https://github.com/neovim/neovim.git $HOME/neovim
  cd $HOME/neovim
  make CMAKE_BUILD_TYPE=Release
  sudo make install
fi

# Clone and set up your Neovim config
echo "Setting up Neovim configuration..."
NVIM_CONFIG_DIR="$HOME/.config/nvim"
if [ ! -d "$NVIM_CONFIG_DIR" ]; then
  git clone https://github.com/mattsykesj/kickstart.nvim.git $NVIM_CONFIG_DIR
  nvim --headless "+Lazy sync" +qa  # Install Neovim dependencies (Lazy.nvim)
fi

# Install Tmux and basic config
echo "Configuring Tmux..."
cat <<EOF > $HOME/.tmux.conf
set -g mouse on
setw -g mode-keys vi
set -g history-limit 10000
bind -n C-a send-prefix
EOF

# Reload shell
echo "Setup complete! Restarting shell..."
exec zsh
