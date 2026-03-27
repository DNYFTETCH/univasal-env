# Universal Linux Environment Setup Guide
## Cross-Platform Compatibility: Termux | macOS | Windows 11 | Linux Desktop/Server

---

## 🎯 **OBJECTIVE**
Build a production-grade, portable Linux development environment that works identically across:
- **Android** (Termux/proot-distro)
- **macOS** (native Darwin + Homebrew)
- **Windows 11** (WSL2 + native Windows Terminal)
- **Linux Desktop/Server** (Ubuntu/Debian/Arch/Fedora)

---

## 📋 **CORE REQUIREMENTS**

### 1. Package Manager Unification
Create a universal package wrapper that detects the platform and uses the appropriate package manager:

**Supported Package Managers:**
- Termux: `pkg` (apt fork)
- macOS: `brew` (Homebrew)
- Windows 11: `winget` + WSL2 `apt`
- Linux: `apt`, `yum`, `dnf`, `pacman`, `zypper`

### 2. Essential Development Tools (Universal)
```
git, curl, wget, vim/nano, tmux, zsh/bash
build-essential (gcc, g++, make, cmake)
python3, python3-pip, python3-venv
nodejs, npm
ruby, bundler
go, rust, java (openjdk)
docker/podman (where supported)
```

### 3. Shell Environment Standardization
- **Default Shell:** `zsh` with `oh-my-zsh` or `bash` with custom `.bashrc`
- **Universal Aliases:** Cross-platform command shortcuts
- **PATH Management:** Consistent binary locations
- **Environment Variables:** XDG Base Directory compliance

### 4. Directory Structure (XDG-Compliant)
```
$HOME/
├── .config/          # Configuration files
├── .local/
│   ├── bin/         # User executables
│   ├── lib/         # User libraries
│   └── share/       # User data
├── Projects/         # Development workspace
├── Scripts/          # Utility scripts
└── .dotfiles/        # Version-controlled configs
```

---

## 🚀 **PLATFORM-SPECIFIC INSTALLATION**

### **A. TERMUX (Android)**

#### Initial Setup
```bash
# Update package lists
pkg update && pkg upgrade -y

# Install essential packages
pkg install -y \
  git curl wget vim tmux \
  openssh openssl ca-certificates \
  build-essential clang make cmake \
  python python-pip \
  nodejs npm \
  ruby \
  golang rust \
  proot proot-distro \
  termux-api termux-tools

# Setup storage access
termux-setup-storage

# Install Oh-My-Zsh (optional)
pkg install -y zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
```

#### Termux-Specific Optimizations
```bash
# Enable external storage access
echo "allow-external-apps = true" >> ~/.termux/termux.properties

# Setup custom repositories
pkg install -y termux-keyring
pkg update

# Install full Linux distribution (Ubuntu/Debian) via proot
proot-distro install ubuntu
proot-distro login ubuntu
```

#### Limitations & Workarounds
- **No systemd:** Use `sv` service manager (runit)
- **No root access:** Use `proot` or `termux-sudo` (emulated)
- **No Docker:** Use `podman` or remote Docker API
- **Limited port binding:** Ports < 1024 unavailable

---

### **B. macOS (Darwin)**

#### Initial Setup
```bash
# Install Homebrew (if not present)
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Add Homebrew to PATH
echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zshrc
source ~/.zshrc

# Install essential packages
brew install \
  git curl wget vim tmux \
  openssh openssl \
  gcc cmake make \
  python@3.11 node ruby go rust \
  docker docker-compose \
  jq yq fzf ripgrep bat

# Install Oh-My-Zsh (zsh is default on macOS)
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
```

#### macOS-Specific Tools
```bash
# Install coreutils for GNU compatibility
brew install coreutils findutils gnu-sed gnu-tar

# Add GNU tools to PATH (replaces macOS BSD versions)
echo 'export PATH="/opt/homebrew/opt/coreutils/libexec/gnubin:$PATH"' >> ~/.zshrc
```

#### Xcode Command Line Tools
```bash
xcode-select --install
```

---

### **C. Windows 11 (WSL2 + Native)**

#### WSL2 Setup
```powershell
# In PowerShell (Administrator)
wsl --install -d Ubuntu-22.04
wsl --set-default-version 2
wsl --set-default Ubuntu-22.04

# Launch WSL
wsl
```

#### Inside WSL (Ubuntu/Debian)
```bash
# Update system
sudo apt update && sudo apt upgrade -y

# Install essential packages
sudo apt install -y \
  git curl wget vim tmux \
  build-essential cmake \
  python3 python3-pip python3-venv \
  nodejs npm \
  ruby ruby-dev \
  golang-go rustc cargo \
  docker.io docker-compose \
  zsh

# Install Oh-My-Zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
chsh -s $(which zsh)
```

