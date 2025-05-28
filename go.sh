#!/usr/bin/env bash

# ==============================================================================
# Dotfiles Setup Orchestrator - go.sh
# ==============================================================================
# 
# This script automates the complete setup of your development environment by
# running all configuration scripts in the correct order.
#
# WHAT THIS SCRIPT DOES:
# 1. Sets up Homebrew and installs packages (brewSetup.sh)
# 2. Creates symbolic links for all dotfiles (linkFilesv3.sh)
# 3. Configures SSH keys and settings (sshSetup.sh)  
# 4. Creates convenient cloud storage shortcuts (linkCloudStorageProviders.sh)
#
# PREREQUISITES:
# - macOS system
# - Internet connection for Homebrew installations
# - This script should be run from the dotfiles.v2 directory
#
# USAGE:
#   ./go.sh [--dry-run] [--skip-brew] [--skip-ssh] [--skip-cloud]
#
# OPTIONS:
#   --dry-run     Show what would be done without making changes
#   --skip-brew   Skip Homebrew setup (useful if already installed)
#   --skip-ssh    Skip SSH setup
#   --skip-cloud  Skip cloud storage linking
#   --help        Show this help message
#
# ==============================================================================

VERSION="1.0.0"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Configuration
DRY_RUN=false
SKIP_BREW=false
SKIP_SSH=false
SKIP_CLOUD=false
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Function to print colored output
print_step() {
    echo -e "\n${CYAN}===${NC} ${BLUE}$1${NC} ${CYAN}===${NC}"
}

print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

print_info() {
    echo -e "${PURPLE}ℹ${NC} $1"
}

show_help() {
    cat << EOF
${CYAN}Dotfiles Setup Orchestrator v${VERSION}${NC}

This script automates the complete setup of your development environment.

${YELLOW}USAGE:${NC}
    $0 [OPTIONS]

${YELLOW}OPTIONS:${NC}
    --dry-run     Show what would be done without making changes
    --skip-brew   Skip Homebrew setup (useful if already installed)
    --skip-ssh    Skip SSH setup
    --skip-cloud  Skip cloud storage linking
    --help        Show this help message

${YELLOW}SETUP PROCESS:${NC}
    ${GREEN}1.${NC} Homebrew Setup - Installs Homebrew and essential packages
    ${GREEN}2.${NC} Dotfiles Linking - Creates symlinks for all configuration files
    ${GREEN}3.${NC} SSH Configuration - Sets up SSH keys and config
    ${GREEN}4.${NC} Cloud Storage - Creates shortcuts to cloud storage folders

${YELLOW}ESTIMATED TIME:${NC}
    First run: 10-20 minutes (depending on Homebrew installations)
    Subsequent runs: 2-5 minutes

${YELLOW}WHAT GETS INSTALLED:${NC}
    - Homebrew package manager
    - Essential development tools and applications
    - Shell configurations (zsh, fish)
    - Terminal applications (wezterm, kitty, ghostty)
    - Development tools (git, atuin, starship, yazi, helix)
    - Various utility applications via Homebrew

${YELLOW}WHAT GETS CONFIGURED:${NC}
    - Shell dotfiles (.zshrc, .zprofile, etc.)
    - Application configurations in ~/.config/
    - Hammerspoon automation setup
    - SSH keys and configuration
    - Cloud storage shortcuts (Dropbox, Google Drive)

EOF
}

# Function to check if a script exists and is executable
check_script() {
    local script_path="$1"
    if [[ ! -f "$script_path" ]]; then
        print_error "Script not found: $script_path"
        return 1
    fi
    if [[ ! -x "$script_path" ]]; then
        print_warning "Making script executable: $script_path"
        if [[ $DRY_RUN == false ]]; then
            chmod +x "$script_path"
        fi
    fi
    return 0
}

# Function to run a script with error handling
run_script() {
    local script_path="$1"
    local script_name="$(basename "$script_path")"
    local description="$2"
    
    print_step "$description"
    print_info "Running: $script_name"
    
    if [[ $DRY_RUN == true ]]; then
        print_warning "DRY RUN: Would execute $script_path"
        return 0
    fi
    
    if check_script "$script_path"; then
        if "$script_path"; then
            print_success "$description completed successfully"
            return 0
        else
            print_error "$description failed (exit code: $?)"
            return 1
        fi
    else
        return 1
    fi
}

