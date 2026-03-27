# Universal Linux Environment

**Production-grade cross-platform development environment for Termux, macOS, Windows 11 (WSL), and Linux.**

[![Platform](https://img.shields.io/badge/platform-termux%20%7C%20macos%20%7C%20linux%20%7C%20windows-blue)]()
[![License](https://img.shields.io/badge/license-MIT-green)]()

---

## 🎯 What is This?

A **complete, portable Linux development environment** that works identically across:

- **Android** (Termux)
- **macOS** (Darwin + Homebrew)
- **Windows 11** (WSL2)
- **Linux** (Ubuntu, Debian, Fedora, Arch, etc.)

**No Docker required.** Just run one command and get a fully configured development environment with:

✅ Universal package management (UPM wrapper)  
✅ Standardized shell configuration  
✅ Cross-platform development tools  
✅ Git, Python, Node.js, Ruby, Go, Rust  
✅ Unified aliases and utilities  
✅ XDG Base Directory compliance  

---

## 🚀 Quick Start

### One-Line Install

```bash
# Download and run setup
curl -sSL https://raw.githubusercontent.com/dnyftetch/universal-env/main/setup.sh | bash

# OR clone and install
git clone https://github.com/dnyftetch/universal-env.git
cd universal-env
make all
```

That's it! The script auto-detects your platform and installs everything needed.

### What Gets Installed?

**Core Development Tools:**
- Git, curl, wget, vim, tmux
- Build tools (gcc, make, cmake)
- Python 3 + pip + venv
- Node.js + npm
- Ruby + bundler
- Go, Rust
- Docker (where supported)

**Universal Utilities:**
- `upm` - Universal Package Manager
- `.shellrc` - Cross-platform shell config
- Standard aliases and functions
- XDG-compliant directory structure

---

## 📦 UPM - Universal Package Manager

UPM automatically detects your platform and uses the right package manager:

```bash
# Install packages (works on ALL platforms)
upm install vim git python3

# Update all packages
upm update

# Search for packages
upm search docker

# Remove packages
upm remove old-package

# List installed packages
upm list
```

**Supported Package Managers:**
- Termux → `pkg`
- macOS → `brew` (Homebrew)
- Debian/Ubuntu → `apt`
- Fedora/RHEL → `dnf`/`yum`
- Arch Linux → `pacman`

---

## 🛠️ Makefile Commands

```bash
make setup     # Run full environment setup
make install   # Install UPM to ~/.local/bin
make test      # Test installation
make doctor    # System health check
make update    # Update all packages
make clean     # Remove build artifacts
make help      # Show available commands
```

---

## 📂 Directory Structure

```
$HOME/
├── .config/          # XDG configuration files
├── .local/
│   ├── bin/         # User executables (UPM lives here)
│   ├── lib/         # User libraries
│   ├── share/       # User data
│   └── venvs/       # Python virtual environments
├── Projects/         # Your development workspace
├── Scripts/          # Utility scripts
├── .shellrc         # Universal shell configuration
└── .dotfiles/       # Version-controlled configs (optional)
```

---

## 🔧 Usage Examples

### Install Development Tools

```bash
# Same command works everywhere
upm install nodejs python3 ruby golang docker

# Platform-specific tools installed automatically
# Termux: pkg install ...
# macOS: brew install ...
# Linux: apt/dnf/pacman install ...
```

### Create Python Virtual Environment

```bash
# Universal pyenv function (included in .shellrc)
pyenv my-project

# Creates ~/.local/venvs/my-project
# Activates it automatically
pip install django flask requests
```

### Common Workflows

```bash
# Create new project
mkcd ~/Projects/my-app
git init
pyenv my-app
pip install -r requirements.txt

# Search for packages
upm search postgresql

# Check system health
make doctor

# Update everything
make update
```

---

## 🌍 Platform-Specific Notes

### Termux (Android)

```bash
# After installation, grant storage access
termux-setup-storage

# Install full Ubuntu environment (optional)
pkg install proot-distro
proot-distro install ubuntu
proot-distro login ubuntu

# Termux limitations:
# - No systemd (use sv/runit)
# - No root access (use proot)
# - No Docker (use podman or remote API)
# - Ports < 1024 unavailable
```

### macOS

```bash
# Homebrew installed automatically
# GNU tools added to PATH for compatibility

# macOS uses zsh by default (configured automatically)
# Xcode Command Line Tools required:
xcode-select --install
```

### Windows 11 (WSL2)

```bash
# In PowerShell (Administrator):
wsl --install -d Ubuntu-22.04
wsl

# Inside WSL, run setup:
curl -sSL https://your-url/setup.sh | bash

# Access Windows files from WSL:
cd /mnt/c/Users/YourName/

# Access WSL files from Windows:
# \\wsl$\Ubuntu-22.04\home\username\
```

### Linux Desktop/Server

```bash
# Works on Ubuntu, Debian, Fedora, Arch, etc.
# Auto-detects package manager
# Installs with sudo where needed
```

---

## ⚙️ Configuration

### Shell Configuration (~/.shellrc)

Automatically loaded by both bash and zsh:

```bash
# Platform detection (auto-set)
echo $PLATFORM  # termux, macos, linux, windows

# XDG directories (auto-configured)
echo $XDG_CONFIG_HOME  # ~/.config
echo $XDG_DATA_HOME    # ~/.local/share

# Universal aliases (pre-configured)
ll      # ls -lah
gs      # git status
py      # python3
pip     # python3 -m pip

# Custom functions
mkcd my-dir          # Create and cd into directory
pyenv my-env         # Create/activate virtual environment
extract file.tar.gz  # Smart archive extraction
```

### Git Configuration

Setup prompts for your details on first run:

```bash
git config --global user.name "Your Name"
git config --global user.email "your@email.com"

# Pre-configured aliases:
git st      # git status
git co      # git checkout
git ci      # git commit
git br      # git branch
```

### SSH Keys

Generated during setup (optional):

```bash
# Keys stored at ~/.ssh/id_ed25519
# Add public key to GitHub:
cat ~/.ssh/id_ed25519.pub
```

---

## 🧪 Testing & Verification

### Quick Test

```bash
make test
```

Expected output:
```
Platform: macos
Python: Python 3.11.5

Checking required commands:
✓ git: /usr/bin/git
✓ curl: /usr/bin/curl
✓ vim: /usr/bin/vim
✓ python3: /usr/local/bin/python3
✓ node: /usr/local/bin/node
✓ npm: /usr/local/bin/npm

✓ UPM installed at ~/.local/bin/upm
```

### System Health Check

```bash
make doctor
```

Shows comprehensive system information:
- Platform and shell
- Installed development tools
- Package manager status
- Environment variables
- PATH configuration

---

## 📚 Documentation

- **[UNIVERSAL_LINUX_SETUP.md](UNIVERSAL_LINUX_SETUP.md)** - Complete setup guide
- **[upm](upm)** - Universal Package Manager script
- **[setup.sh](setup.sh)** - Auto-detection installer
- **[Makefile](Makefile)** - Build automation

---

## 🔍 Troubleshooting

### "Command not found: upm"

```bash
# Ensure ~/.local/bin is in PATH
export PATH="$HOME/.local/bin:$PATH"

# Or reinstall
make install
```

### "Permission denied"

```bash
# Make scripts executable
chmod +x setup.sh upm

# Or use make
make install
```

### Termux-specific issues

```bash
# Update repositories
pkg update
pkg upgrade

# Fix repository errors
termux-change-repo

# Reinstall packages
pkg install build-essential
```

### macOS-specific issues

```bash
# Accept Xcode license
sudo xcodebuild -license accept

# Reinstall Homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Fix GNU tools PATH
echo 'export PATH="/opt/homebrew/opt/coreutils/libexec/gnubin:$PATH"' >> ~/.zshrc
```

---

## 🎓 Advanced Usage

### Creating Portable Projects

```makefile
# Example Makefile using UPM
.PHONY: setup test

setup:
	upm install python3 nodejs
	python3 -m venv .venv
	.venv/bin/pip install -r requirements.txt

test:
	.venv/bin/pytest tests/
```

### Dotfiles Management

```bash
# Initialize dotfiles repo
git init --bare $HOME/.dotfiles

# Add alias to ~/.shellrc
alias dotfiles='/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'

# Track configs
dotfiles add ~/.shellrc ~/.vimrc ~/.gitconfig
dotfiles commit -m "Initial dotfiles"
dotfiles remote add origin git@github.com:username/dotfiles.git
dotfiles push
```

### Remote Development

```bash
# SSH into any machine
ssh user@remote-host

# Run setup
curl -sSL https://your-url/setup.sh | bash

# Identical environment ready in minutes
```

---

## 📊 Performance

**Setup time:**
- Termux: ~5-10 minutes
- macOS: ~3-5 minutes
- Linux: ~2-4 minutes
- WSL2: ~3-5 minutes

**Disk usage:**
- Core install: ~500MB
- With full dev tools: ~2-3GB

**Internet required:**
- Initial setup only
- Offline usage after installation

---

## 🤝 Contributing

Contributions welcome! Please:

1. Fork the repository
2. Create a feature branch
3. Test on multiple platforms
4. Submit a pull request

### Testing Checklist

- [ ] Termux (Android)
- [ ] macOS (Intel + Apple Silicon)
- [ ] Ubuntu/Debian
- [ ] Fedora/RHEL
- [ ] Arch Linux
- [ ] Windows 11 WSL2

---

## 📄 License

MIT License - see [LICENSE](LICENSE) for details.

---

## 👤 Author

**@dnyftetch**
- GitHub: [@dnyftetch](https://github.com/dnyftetch)
- Organization: [DNYFTECH](https://github.com/DNYFTECH)

---

## 🌟 Features Roadmap

- [ ] Auto-update mechanism
- [ ] Cloud sync for dotfiles
- [ ] Plugin system
- [ ] GUI installer
- [ ] Mobile app integration
- [ ] CI/CD templates
- [ ] Pre-configured IDE settings

---

## 📞 Support

- **Issues:** https://github.com/dnyftetch/universal-env/issues
- **Discussions:** https://github.com/dnyftetch/universal-env/discussions
- **Documentation:** [UNIVERSAL_LINUX_SETUP.md](UNIVERSAL_LINUX_SETUP.md)

---

**Made with ❤️ for developers who work across multiple platforms.**
