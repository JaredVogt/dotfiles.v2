# dotfiles.v2

A comprehensive macOS dotfiles configuration system that automates the setup and management of development tools, shell configurations, applications, and system preferences across multiple machines.

## Table of Contents

- [Overview](#overview)
- [Quick Start](#quick-start)
- [Detailed Setup Guide](#detailed-setup-guide)
- [Configuration Management](#configuration-management)
- [Automation Scripts](#automation-scripts)
- [Supported Applications](#supported-applications)
- [Package Management](#package-management)
- [Cloud Storage Integration](#cloud-storage-integration)
- [Troubleshooting](#troubleshooting)
- [Maintenance](#maintenance)
- [Contributing](#contributing)

## Overview

This dotfiles repository provides a complete development environment setup for macOS, featuring:

- **Automated SSH key generation and GitHub authentication**
- **Comprehensive shell configurations** (zsh, fish, nushell)
- **Modern terminal emulators** (WezTerm, Kitty, Ghostty)
- **Development tools** (Git, Helix editor, tmux)
- **System automation** (Karabiner, Hammerspoon)
- **CLI productivity tools** (Atuin, Starship, Yazi)
- **Homebrew package management** with backup/restore capabilities
- **Cloud storage integration** (Dropbox, Google Drive)
- **Browser extensions** (Vimium)
- **Note-taking setup** (Inkdrop)

The system is designed for easy migration between machines, with intelligent symlink management and comprehensive backup capabilities.

## Quick Start

### Prerequisites
- macOS (tested on Ventura/Sonoma/Sequoia)
- Internet connection for downloading packages
- Admin privileges for installing applications

### New Machine Setup (5 minutes)

```bash
# 1. Setup GitHub SSH access
curl -O https://raw.githubusercontent.com/[your-username]/dotfiles.v2/main/sshSetup.sh
chmod +x sshSetup.sh
./sshSetup.sh

# 2. Clone the repository
git clone git@github.com:[your-username]/dotfiles.v2.git ~/projects/dotfiles.v2
cd ~/projects/dotfiles.v2

# 3. Create all configuration symlinks
./linkShellConfigFiles.sh

# 4. Install Homebrew packages (optional but recommended)
./brewSetup.sh --install

# 5. Link cloud storage (after installing Dropbox/Google Drive)
./linkCloudStorageProviders.sh

# 6. Capture current system state for future reference
./syncCurrentState.sh
```

## Detailed Setup Guide

### Step 1: SSH Key Setup

The `sshSetup.sh` script automates GitHub SSH authentication:

```bash
./sshSetup.sh
```

**What this does:**
- Checks for existing SSH keys and GitHub authentication
- Creates a new ED25519 SSH key with enhanced security
- Configures `~/.ssh/config` for GitHub
- Adds the key to SSH agent with macOS keychain integration
- Copies the public key to clipboard for adding to GitHub

**Options:**
- `--help` - Show detailed help
- `--force` - Force new key creation even if working authentication exists
- `--version` - Show script version

### Step 2: Repository Setup

Clone the repository to the expected location:

```bash
# Create projects directory if it doesn't exist
mkdir -p ~/projects

# Clone the repository
git clone git@github.com:[your-username]/dotfiles.v2.git ~/projects/dotfiles.v2
cd ~/projects/dotfiles.v2
```

### Step 3: Configuration Linking

The `linkShellConfigFiles.sh` script creates symlinks for all configurations:

```bash
./linkShellConfigFiles.sh
```

**What this does:**
- Links home directory files: `.zprofile`, `.zshenv`, `.zshrc`, `.gitconfig`, `.tmux.conf`
- Creates `~/.config` directories for each application
- Symlinks all configuration files to their proper locations
- Preserves existing files by creating backups

**Options:**
- `--check` - Check current symlink status without making changes
- `--dry-run` - Show what would be done without making changes
- `--verbose` - Show detailed output

**Example output:**
```
✓ Linked: ~/.zshrc → ~/projects/dotfiles.v2/zsh/.zshrc
⚠ Incorrect link: ~/.gitconfig → /old/path (should be → ~/projects/dotfiles.v2/git/.gitconfig)
✗ Exists but not a link: ~/.tmux.conf
```

### Step 4: Package Management

The `brewSetup.sh` script provides comprehensive Homebrew management:

#### First Time Setup
```bash
# Install packages from backup file
./brewSetup.sh --install
```

#### Creating Backups
```bash
# Generate JSON backup of current packages
./brewSetup.sh --backup
```

#### Package Analysis
```bash
# Show detailed analysis of installed packages
./brewSetup.sh --verbose

# Quick list of packages
./brewSetup.sh --ls
```

#### Package Maintenance
```bash
# Check for outdated packages
./brewSetup.sh --check-outdated

# Update all packages
./brewSetup.sh --update
```

### Step 5: Cloud Storage Integration

Link cloud storage directories for easy access:

```bash
./linkCloudStorageProviders.sh
```

**Prerequisites:**
- Dropbox installed and synced
- Google Drive installed and synced

**Creates symlinks:**
- `~/Dropbox` → `~/Library/CloudStorage/Dropbox`
- `~/gd_wolff` → `~/Library/CloudStorage/GoogleDrive-Jared@wolffaudio.com`
- `~/gd_jrv` → `~/Library/CloudStorage/GoogleDrive-jared.vogt@gmail.com`

## Configuration Management

### Shells

#### Zsh Configuration
- **Location**: `zsh/`
- **Files**: `.zprofile`, `.zshenv`, `.zshrc`
- **Features**: 
  - Custom aliases and functions
  - PATH management
  - Integration with modern CLI tools
  - Optimized startup performance

#### Fish Shell Configuration
- **Location**: `fish/`
- **Files**: `config.fish`, `aliases.fish`, `aliases_git.fish`, custom functions
- **Features**:
  - Interactive shell configuration
  - Git aliases and shortcuts
  - Custom functions for productivity
  - Fisher plugin management

#### Nushell Configuration
- **Location**: `nushell/`
- **Files**: `config.nu`, `env.nu`
- **Features**:
  - Modern shell with structured data
  - Custom commands and aliases
  - Environment configuration

### Terminal Emulators

#### WezTerm
- **Location**: `wezterm/`
- **File**: `wezterm.lua`
- **Features**:
  - GPU-accelerated terminal
  - Custom key bindings
  - Font and color scheme configuration
  - Tab and pane management

#### Kitty
- **Location**: `kitty/`
- **File**: `kitty.conf`
- **Features**:
  - Fast terminal emulator
  - Custom themes
  - Performance optimizations

#### Ghostty
- **Location**: `ghostty/`
- **File**: `config`
- **Features**:
  - Native macOS terminal
  - Minimal configuration
  - System integration

### Development Tools

#### Git Configuration
- **Location**: `git/`
- **File**: `.gitconfig`
- **Features**:
  - User identity configuration
  - Custom aliases for common operations
  - Merge and diff tool setup
  - Performance optimizations

#### Helix Editor
- **Location**: `helix/`
- **Features**:
  - Modern modal editor
  - Language server integration
  - Custom key bindings
  - Theme configuration

#### Tmux
- **Location**: `tmux/`
- **File**: `.tmux.conf`
- **Features**:
  - Terminal multiplexer configuration
  - Custom key bindings
  - Status bar customization
  - Session management

### System Tools

#### Karabiner Elements
- **Location**: `karabiner/`
- **File**: `karabiner.json`
- **Features**:
  - Keyboard customization
  - Key remapping
  - Complex modifications
  - Application-specific bindings

#### Hammerspoon
- **Location**: `hammerspoon/`
- **Files**: `init.lua`, `myLeaders.toml`
- **Features**:
  - macOS automation
  - Window management
  - Custom hotkeys
  - System integration

### CLI Productivity Tools

#### Atuin
- **Location**: `atuin/`
- **File**: `config.toml`
- **Features**:
  - Enhanced shell history
  - Sync across machines
  - Fuzzy search
  - Statistics and insights

#### Starship
- **Location**: `starship/`
- **File**: `starship.toml`
- **Features**:
  - Cross-shell prompt
  - Git integration
  - Custom modules
  - Performance optimization

#### Yazi
- **Location**: `yazi/`
- **File**: `yazi.toml`
- **Features**:
  - Terminal file manager
  - Vi-like navigation
  - Preview capabilities
  - Custom commands

### Browser Extensions

#### Vimium
- **Location**: `vimium/`
- **File**: `vimium-options.json`
- **Features**:
  - Vim-like browser navigation
  - Custom key mappings
  - Search engine shortcuts
  - Link hints configuration

### Productivity Tools

#### PopClip Extensions
- **Location**: `popclip/`
- **Files**: Various `.popcliptxt` files
- **Features**:
  - Text selection actions
  - Custom workflows
  - Application integrations
  - Deep linking

#### Claude AI
- **Location**: `claude/`
- **File**: `claude_desktop_config.json`
- **Features**:
  - AI assistant configuration
  - Custom settings
  - Integration preferences

## Automation Scripts

### brewSetup.sh - Package Management

A comprehensive Homebrew management tool with the following capabilities:

#### Features
- **Package Analysis**: Detailed breakdown of installed formulae and casks
- **Backup/Restore**: JSON-based package backup for system migration
- **Dependency Mapping**: Shows relationships between packages
- **Update Management**: Check for and install package updates
- **Dry-run Mode**: Preview operations without making changes
- **Logging**: All operations logged to `logs-backups/` directory

#### Usage Patterns

**System Migration Workflow:**
```bash
# On old machine
./brewSetup.sh --backup

# Copy homebrew-packages.json to new machine
# On new machine
./brewSetup.sh --install
```

**Regular Maintenance:**
```bash
# Check what's installed and what needs updates
./brewSetup.sh --verbose

# Update everything
./brewSetup.sh --update
```

### linkShellConfigFiles.sh - Configuration Management

Intelligent symlink management with robust error handling:

#### Features
- **Status Checking**: Reports current state of all symlinks
- **Backup Creation**: Automatic backup of existing files
- **Dry-run Mode**: Preview changes without applying them
- **Verbose Output**: Detailed reporting of all operations
- **Error Handling**: Graceful handling of permission issues and conflicts

#### Safety Features
- Never overwrites files without backing them up
- Validates source files exist before creating links
- Provides clear status reporting for troubleshooting

### sshSetup.sh - GitHub Authentication

Automated SSH key setup with security best practices:

#### Features
- **Key Generation**: Creates ED25519 keys with enhanced security options
- **Configuration Management**: Updates `~/.ssh/config` automatically
- **Agent Integration**: Adds keys to SSH agent with keychain support
- **Conflict Detection**: Checks for existing keys and configurations
- **Help System**: Comprehensive documentation and guidance

#### Security Features
- Uses modern ED25519 cryptography
- Integrates with macOS keychain
- Provides clear instructions for GitHub setup
- Validates existing authentication before creating new keys

### Additional Utilities

#### syncCurrentState.sh
Comprehensive application discovery and backup tool:
- **Smart Filtering**: Excludes Homebrew-managed applications to focus on manual installs
- **Source Detection**: Identifies Mac App Store, direct downloads, PKG installers, and system apps
- **JSON Backup**: Creates timestamped backups for system migration planning
- **Easy Reading**: `--jls` option to quickly view what needs manual installation
- **Migration Planning**: Provides actionable lists for setting up new machines

#### inkdropSetup.sh
Installs Inkdrop note-taking app plugins:
- Comprehensive plugin suite for enhanced functionality
- Syntax highlighting, math support, diagrams
- Export capabilities and vim integration

#### linkCloudStorageProviders.sh
Creates convenient symlinks to cloud storage:
- Standardizes access to Dropbox and Google Drive
- Simplifies file management across cloud providers

## Package Management

### Homebrew Integration

The repository includes sophisticated Homebrew management through `brewSetup.sh`:

#### Package Categories Managed
- **Development Tools**: Git, language runtimes, build tools
- **CLI Utilities**: Modern replacements for standard Unix tools
- **Applications**: Development environments, productivity apps
- **System Tools**: Monitoring, network utilities, file management

#### Backup Format
The JSON backup includes:
- Package names and versions
- Installation dates
- Dependency information
- Restore instructions

Example backup structure:
```json
{
  "formulae": [
    {
      "name": "git",
      "version": "2.42.0",
      "installed_on": "Oct 15 2023",
      "dependencies": ["gettext", "pcre2"]
    }
  ],
  "casks": [
    {
      "name": "wezterm",
      "version": "20231015-185738",
      "installed_on": "Oct 15 2023"
    }
  ]
}
```

### Migration Benefits
- **Consistency**: Identical package setup across machines
- **Documentation**: Clear record of what's installed and why
- **Efficiency**: Automated installation saves hours of manual setup
- **Rollback**: Easy to revert to previous package states

## Application Discovery and Migration

### Capturing Current System State

The `syncCurrentState.sh` script provides comprehensive application discovery for migration planning:

```bash
# Generate application report and backup
./syncCurrentState.sh

# View applications from latest backup
./syncCurrentState.sh --jls

# View specific backup file
./syncCurrentState.sh --jls=logs-backups/installed-applications-20240127_143022.json
```

#### What It Discovers

**Application Sources Detected:**
- **[MAS]** Mac App Store applications (with App Store receipts)
- **[DL]** Direct downloads (Adobe, Microsoft, Google, etc.)
- **[PKG]** PKG installer applications
- **[SYS]** System/Apple applications
- **[???]** Unknown installation source

**Smart Filtering:**
- Automatically excludes Homebrew-managed applications
- Focuses only on manually installed software
- Shows Homebrew apps separately for reference

#### Example Output

```bash
📱 Mac App Store Applications:
  • Keynote.app
  • Pages.app

💻 Standalone Applications (Non-Homebrew):
  [MAS] Numbers.app (v13.2)
  [DL]  Adobe Photoshop 2024.app (v25.0)
  [PKG] Microsoft Office.app (v16.77)

🍺 Homebrew-Managed Applications (for reference):
  • wezterm
  • visual-studio-code
  • neovide

📊 Summary:
  Total Applications: 45
  Homebrew Managed: 15
  Mac App Store: 8
  Other Standalone: 22
```

#### Migration Workflow

1. **On Old Machine:**
   ```bash
   ./syncCurrentState.sh
   cp logs-backups/installed-applications-*.json ~/Dropbox/backups/
   ```

2. **On New Machine:**
   ```bash
   ./syncCurrentState.sh --jls=~/Dropbox/backups/installed-applications-*.json
   ```

3. **Follow the guidance:**
   - Mac App Store apps: Install via App Store or `mas` CLI
   - Direct downloads: Visit vendor websites
   - PKG installers: Re-run installer packages

This ensures you capture and can recreate your entire application environment beyond what Homebrew manages.

## Cloud Storage Integration

### Supported Providers
- **Dropbox**: Full sync and selective sync support
- **Google Drive**: Multiple account support
- **iCloud**: Native macOS integration

### Symlink Strategy
Instead of cluttering the home directory with cloud provider folders, the system creates convenient symlinks:

```
~/Dropbox → ~/Library/CloudStorage/Dropbox
~/gd_wolff → ~/Library/CloudStorage/GoogleDrive-Jared@wolffaudio.com
~/gd_jrv → ~/Library/CloudStorage/GoogleDrive-jared.vogt@gmail.com
```

### Benefits
- **Clean Home Directory**: No cloud provider clutter
- **Consistent Access**: Same paths across machines
- **Multiple Accounts**: Support for multiple Google Drive accounts
- **Easy Scripts**: Simplified backup and sync scripts

## Troubleshooting

### Common Issues and Solutions

#### SSH Key Problems
```bash
# Test GitHub connection
ssh -T git@github.com

# Re-add key to agent
ssh-add --apple-use-keychain ~/.ssh/github_jared.vogt

# Check SSH agent
ssh-add -l
```

#### Symlink Issues
```bash
# Check current symlink status
./linkShellConfigFiles.sh --check

# Fix broken symlinks
./linkShellConfigFiles.sh --verbose
```

#### Homebrew Problems
```bash
# Verify Homebrew installation
brew doctor

# Update Homebrew itself
brew update

# Check package status
./brewSetup.sh --verbose
```

#### Permission Issues
```bash
# Fix SSH directory permissions
chmod 700 ~/.ssh
chmod 600 ~/.ssh/*

# Fix config directory permissions
chmod 755 ~/.config
```

### Backup Recovery

#### Restoring from Backups
The linking script automatically creates backups with timestamps:
```bash
# Backups are stored with format: YYYYMMDD_HHMMSS_backup_filename
ls -la ~/.*backup*

# Restore a backup
cp ~/20231015_120000_backup_.zshrc ~/.zshrc
```

#### Package Recovery
```bash
# Restore packages from backup
./brewSetup.sh --install

# Check what would be installed without doing it
./brewSetup.sh --dry-run
```

### Debugging Scripts

#### Verbose Modes
All scripts support verbose output for debugging:
```bash
./linkShellConfigFiles.sh --verbose
./brewSetup.sh --verbose
```

#### Dry-run Modes
Test operations without making changes:
```bash
./linkShellConfigFiles.sh --dry-run
./brewSetup.sh --dry-run
```

#### Log Files
Operations are logged to `logs-backups/` directory:
```bash
# View recent logs
ls -la logs-backups/
tail -f logs-backups/homebrew_install_*.log
```

## Maintenance

### Regular Tasks

#### Weekly Maintenance
```bash
# Update packages
./brewSetup.sh --update

# Check system status
./linkShellConfigFiles.sh --check
```

#### Monthly Maintenance
```bash
# Create package backup
./brewSetup.sh --backup

# Clean up old logs
find logs-backups/ -name "*.log" -mtime +30 -delete
```

#### Before System Migration
```bash
# Create comprehensive backup
./brewSetup.sh --backup
cp homebrew-packages.json ~/Dropbox/backups/
```

### Adding New Applications

To add a new application to the dotfiles:

1. **Create configuration directory:**
   ```bash
   mkdir newapp/
   ```

2. **Add configuration files:**
   ```bash
   cp ~/.config/newapp/config.conf newapp/
   ```

3. **Update linking script:**
   Add `newapp` to the `programs` array in `linkShellConfigFiles.sh`

4. **Test the setup:**
   ```bash
   ./linkShellConfigFiles.sh --dry-run
   ```

### Updating Configurations

#### Shell Configurations
- Edit files in `zsh/`, `fish/`, or `nushell/` directories
- Changes are immediately available (symlinked)
- Test in new shell session

#### Application Configurations
- Edit files in respective application directories
- Some applications require restart to pick up changes
- Use `--check` mode to verify symlinks are correct

## Contributing

### Guidelines
- Test all changes on a fresh macOS installation
- Update documentation for new features
- Follow existing naming conventions
- Include error handling in scripts

### Script Development
- Use `set -euo pipefail` for robust error handling
- Provide `--help` options for all scripts
- Include version information
- Add comprehensive logging

### Configuration Management
- Keep sensitive information out of tracked files
- Use template files for machine-specific configurations
- Document any manual setup steps required

---

**Note**: This dotfiles system is designed for macOS and may require modifications for other operating systems. Always review scripts before running them on your system.