# Function to run linkFilesv3.sh in headless mode
run_linkfiles() {
    local script_path="$SCRIPT_DIR/linkFilesv3.sh"
    
    print_step "Setting up dotfiles symlinks"
    print_info "Running: linkFilesv3.sh --headless"
    
    if [[ $DRY_RUN == true ]]; then
        print_warning "DRY RUN: Would execute $script_path --dry-run"
        return 0
    fi
    
    if check_script "$script_path"; then
        if "$script_path" --headless; then
            print_success "Dotfiles linking completed successfully"
            return 0
        else
            print_error "Dotfiles linking failed (exit code: $?)"
            return 1
        fi
    else
        return 1
    fi
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --dry-run)
            DRY_RUN=true
            print_warning "DRY RUN MODE - No changes will be made"
            shift
            ;;
        --skip-brew)
            SKIP_BREW=true
            print_info "Skipping Homebrew setup"
            shift
            ;;
        --skip-ssh)
            SKIP_SSH=true
            print_info "Skipping SSH setup"
            shift
            ;;
        --skip-cloud)
            SKIP_CLOUD=true
            print_info "Skipping cloud storage setup"
            shift
            ;;
        --help|-h)
            show_help
            exit 0
            ;;
        *)
            print_error "Unknown option: $1"
            echo "Use --help for usage information"
            exit 1
            ;;
    esac
done

# Main execution
main() {
    echo -e "${CYAN}╔════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║${NC}                    ${PURPLE}Dotfiles Setup v${VERSION}${NC}                    ${CYAN}║${NC}"
    echo -e "${CYAN}╚════════════════════════════════════════════════════════════════╝${NC}"
    
    print_info "Starting automated dotfiles setup..."
    print_info "Working directory: $SCRIPT_DIR"
    
    if [[ $DRY_RUN == true ]]; then
        print_warning "DRY RUN MODE: No actual changes will be made"
    fi
    
    # Verify we're in the right directory
    if [[ ! -f "$SCRIPT_DIR/README.md" ]] || [[ ! -f "$SCRIPT_DIR/linkFilesv3.sh" ]]; then
        print_error "This script must be run from the dotfiles.v2 directory"
        print_error "Current directory: $SCRIPT_DIR"
        exit 1
    fi
    
    local failed_steps=()
    
    # Step 1: Homebrew Setup
    if [[ $SKIP_BREW == false ]]; then
        if ! run_script "$SCRIPT_DIR/brewSetup.sh" "Homebrew and package installation"; then
            failed_steps+=("Homebrew setup")
        fi
    else
        print_step "Skipping Homebrew setup (--skip-brew)"
    fi
    
    # Step 2: Dotfiles Linking
    if ! run_linkfiles; then
        failed_steps+=("Dotfiles linking")
    fi
    
    # Step 3: SSH Setup
    if [[ $SKIP_SSH == false ]]; then
        if ! run_script "$SCRIPT_DIR/sshSetup.sh" "SSH configuration"; then
            failed_steps+=("SSH setup")
        fi
    else
        print_step "Skipping SSH setup (--skip-ssh)"
    fi
    
    # Step 4: Cloud Storage Linking
    if [[ $SKIP_CLOUD == false ]]; then
        if ! run_script "$SCRIPT_DIR/linkCloudStorageProviders.sh" "Cloud storage shortcuts"; then
            failed_steps+=("Cloud storage linking")
        fi
    else
        print_step "Skipping cloud storage setup (--skip-cloud)"
    fi
    
    # Summary
    echo -e "\n${CYAN}╔════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║${NC}                        ${PURPLE}Setup Summary${NC}                         ${CYAN}║${NC}"
    echo -e "${CYAN}╚════════════════════════════════════════════════════════════════╝${NC}"
    
    if [[ ${#failed_steps[@]} -eq 0 ]]; then
        print_success "All setup steps completed successfully!"
        echo -e "\n${GREEN}Next steps:${NC}"
        echo -e "  • Restart your terminal or run: ${YELLOW}exec zsh${NC}"
        echo -e "  • Verify configurations with: ${YELLOW}./linkFilesv3.sh --check${NC}"
        echo -e "  • Check Homebrew status with: ${YELLOW}brew doctor${NC}"
        
        if [[ $DRY_RUN == false ]]; then
            echo -e "\n${PURPLE}Your development environment is now configured!${NC}"
        fi
    else
        print_error "Some steps failed:"
        for step in "${failed_steps[@]}"; do
            echo -e "  ${RED}•${NC} $step"
        done
        echo -e "\n${YELLOW}You can re-run this script or run individual scripts manually.${NC}"
        exit 1
    fi
}

# Trap to handle script interruption
trap 'echo -e "\n${YELLOW}Setup interrupted by user${NC}"; exit 130' INT

# Run main function
main "$@"