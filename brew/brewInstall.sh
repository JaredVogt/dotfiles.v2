#!/usr/bin/env zsh

# This script automates the installation and updating of Homebrew packages and casks.
# It reads a package list from a specified input file and:
#   - Detects which packages/casks are already installed
#   - Identifies which installed packages need updates
#   - Provides an interactive installation process
#   - Supports both regular Homebrew formulae and casks (GUI applications)
#
# Usage: ./script.sh [--verbose] <package-list-file>

VERBOSE=false
LOG_FILE="brew_install.log"

# Function to log with timestamp
log_message() {
    echo "$1" | tee -a "$LOG_FILE"
}

# Function to log only if verbose
verbose_log() {
    if [ "$VERBOSE" = true ]; then
        log_message "$1"
    fi
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --verbose)
            VERBOSE=true
            shift
            ;;
        *)
            input_file="$1"
            shift
            ;;
    esac
done

# Check if input file exists
if [ -z "$input_file" ]; then
    echo "Usage: $0 [--verbose] <package-list-file>"
    exit 1
fi

if [ ! -f "$input_file" ]; then
    echo "Error: File $input_file not found"
    exit 1
fi

# Display current brew status if verbose
if [ "$VERBOSE" = true ]; then
    echo "=== Currently Installed Packages ==="
    brew list
    echo -e "\n=== Outdated Packages ==="
    brew outdated
    echo
fi

# Get list of installed packages
installed_packages=$(brew list)
outdated_packages=$(brew outdated)

# Function to check if package is installed
is_installed() {
    local package=$1
    echo "$installed_packages" | grep -q "^${package}$"
    return $?
}

# Function to check if package needs upgrade
needs_upgrade() {
    local package=$1
    echo "$outdated_packages" | grep -q "^${package}$"
    return $?
}

# Separate casks and regular packages
regular_packages=()
cask_packages=()