#### Native Windows Tools (PowerShell)
```powershell
# Install winget (Windows Package Manager)
# Usually pre-installed on Windows 11

# Install development tools
winget install Git.Git
winget install Microsoft.VisualStudioCode
winget install Python.Python.3.11
winget install OpenJS.NodeJS
winget install GoLang.Go
winget install Rustlang.Rustup

# Install Windows Terminal
winget install Microsoft.WindowsTerminal
```

#### WSL Integration
```bash
# Enable WSL Docker integration
sudo usermod -aG docker $USER
sudo service docker start

# Access Windows files from WSL
cd /mnt/c/Users/YourUsername/

# Access WSL files from Windows
# \\wsl$\Ubuntu-22.04\home\username\
```

---

### **D. Linux Desktop/Server**

#### Ubuntu/Debian
```bash
sudo apt update && sudo apt upgrade -y

sudo apt install -y \
  git curl wget vim tmux \
  build-essential cmake \
  python3 python3-pip python3-venv \
  nodejs npm \
  ruby ruby-dev \
  golang-go rustc cargo \
  docker.io docker-compose \
  zsh

# Docker setup
sudo systemctl enable docker
sudo systemctl start docker
sudo usermod -aG docker $USER
```

#### Fedora/RHEL/CentOS
```bash
sudo dnf update -y

sudo dnf groupinstall -y "Development Tools"
sudo dnf install -y \
  git curl wget vim tmux \
  cmake python3 python3-pip \
  nodejs npm \
  ruby ruby-devel \
  golang rust cargo \
  docker docker-compose \
  zsh

sudo systemctl enable docker
sudo systemctl start docker
sudo usermod -aG docker $USER
```

#### Arch Linux
```bash
sudo pacman -Syu

sudo pacman -S --needed \
  base-devel git curl wget vim tmux \
  cmake python python-pip \
  nodejs npm \
  ruby go rust \
  docker docker-compose \
  zsh

sudo systemctl enable docker
sudo systemctl start docker
sudo usermod -aG docker $USER
```

---

## 🔧 **UNIVERSAL CONFIGURATION**

### 1. Create Universal Package Wrapper

```bash
#!/usr/bin/env bash
# File: ~/.local/bin/upm (Universal Package Manager)

upm() {
  local cmd="$1"
  shift
  
  case "$OSTYPE" in
    linux-android*)
      # Termux
      case "$cmd" in
        install|i) pkg install -y "$@" ;;
        remove|r) pkg uninstall -y "$@" ;;
        update|u) pkg update && pkg upgrade -y ;;
        search|s) pkg search "$@" ;;
        *) pkg "$cmd" "$@" ;;
      esac
      ;;
    darwin*)
      # macOS
      case "$cmd" in
        install|i) brew install "$@" ;;
        remove|r) brew uninstall "$@" ;;
        update|u) brew update && brew upgrade ;;
        search|s) brew search "$@" ;;
        *) brew "$cmd" "$@" ;;
      esac
      ;;
    linux-gnu*)
      # Linux (detect package manager)
      if command -v apt >/dev/null; then
        case "$cmd" in
          install|i) sudo apt install -y "$@" ;;
          remove|r) sudo apt remove -y "$@" ;;
          update|u) sudo apt update && sudo apt upgrade -y ;;
          search|s) apt search "$@" ;;
          *) sudo apt "$cmd" "$@" ;;
        esac
      elif command -v dnf >/dev/null; then
        case "$cmd" in
          install|i) sudo dnf install -y "$@" ;;
          remove|r) sudo dnf remove -y "$@" ;;
          update|u) sudo dnf update -y ;;
          search|s) dnf search "$@" ;;
          *) sudo dnf "$cmd" "$@" ;;
        esac
      elif command -v pacman >/dev/null; then
        case "$cmd" in
          install|i) sudo pacman -S --needed "$@" ;;
          remove|r) sudo pacman -R "$@" ;;
          update|u) sudo pacman -Syu ;;
          search|s) pacman -Ss "$@" ;;
          *) sudo pacman "$cmd" "$@" ;;
        esac
      fi
      ;;
  esac
}

# Make command available
upm "$@"
```

**Installation:**
```bash
mkdir -p ~/.local/bin
curl -o ~/.local/bin/upm https://your-url/upm.sh
chmod +x ~/.local/bin/upm
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc
```

**Usage:**
```bash
upm install vim git python
upm update
upm search nodejs
upm remove old-package
```

---

### 2. Unified Shell Configuration

