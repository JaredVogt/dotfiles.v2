#!/usr/bin/env bash

# Homebrew Package Manager Script
# Version: 1.4.1
#
# DESCRIPTION:
# This script provides comprehensive tools for managing Homebrew installations on macOS.
# It helps with package analysis, backup/restore operations, update management, and system migration.
#
# MAIN FEATURES:
# - Verbose analysis of installed formulae and casks with dependency mapping
# - Generate JSON backup files with package details for system migration
# - Restore packages from JSON backup files on fresh installations
# - Check for outdated packages and perform updates
# - Dry-run mode to preview operations without making changes
# - Interactive menu interface for easy operation
# - Comprehensive logging of all operations
#
# USAGE:
# Interactive mode (recommended):
#   ./brewSetup.sh
#
# Command-line flags:
#   ./brewSetup.sh --verbose         # Show detailed package analysis
#   ./brewSetup.sh --backup          # Generate homebrew-packages.json backup
#   ./brewSetup.sh --install         # Install packages from JSON backup
#   ./brewSetup.sh --dry-run         # Preview what would be installed
#   ./brewSetup.sh --check-outdated  # Check for package updates
#   ./brewSetup.sh --update          # Update all outdated packages
#
# TYPICAL WORKFLOWS:
# 1. System Migration:
#    - On old system: ./brewSetup.sh --backup
#    - Copy homebrew-packages.json to new system
#    - On new system: ./brewSetup.sh --install
#
# 2. Regular Maintenance:
#    - ./brewSetup.sh --verbose (shows analysis + update check)
#    - ./brewSetup.sh --update (if updates are needed)
#
# 3. Package Backup:
#    - ./brewSetup.sh --backup (creates timestamped backup)
#
# DEPENDENCIES:
# - brew (Homebrew package manager)
# - jq (JSON processor - auto-installed if missing)
# - python3 (for JSON processing)
#
# OUTPUT:
# - homebrew-packages.json: Package backup file
# - logs-backups/: Directory containing operation logs and backups
#
# NOTES:
# - Script only installs top-level packages; dependencies are handled automatically
# - All operations are logged with timestamps
# - Existing files are backed up before being overwritten

VERSION="1.4.1"

# Colors for better readability
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Globals
LOGS_BACKUPS_DIR="./logs-backups"
LOG_ENABLED=true
log_file="${LOGS_BACKUPS_DIR}/homebrew_install_$(date +%Y%m%d_%H%M%S).log"

# Ensure logs-backups directory exists
prepare_logs_backups_dir() {
    if [ ! -d "$LOGS_BACKUPS_DIR" ]; then
        mkdir -p "$LOGS_BACKUPS_DIR"
        chmod 755 "$LOGS_BACKUPS_DIR"
        echo -e "${GREEN}Created directory: $LOGS_BACKUPS_DIR${NC}"
    fi
}

# Initialize log file
initialize_log_file() {
    touch "$log_file"
    chmod 644 "$log_file"
}

# Ensure jq is installed
install_jq() {
    if ! command -v jq >/dev/null; then
        log_and_print "${YELLOW}Installing jq...${NC}"
        brew install jq || {
            log_and_print "${RED}Failed to install jq. Please install it manually.${NC}"
            exit 1
        }
    fi
}

# Preflight checks
check_dependencies() {
    for cmd in brew jq python3; do
        if ! command -v "$cmd" >/dev/null; then
            log_and_print "${RED}Error: $cmd is not installed. Please install it before running this script.${NC}"
            exit 1
        fi
    done
}

# Utility: Print and optionally log
log_and_print() {
    local message="$1"
    echo -e "$message"
    $LOG_ENABLED && echo -e "$message" >> "$log_file"
}

# Check for outdated packages
check_outdated_packages() {
    log_and_print "\n🔄 Checking for outdated packages..."
    local outdated_formulae
    local outdated_casks
    
    outdated_formulae=$(brew outdated --formula 2>/dev/null)
    outdated_casks=$(brew outdated --cask 2>/dev/null)
    
    if [ ! -z "$outdated_formulae" ] || [ ! -z "$outdated_casks" ]; then
        log_and_print "\n${YELLOW}⚠️  Outdated Packages Found:${NC}"
        
        if [ ! -z "$outdated_formulae" ]; then
            log_and_print "\n📦 Outdated Formulae:"
            echo "$outdated_formulae" | while IFS= read -r line; do
                log_and_print "• $line"
            done
        fi
        
        if [ ! -z "$outdated_casks" ]; then
            log_and_print "\n🎪 Outdated Casks:"
            echo "$outdated_casks" | while IFS= read -r line; do
                log_and_print "• $line"
            done
        fi
        
        log_and_print "\n${BLUE}Run 'brew upgrade' to update all packages or use menu option 6.${NC}"
        return 0
    else
        log_and_print "\n${GREEN}✅ All packages are up to date!${NC}"
        return 1
    fi
}