while IFS= read -r line; do
    if [[ -z "$line" ]] || [[ "$line" =~ ^[[:space:]]*# ]]; then
        continue
    fi
    
    if [[ "$line" == "--cask"* ]]; then
        package_name=$(echo "${line#--cask}" | xargs)
        cask_packages+=("$package_name")
    else
        regular_packages+=("$line")
    fi
done < "$input_file"

# Prepare lists for summary
to_install_regular=()
to_upgrade_regular=()
to_install_cask=()
to_upgrade_cask=()

# Check regular packages
for package in "${regular_packages[@]}"; do
    if is_installed "$package"; then
        if needs_upgrade "$package"; then
            to_upgrade_regular+=("$package")
        fi
    else
        to_install_regular+=("$package")
    fi
done

# Check cask packages
for package in "${cask_packages[@]}"; do
    if is_installed "$package"; then
        if needs_upgrade "$package"; then
            to_upgrade_cask+=("$package")
        fi
    else
        to_install_cask+=("$package")
    fi
done

# Print summary (to terminal only)
echo "=== Installation Summary ==="
echo "Regular packages to install (${#to_install_regular[@]}):"
printf '%s\n' "${to_install_regular[@]}" | sed 's/^/  - /'
echo -e "\nRegular packages to upgrade (${#to_upgrade_regular[@]}):"
printf '%s\n' "${to_upgrade_regular[@]}" | sed 's/^/  - /'
echo -e "\nCask packages to install (${#to_install_cask[@]}):"
printf '%s\n' "${to_install_cask[@]}" | sed 's/^/  - /'
echo -e "\nCask packages to upgrade (${#to_upgrade_cask[@]}):"
printf '%s\n' "${to_upgrade_cask[@]}" | sed 's/^/  - /'

echo -e "\n=== Starting Installation Process ===\n"

# Ask if user wants to say yes to everything
read "auto_yes?Do you want to automatically say yes to all installations and updates? [y/N] "
echo # Add newline

# Initialize associative array for decisions
typeset -A package_decisions

if [[ "$auto_yes" =~ ^[Yy]$ ]]; then
    # Set all decisions to yes
    for package in "${to_install_regular[@]}" "${to_upgrade_regular[@]}"; do
        package_decisions[$package]=1
    done
    for package in "${to_install_cask[@]}" "${to_upgrade_cask[@]}"; do
        package_decisions[$package]=1
    done
else
    # Ask for confirmation for each package first
    echo "Please answer the following questions. The actual installation will start after all questions are answered."
    
    # Ask about regular packages
    for package in "${regular_packages[@]}"; do
        if is_installed "$package"; then
            if needs_upgrade "$package"; then
                read "response?$package is installed but outdated. Upgrade? [y/N] "
                [[ "$response" =~ ^[Yy]$ ]] && package_decisions[$package]=1 || package_decisions[$package]=0
            fi
        else
            read "response?Install $package? [y/N] "
            [[ "$response" =~ ^[Yy]$ ]] && package_decisions[$package]=1 || package_decisions[$package]=0
        fi
    done

    # Ask about cask packages
    for package in "${cask_packages[@]}"; do
        if is_installed "$package"; then
            if needs_upgrade "$package"; then
                read "response?$package is installed but outdated. Upgrade? [y/N] "
                [[ "$response" =~ ^[Yy]$ ]] && package_decisions[$package]=1 || package_decisions[$package]=0
            fi
        else
            read "response?Install $package (cask)? [y/N] "
            [[ "$response" =~ ^[Yy]$ ]] && package_decisions[$package]=1 || package_decisions[$package]=0
        fi
    done
fi

# Final confirmation before proceeding
read "proceed?Ready to proceed with installations and updates. Continue? [y/N] "
if [[ ! "$proceed" =~ ^[Yy]$ ]]; then
    echo "Installation cancelled."
    exit 0
fi

# Only now do we start writing to the log file
echo -e "\n=== Brew Installation Run - $(date '+%Y-%m-%d %H:%M:%S') ===\n" >> "$LOG_FILE"

# Write the summary to the log file
log_message "=== Installation Summary ==="
log_message "Regular packages to install (${#to_install_regular[@]}):"
printf '%s\n' "${to_install_regular[@]}" | sed 's/^/  - /' | tee -a "$LOG_FILE"
log_message "\nRegular packages to upgrade (${#to_upgrade_regular[@]}):"
printf '%s\n' "${to_upgrade_regular[@]}" | sed 's/^/  - /' | tee -a "$LOG_FILE"
log_message "\nCask packages to install (${#to_install_cask[@]}):"
printf '%s\n' "${to_install_cask[@]}" | sed 's/^/  - /' | tee -a "$LOG_FILE"
log_message "\nCask packages to upgrade (${#to_upgrade_cask[@]}):"
printf '%s\n' "${to_upgrade_cask[@]}" | sed 's/^/  - /' | tee -a "$LOG_FILE"

# Process regular packages
log_message "\nProcessing regular packages..."
for package in "${regular_packages[@]}"; do
    if is_installed "$package"; then
        if needs_upgrade "$package"; then
            if (( ${package_decisions[$package]} )); then
                log_message "🔄 Upgrading $package..."
                brew upgrade "$package" 2>&1 | tee -a "$LOG_FILE"
                log_message ""  # Add line break after package completion
            else
                log_message "Skipping upgrade of $package"
            fi
        else
            verbose_log "$package is already installed and up to date. Skipping."
        fi
    else
        if (( ${package_decisions[$package]} )); then
            log_message "🔄 Installing $package..."
            brew install "$package" 2>&1 | tee -a "$LOG_FILE"
            log_message ""  # Add line break after package completion
        else
            log_message "Skipping installation of $package"
        fi
    fi
done

# Process cask packages
log_message "\nProcessing cask packages..."
for package in "${cask_packages[@]}"; do
    if is_installed "$package"; then
        if needs_upgrade "$package"; then
            if (( ${package_decisions[$package]} )); then
                log_message "🔄 Upgrading $package..."
                brew upgrade --cask "$package" 2>&1 | tee -a "$LOG_FILE"
                log_message ""  # Add line break after package completion
            else
                log_message "Skipping upgrade of $package"
            fi
        else
            verbose_log "$package is already installed and up to date. Skipping."
        fi
    else
        if (( ${package_decisions[$package]} )); then
            log_message "🔄 Installing $package..."
            brew install --cask "$package" 2>&1 | tee -a "$LOG_FILE"
            log_message ""  # Add line break after package completion
        else
            log_message "Skipping installation of $package"
        fi
    fi
done

log_message "Installation process complete!"