Create `~/.shellrc` (sourced by both bash and zsh):

```bash
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

# Platform-specific overrides
if [[ "$PLATFORM" == "macos" ]]; then
  alias ls='ls -G'
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
alias dps='docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"'

# Functions
mkcd() { mkdir -p "$1" && cd "$1"; }
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

# Load platform-specific config
if [ -f "$HOME/.config/shell/$PLATFORM.sh" ]; then
  source "$HOME/.config/shell/$PLATFORM.sh"
fi
```

**Setup:**
```bash
# In ~/.bashrc
[ -f ~/.shellrc ] && source ~/.shellrc

# In ~/.zshrc
[ -f ~/.shellrc ] && source ~/.shellrc
```

---

### 3. Python Environment Management

```bash
# Create global virtualenv location
mkdir -p ~/.local/venvs

# Helper function (add to ~/.shellrc)
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

# Usage
pyenv myproject  # Creates/activates ~/.local/venvs/myproject
pip install django flask
```

---

### 4. Git Configuration (Universal)

```bash
# Global git config
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"
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
git config --global alias.last 'log -1 HEAD'
git config --global alias.visual 'log --oneline --graph --all --decorate'
```

---

### 5. SSH Key Management

```bash
# Generate SSH key (universal)
ssh-keygen -t ed25519 -C "your.email@example.com" -f ~/.ssh/id_ed25519

# Start SSH agent (add to ~/.shellrc)
if [ -z "$SSH_AUTH_SOCK" ]; then
  eval "$(ssh-agent -s)"
  ssh-add ~/.ssh/id_ed25519 2>/dev/null
fi

# Copy public key to clipboard
# Termux
cat ~/.ssh/id_ed25519.pub | termux-clipboard-set

# macOS
cat ~/.ssh/id_ed25519.pub | pbcopy

# Linux (xclip)
cat ~/.ssh/id_ed25519.pub | xclip -selection clipboard

# WSL
cat ~/.ssh/id_ed25519.pub | clip.exe
```

---

## 🧪 **TESTING & VALIDATION**

### Platform Detection Script

```bash
#!/usr/bin/env bash
# test-platform.sh

echo "=== Platform Information ==="
echo "OS Type: $OSTYPE"
echo "Platform: $PLATFORM"
echo "Shell: $SHELL"
echo "User: $USER"
echo "Home: $HOME"
echo ""

echo "=== Available Tools ==="
for tool in git curl wget vim python3 node npm ruby go docker; do
  if command -v "$tool" >/dev/null 2>&1; then
    version=$(command "$tool" --version 2>&1 | head -n1)
    echo "✓ $tool: $version"
  else
    echo "✗ $tool: NOT FOUND"
  fi
done
echo ""

echo "=== Package Manager ==="
if command -v pkg >/dev/null; then
  echo "✓ Termux (pkg)"
elif command -v brew >/dev/null; then
  echo "✓ Homebrew (macOS)"
elif command -v apt >/dev/null; then
  echo "✓ APT (Debian/Ubuntu)"
elif command -v dnf >/dev/null; then
  echo "✓ DNF (Fedora/RHEL)"
elif command -v pacman >/dev/null; then
  echo "✓ Pacman (Arch)"
fi
echo ""

echo "=== Environment ==="
echo "PATH: $PATH"
echo "EDITOR: $EDITOR"
```

---

## 📦 **PORTABLE PROJECT STRUCTURE**

### Example: Universal Build System

```
universal-builder/
├── .env.example          # Environment template
├── Makefile              # Universal build commands
├── setup.sh              # Auto-detection installer
├── config/
│   ├── termux.conf
│   ├── macos.conf
│   ├── linux.conf
│   └── windows.conf
├── scripts/
│   │── detect-platform.sh
│   ├── install-deps.sh
│   └── run-tests.sh
├── src/
│   └── your-code/
└── README.md
```

### Universal Makefile

```makefile
# Detect platform
UNAME_S := $(shell uname -s)
PLATFORM := unknown

ifeq ($(UNAME_S),Linux)
  ifeq ($(shell uname -o),Android)
    PLATFORM := termux
  else
    PLATFORM := linux
  endif
endif
ifeq ($(UNAME_S),Darwin)
  PLATFORM := macos
endif

# Platform-specific variables
ifeq ($(PLATFORM),termux)
  PYTHON := python
  SUDO :=
else
  PYTHON := python3
  SUDO := sudo
endif

.PHONY: setup build test clean

setup:
	@echo "Setting up for platform: $(PLATFORM)"
	@./scripts/install-deps.sh $(PLATFORM)

build:
	@echo "Building on $(PLATFORM)"
	$(PYTHON) -m pip install --upgrade pip
	$(PYTHON) -m pip install -r requirements.txt

test:
	@echo "Running tests on $(PLATFORM)"
	$(PYTHON) -m pytest tests/

clean:
	@echo "Cleaning build artifacts"
	rm -rf build/ dist/ *.egg-info __pycache__/
```