# Update all outdated packages
update_packages() {
    log_and_print "\n${BLUE}Updating all outdated packages...${NC}"
    
    local outdated_formulae
    local outdated_casks
    
    outdated_formulae=$(brew outdated --formula 2>/dev/null)
    outdated_casks=$(brew outdated --cask 2>/dev/null)
    
    if [ -z "$outdated_formulae" ] && [ -z "$outdated_casks" ]; then
        log_and_print "${GREEN}All packages are already up to date!${NC}"
        return
    fi
    
    if [ ! -z "$outdated_formulae" ]; then
        log_and_print "\n📦 Updating formulae..."
        brew upgrade 2>&1 | tee -a "$log_file"
    fi
    
    if [ ! -z "$outdated_casks" ]; then
        log_and_print "\n🎪 Updating casks..."
        brew upgrade --cask 2>&1 | tee -a "$log_file"
    fi
    
    log_and_print "\n${GREEN}✅ Package updates complete!${NC}"
}

# Show verbose output
show_verbose_output() {
    log_and_print "\n=== Homebrew Installation Analysis v${VERSION} ==="
    log_and_print "=== $(date) ===\n"

    log_and_print "📦 Top Level Packages (brew leaves):"
    brew leaves | while IFS= read -r formula; do
        log_and_print "• $formula"
        deps=$(brew deps "$formula")
        if [ ! -z "$deps" ]; then
            log_and_print "  Dependencies:"
            log_and_print "$(echo "$deps" | sed 's/^/    /')"
        fi
    done

    log_and_print "\n🍺 All Installed Formulae:"
    brew list --formula | while IFS= read -r formula; do
        log_and_print "• $formula"
        uses=$(brew uses --installed "$formula")
        if [ ! -z "$uses" ]; then
            log_and_print "  Used by:"
            log_and_print "$(echo "$uses" | sed 's/^/    /')"
        fi
    done

    log_and_print "\n🎪 Installed Casks:"
    brew list --cask | while IFS= read -r cask; do
        log_and_print "• $cask"
    done

    # Check for outdated packages
    check_outdated_packages

    log_and_print "\n📊 Summary Statistics:"
    log_and_print "Total Formulae: $(brew list --formula | wc -l | tr -d ' ')"
    log_and_print "Total Casks: $(brew list --cask | wc -l | tr -d ' ')"
    log_and_print "Top Level Packages: $(brew leaves | wc -l | tr -d ' ')"
}

# Generate JSON file
generate_json_output() {
    local json_file="homebrew-packages.json"

    # Backup the existing JSON file, if it exists
    if [ -f "$json_file" ]; then
        local backup_file="${LOGS_BACKUPS_DIR}/homebrew-packages_backup_$(date +%Y%m%d_%H%M%S).json"
        cp "$json_file" "$backup_file"
        log_and_print "${YELLOW}Existing JSON file backed up as $backup_file.${NC}"
    fi

    log_and_print "Generating JSON file at $json_file..."

    {
        echo "{"
        echo '    "formulae": ['
        brew leaves | while IFS= read -r formula; do
            local version
            version=$(brew info --json=v2 "$formula" | jq -r '.formulae[0].versions.stable')
            local installed_on
            installed_on=$(ls -ld "$(brew --cellar)/$formula" | awk '{print $6, $7, $8}')
            local dependencies
            dependencies=$(brew deps "$formula" 2>/dev/null | jq -R -s -c 'split("\n")[:-1]')
            echo "        {\"name\": \"$formula\", \"version\": \"$version\", \"installed_on\": \"$installed_on\", \"dependencies\": $dependencies},"
        done | sed '$ s/,$//'
        echo "    ],"
        echo '    "casks": ['
        brew list --cask | while IFS= read -r cask; do
            local version
            version=$(brew info --json=v2 --cask "$cask" | jq -r '.casks[0].version')
            local installed_on
            installed_on=$(ls -ld "$(brew --caskroom)/$cask" | awk '{print $6, $7, $8}')
            local dependencies
            dependencies=$(brew info --json=v2 --cask "$cask" | jq -r '.casks[0].depends_on | values | .[] | select(. != null) | keys[]' | jq -R -s -c 'split("\n")[:-1]')
            echo "        {\"name\": \"$cask\", \"version\": \"$version\", \"installed_on\": \"$installed_on\", \"dependencies\": $dependencies},"
        done | sed '$ s/,$//'
        echo "    ]"
        echo "}"
    } > "$json_file"

    log_and_print "${GREEN}JSON file generated successfully at $json_file.${NC}"
}

