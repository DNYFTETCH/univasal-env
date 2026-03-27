#!/usr/bin/env bash
#
# Universal Linux Environment Setup Script
# Auto-detects platform and installs required dependencies
#
# Usage: curl -sSL https://your-url/setup.sh | bash
#   or:  ./setup.sh
#

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Logging
log() { echo -e "${GREEN}[✓]${NC} $*"; }
warn() { echo -e "${YELLOW}[!]${NC} $*"; }
error() { echo -e "${RED}[✗]${NC} $*" >&2; }
info() { echo -e "${BLUE}[i]${NC} $*"; }

# Detect platform
detect_platform() {
  case "$OSTYPE" in
    linux-android*) echo "termux" ;;
    darwin*) echo "macos" ;;
    linux-gnu*)
      if [ -f /etc/os-release ]; then
        . /etc/os-release
        echo "${ID:-linux}"
      else
        echo "linux"
      fi
      ;;
    msys*|cygwin*) echo "windows" ;;
    *) echo "unknown" ;;
  esac
}

# Check if command exists
has_command() {
  command -v "$1" >/dev/null 2>&1
}

# Install package manager if missing
install_pkg_manager() {
  local platform="$1"
  
  case "$platform" in
    macos)
      if ! has_command brew; then
        info "Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        
        # Add to PATH
        if [ -f /opt/homebrew/bin/brew ]; then
          eval "$(/opt/homebrew/bin/brew shellenv)"
          echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
        fi
        log "Homebrew installed"
      fi
      ;;
    termux)
      # Termux comes with pkg
      if ! has_command pkg; then
        error "Termux pkg not found. Are you running this in Termux?"
        exit 1
      fi
      ;;
  esac
}

# Install essential development tools
install_essentials() {
  local platform="$1"
  
  info "Installing essential development tools for $platform..."
  
  local packages=(
    git
    curl
    wget
    vim
    tmux
  )
  
  # Platform-specific package lists
  case "$platform" in
    termux)
      pkg update -y
      pkg install -y "${packages[@]}" \
        openssh openssl ca-certificates \
        build-essential clang make cmake \
        python python-pip \
        nodejs npm \
        ruby \
        golang rust
      ;;
    
    macos)
      brew install "${packages[@]}" \
        openssh openssl \
        gcc cmake make \
        python@3.11 node ruby go rust \
        coreutils findutils gnu-sed gnu-tar
      ;;
    
    ubuntu|debian)
      sudo apt update
      sudo apt install -y "${packages[@]}" \
        build-essential cmake \
        python3 python3-pip python3-venv \
        nodejs npm \
        ruby ruby-dev \
        golang-go rustc cargo
      ;;
    
    fedora|rhel|centos)
      sudo dnf install -y "${packages[@]}" \
        gcc gcc-c++ make cmake \
        python3 python3-pip \
        nodejs npm \
        ruby ruby-devel \
        golang rust cargo
      ;;
    
    arch|manjaro)
      sudo pacman -Sy --needed --noconfirm "${packages[@]}" \
        base-devel cmake \
        python python-pip \
        nodejs npm \
        ruby go rust
      ;;
    
    *)
      warn "Unknown platform: $platform. Skipping package installation."
      return
      ;;
  esac
  
  log "Essential tools installed"
}

# Setup directory structure
setup_directories() {
  info "Setting up directory structure..."
  
  mkdir -p ~/.config
  mkdir -p ~/.local/bin
  mkdir -p ~/.local/lib
  mkdir -p ~/.local/share
  mkdir -p ~/.local/venvs
  mkdir -p ~/Projects
  mkdir -p ~/Scripts
  
  log "Directories created"
}

# Install UPM (Universal Package Manager)
install_upm() {
  info "Installing UPM (Universal Package Manager)..."
  
  local upm_path="$HOME/.local/bin/upm"
  
  if [ -f ./upm ]; then
    cp ./upm "$upm_path"
  else
    warn "upm script not found in current directory, downloading..."
    # In production, replace with actual URL
    # curl -sSL https://raw.githubusercontent.com/your-repo/upm -o "$upm_path"
    warn "Please ensure upm script is in current directory or available online"
    return
  fi
  
  chmod +x "$upm_path"
  log "UPM installed to $upm_path"
}

# Setup shell configuration
setup_shell() {
  info "Setting up shell configuration..."
  
  local shellrc="$HOME/.shellrc"
  
  cat > "$shellrc" << 'SHELLRC'
# ~/.shellrc - Universal shell configuration

# Platform detection
export PLATFORM="unknown"
case "$OSTYPE" in
  linux-android*) export PLATFORM="termux" ;;
  darwin*) export PLATFORM="macos" ;;
  linux-gnu*) export PLATFORM="linux" ;;
  msys*|cygwin*) export PLATFORM="windows" ;;
esac

# XDG Base Directory
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_CACHE_HOME="$HOME/.cache"

# PATH configuration
export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/Scripts:$PATH"

# Editor preferences
export EDITOR="vim"
export VISUAL="vim"