---

## 🎓 **BEST PRACTICES**

### 1. Use Version Managers
- **Python:** `pyenv` (all platforms)
- **Node.js:** `nvm` (all platforms)
- **Ruby:** `rbenv` or `rvm`
- **Java:** `sdkman`

### 2. Containerization
- **Portable:** Use Docker/Podman for consistent environments
- **Termux:** Use `proot-distro` for full Linux
- **Windows:** Use WSL2 for native Linux experience

### 3. Dotfiles Management
```bash
# Initialize dotfiles repo
cd ~
git init --bare $HOME/.dotfiles
echo "alias dotfiles='/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'" >> ~/.shellrc
source ~/.shellrc

# Track configs
dotfiles add ~/.bashrc ~/.zshrc ~/.vimrc ~/.gitconfig
dotfiles commit -m "Initial dotfiles"
dotfiles remote add origin git@github.com:username/dotfiles.git
dotfiles push -u origin main
```

### 4. Cross-Platform Scripts
Always use:
- Shebang: `#!/usr/bin/env bash`
- POSIX-compliant syntax when possible
- Platform detection at runtime
- Graceful fallbacks

---

## 🚨 **COMMON PITFALLS & SOLUTIONS**

### Termux-Specific
- **Problem:** `apt` doesn't work
  - **Solution:** Use `pkg` instead (Termux's package manager)
  
- **Problem:** Permission denied errors
  - **Solution:** Termux has no root; use `proot` or avoid requiring root

- **Problem:** Docker not available
  - **Solution:** Use remote Docker API or `proot-distro` containers

### macOS-Specific
- **Problem:** GNU tools missing (gnu-sed, gnu-tar)
  - **Solution:** `brew install coreutils findutils gnu-sed gnu-tar`
  
- **Problem:** Xcode license not accepted
  - **Solution:** `sudo xcodebuild -license accept`

### Windows/WSL-Specific
- **Problem:** File permission issues between Windows and WSL
  - **Solution:** Work in WSL filesystem (`~/`), not `/mnt/c/`
  
- **Problem:** Docker daemon not running
  - **Solution:** `sudo service docker start` or use Docker Desktop

### Linux-Specific
- **Problem:** Docker requires sudo
  - **Solution:** `sudo usermod -aG docker $USER` (logout/login required)

---

## ✅ **VERIFICATION CHECKLIST**

Run this on each platform:

```bash
# 1. Check shell
echo $SHELL

# 2. Check package manager
upm search git

# 3. Check development tools
git --version
python3 --version
node --version
docker --version

# 4. Check PATH
echo $PATH | tr ':' '\n'

# 5. Test universal aliases
ll
gs
py --version

# 6. Test virtualenv
pyenv test-env
pip install requests
deactivate

# 7. Test SSH
ssh -T git@github.com

# 8. Test Docker (if available)
docker run hello-world
```

---

## 🔗 **ADDITIONAL RESOURCES**

- **Termux Wiki:** https://wiki.termux.com/
- **Homebrew Docs:** https://docs.brew.sh/
- **WSL Documentation:** https://learn.microsoft.com/en-us/windows/wsl/
- **Docker Docs:** https://docs.docker.com/
- **XDG Base Directory:** https://specifications.freedesktop.org/basedir-spec/

---

## 📝 **QUICK START EXAMPLE**

```bash
# 1. Clone your universal setup repo
git clone https://github.com/yourusername/universal-linux-env.git
cd universal-linux-env

# 2. Run auto-detection installer
./setup.sh

# 3. Install all dependencies
make setup

# 4. Verify installation
make test

# 5. Start developing
cd ~/Projects
mkdir my-new-project
cd my-new-project
git init
pyenv my-new-project
pip install -r requirements.txt
code .
```

---

## 🎯 **SUCCESS CRITERIA**

Your universal Linux environment is production-ready when:

✅ Same commands work on all platforms (upm, pyenv, aliases)
✅ Development tools available everywhere (git, python, node, docker)
✅ SSH keys configured and working
✅ Dotfiles version-controlled and synced
✅ Projects portable across devices
✅ No "it works on my machine" issues
✅ Automated setup script runs successfully
✅ CI/CD pipelines compatible across platforms

---

**Last Updated:** 2025-03-27
**Maintainer:** @dnyftetch
**License:** MIT