install_from_json() {
    local dry_run=false
    if [ "$1" == "--dry-run" ]; then
        dry_run=true
        log_and_print "${YELLOW}Dry-run mode enabled. No changes will be made.${NC}"
    fi

    local json_file="homebrew-packages.json"
    if [ ! -f "$json_file" ]; then
        log_and_print "${RED}Error: $json_file not found${NC}"
        exit 1
    fi

    local formulae
    formulae=$(jq -r '.formulae[].name' "$json_file")
    local casks
    casks=$(jq -r '.casks[].name' "$json_file")

    log_and_print "\n${BLUE}Processing formulae:${NC}"
    for formula in $formulae; do
        if ! brew list --formula | grep -q "^${formula}$"; then
            if [ "$dry_run" = true ]; then
                log_and_print "Would install $formula..."
            else
                log_and_print "Installing $formula..."
                brew install "$formula" 2>&1 | grep -Ev 'Fetching|Downloading|Pouring|Running' | tee -a "$log_file"
            fi
        else
            log_and_print "$formula is already installed"
        fi
    done

    log_and_print "\n${BLUE}Processing casks:${NC}"
    for cask in $casks; do
        if ! brew list --cask | grep -q "^${cask}$"; then
            if [ "$dry_run" = true ]; then
                log_and_print "Would install $cask..."
            else
                log_and_print "Installing $cask..."
                brew install --cask "$cask" 2>&1 | grep -Ev 'Fetching|Downloading|Pouring|Running' | tee -a "$log_file"
            fi
        else
            log_and_print "$cask is already installed"
        fi
    done

    log_and_print "\n${GREEN}Processing complete.${NC}"
}

show_menu() {
    while true; do
        echo
        echo -e "${BLUE}=== Homebrew Package Manager v${VERSION} ===${NC}"
        echo -e "${GREEN}Comprehensive tool for managing Homebrew installations on macOS${NC}"
        echo -e "${GREEN}• Analyze installed packages with dependency mapping${NC}"
        echo -e "${GREEN}• Create JSON backups for system migration${NC}"
        echo -e "${GREEN}• Restore packages from backups on fresh systems${NC}"
        echo -e "${GREEN}• Check for updates and perform package maintenance${NC}"
        echo -e "${GREEN}• All operations logged to logs-backups/ directory${NC}"
        echo
        echo "1) Show verbose installation analysis"
        echo "2) Generate backup JSON file"
        echo "3) Install packages from JSON file"
        echo "4) Dry-run: Show what would be installed"
        echo "5) Check for outdated packages"
        echo "6) Update all outdated packages"
        echo "7) Exit"
        echo
        read -p "Select an option (1-7): " choice

        case $choice in
            1) show_verbose_output ;;
            2) generate_json_output ;;
            3) install_from_json ;;
            4) install_from_json --dry-run ;;
            5) check_outdated_packages ;;
            6) update_packages ;;
            7) echo "Goodbye!" && exit 0 ;;
            *) log_and_print "${RED}Invalid option selected.${NC}" ;;
        esac
    done
}

# Main execution
prepare_logs_backups_dir
initialize_log_file
install_jq
check_dependencies

case "$1" in
    --verbose) show_verbose_output ;;
    --backup) generate_json_output ;;
    --output) generate_json_output ;;  # Deprecated: use --backup
    --install) install_from_json ;;
    --dry-run) install_from_json --dry-run ;;
    --check-outdated) check_outdated_packages ;;
    --update) update_packages ;;
    *) show_menu ;;
esac