# Universal aliases
alias ll='ls -lah'
alias la='ls -A'
alias l='ls -CF'
alias grep='grep --color=auto'
alias ..='cd ..'
alias ...='cd ../..'

# Git aliases
alias gs='git status'
alias ga='git add'
alias gc='git commit -m'
alias gp='git push'
alias gl='git log --oneline --graph --all'

# Platform-specific
if [[ "$PLATFORM" == "macos" ]]; then
  alias ls='ls -G'
  export PATH="/opt/homebrew/opt/coreutils/libexec/gnubin:$PATH"
elif [[ "$PLATFORM" == "termux" ]]; then
  alias open='termux-open'
fi

# Development shortcuts
alias py='python3'
alias pip='python3 -m pip'
alias venv='python3 -m venv'

# Docker shortcuts
alias d='docker'
alias dc='docker-compose'

# Functions
mkcd() { mkdir -p "$1" && cd "$1"; }

pyenv() {
  local env_name="${1:-default}"
  local venv_path="$HOME/.local/venvs/$env_name"
  
  if [ ! -d "$venv_path" ]; then
    echo "Creating virtualenv: $env_name"
    python3 -m venv "$venv_path"
  fi
  
  source "$venv_path/bin/activate"
  echo "Activated: $env_name"
}

extract() {
  if [ -f "$1" ]; then
    case "$1" in
      *.tar.bz2) tar xjf "$1" ;;
      *.tar.gz) tar xzf "$1" ;;
      *.bz2) bunzip2 "$1" ;;
      *.gz) gunzip "$1" ;;
      *.tar) tar xf "$1" ;;
      *.zip) unzip "$1" ;;
      *.Z) uncompress "$1" ;;
      *) echo "'$1' cannot be extracted" ;;
    esac
  fi
}
SHELLRC
  
  # Add sourcing to shell configs
  for rc in ~/.bashrc ~/.zshrc; do
    if [ -f "$rc" ]; then
      if ! grep -q "source ~/.shellrc" "$rc"; then
        echo "" >> "$rc"
        echo "# Universal shell configuration" >> "$rc"
        echo "[ -f ~/.shellrc ] && source ~/.shellrc" >> "$rc"
      fi
    fi
  done
  
  log "Shell configuration installed"
}

# Configure Git
setup_git() {
  info "Configuring Git..."
  
  # Only set if not already configured
  if [ -z "$(git config --global user.name)" ]; then
    read -p "Enter your name for Git: " git_name
    git config --global user.name "$git_name"
  fi
  
  if [ -z "$(git config --global user.email)" ]; then
    read -p "Enter your email for Git: " git_email
    git config --global user.email "$git_email"
  fi
  
  git config --global init.defaultBranch main
  git config --global core.editor vim
  git config --global pull.rebase false
  git config --global color.ui auto
  
  # Useful aliases
  git config --global alias.co checkout
  git config --global alias.br branch
  git config --global alias.ci commit
  git config --global alias.st status
  git config --global alias.unstage 'reset HEAD --'
  
  log "Git configured"
}

# Generate SSH key
setup_ssh() {
  info "Setting up SSH..."
  
  if [ ! -f ~/.ssh/id_ed25519 ]; then
    read -p "Generate SSH key? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
      read -p "Enter email for SSH key: " ssh_email
      ssh-keygen -t ed25519 -C "$ssh_email" -f ~/.ssh/id_ed25519 -N ""
      log "SSH key generated at ~/.ssh/id_ed25519"
      info "Add this public key to GitHub/GitLab:"
      cat ~/.ssh/id_ed25519.pub
    fi
  else
    log "SSH key already exists"
  fi
}

# Test installation
test_installation() {
  info "Testing installation..."
  
  local failed=0
  
  for cmd in git curl wget vim python3 node npm; do
    if has_command "$cmd"; then
      log "$cmd: $(command -v $cmd)"
    else
      warn "$cmd: NOT FOUND"
      failed=1
    fi
  done
  
  if [ $failed -eq 0 ]; then
    log "All tools installed successfully!"
  else
    warn "Some tools are missing. Check installation."
  fi
}

# Main setup flow
main() {
  echo ""
  echo "╔═══════════════════════════════════════════════════╗"
  echo "║   Universal Linux Environment Setup               ║"
  echo "║   Cross-platform development environment          ║"
  echo "╚═══════════════════════════════════════════════════╝"
  echo ""
  
  local platform
  platform=$(detect_platform)
  
  info "Detected platform: $platform"
  echo ""
  
  # Installation steps
  install_pkg_manager "$platform"
  install_essentials "$platform"
  setup_directories
  install_upm
  setup_shell
  setup_git
  setup_ssh
  test_installation
  
  echo ""
  log "Setup complete! 🎉"
  echo ""
  info "Next steps:"
  echo "  1. Restart your shell or run: source ~/.shellrc"
  echo "  2. Test UPM: upm search git"
  echo "  3. Create a project: mkcd ~/Projects/my-project"
  echo "  4. Create Python env: pyenv my-env"
  echo ""
}

# Run setup
main "$@"
