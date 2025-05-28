#!/usr/bin/env bash

# Application Discovery Script
# Captures all manually installed applications (excluding Homebrew-managed ones)
# and categorizes them by installation source

VERSION="2.0.0"

# Parse command line arguments
SHOW_JSON_LIST=false
JSON_FILE=""

for arg in "$@"; do
    case $arg in
        --jls)
            SHOW_JSON_LIST=true
            shift
            ;;
        --jls=*)
            SHOW_JSON_LIST=true
            JSON_FILE="${arg#*=}"
            shift
            ;;
        --help|-h)
            show_help
            exit 0
            ;;
        *)
            # Unknown option
            ;;
    esac
done

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

show_help() {
    cat << EOF
Application Discovery Script v${VERSION}

DESCRIPTION:
    Captures all manually installed applications (excluding Homebrew-managed ones)
    and categorizes them by installation source.

USAGE:
    $(basename "$0") [OPTIONS]

OPTIONS:
    --jls           List applications from the most recent JSON backup
    --jls=FILE      List applications from a specific JSON file
    -h, --help      Show this help message

EXAMPLES:
    $(basename "$0")                    # Generate new application report
    $(basename "$0") --jls              # Show apps from latest JSON backup
    $(basename "$0") --jls=backup.json  # Show apps from specific file

OUTPUT:
    - Console output with color-coded installation sources
    - JSON backup file in logs-backups/ directory

LEGEND:
    [MAS] - Mac App Store
    [DL]  - Direct Download
    [PKG] - PKG Installer
    [SYS] - System/Apple
    [???] - Unknown source
EOF
}

print_header() {
    echo -e "${BLUE}=== System Application Discovery v${VERSION} ===${NC}"
    echo -e "${BLUE}=== $(date) ===${NC}"
    echo
}

# Function to get Homebrew-managed applications
get_brew_apps() {
    if command -v brew >/dev/null 2>&1; then
        brew list --cask 2>/dev/null | sort
    fi
}

# Function to check if an app is managed by Homebrew
is_brew_app() {
    local app_name="$1"
    local brew_apps="$2"
    
    # Convert app name to lowercase and remove .app extension for comparison
    local clean_name=$(basename "$app_name" .app | tr '[:upper:]' '[:lower:]')
    
    # Check if any brew cask matches (allowing for different naming conventions)
    while IFS= read -r brew_app; do
        if [[ -n "$brew_app" ]]; then
            local clean_brew=$(echo "$brew_app" | tr '[:upper:]' '[:lower:]')
            # Match exact names or common variations
            if [[ "$clean_name" == "$clean_brew" ]] || \
               [[ "$clean_name" == *"$clean_brew"* ]] || \
               [[ "$clean_brew" == *"$clean_name"* ]]; then
                return 0
            fi
        fi
    done <<< "$brew_apps"
    return 1
}

# Function to detect Mac App Store apps
get_mas_apps() {
    echo -e "${GREEN}📱 Mac App Store Applications:${NC}"
    find /Applications -path '*Contents/_MASReceipt/receipt' -maxdepth 4 -print 2>/dev/null | \
    sed 's#.app/Contents/_MASReceipt/receipt#.app#g; s#/Applications/##' | \
    sort | while read -r app; do
        if [[ -n "$app" ]]; then
            echo "  • $app"
        fi
    done
    echo
}

# Function to get app bundle info
get_app_info() {
    local app_path="$1"
    local info_plist="$app_path/Contents/Info.plist"
    
    if [[ -f "$info_plist" ]]; then
        # Get bundle identifier and version
        local bundle_id=$(defaults read "$info_plist" CFBundleIdentifier 2>/dev/null || echo "unknown")
        local version=$(defaults read "$info_plist" CFBundleShortVersionString 2>/dev/null || \
                       defaults read "$info_plist" CFBundleVersion 2>/dev/null || echo "unknown")
        echo "$bundle_id|$version"
    else
        echo "unknown|unknown"
    fi
}

# Function to detect installation source
detect_source() {
    local app_path="$1"
    local app_name=$(basename "$app_path")
    
    # Check for Mac App Store receipt
    if [[ -f "$app_path/Contents/_MASReceipt/receipt" ]]; then
        echo "App Store"
        return
    fi
    
    # Check for common installer signatures
    local info_plist="$app_path/Contents/Info.plist"
    if [[ -f "$info_plist" ]]; then
        # Check for common enterprise/installer signatures in bundle ID
        local bundle_id=$(defaults read "$info_plist" CFBundleIdentifier 2>/dev/null || echo "")
        
        case "$bundle_id" in
            com.microsoft.*|com.adobe.*|com.google.*|com.zoom.*|com.slack.*|com.spotify.*|com.dropbox.*|com.docker.*)
                echo "Direct Download"
                ;;
            com.apple.*)
                echo "System/Apple"
                ;;
            *)
                # Check for pkg installer receipts in system
                local receipt_name=$(echo "$app_name" | sed 's/.app$//' | tr '[:upper:]' '[:lower:]')
                if pkgutil --pkgs | grep -qi "$receipt_name" 2>/dev/null; then
                    echo "PKG Installer"
                else
                    echo "Manual Install"
                fi
                ;;
        esac
    else
        echo "Unknown"
    fi
}

# Function to analyze standalone applications
analyze_standalone_apps() {
    echo -e "${GREEN}💻 Standalone Applications (Non-Homebrew):${NC}"
    
    # Get list of Homebrew-managed apps
    local brew_apps=$(get_brew_apps)
    
    # Find all .app bundles in common locations
    local app_locations=(
        "/Applications"
        "/Applications/Utilities"
        "$HOME/Applications"
        "/System/Applications"
    )
    
    for location in "${app_locations[@]}"; do
        if [[ -d "$location" ]]; then
            find "$location" -name "*.app" -maxdepth 2 -type d 2>/dev/null | sort | while read -r app_path; do
                local app_name=$(basename "$app_path")
                
                # Skip if it's a Homebrew-managed app
                if is_brew_app "$app_name" "$brew_apps"; then
                    continue
                fi
                
                # Skip system apps in /System/Applications (optional)
                if [[ "$app_path" == /System/Applications/* ]]; then
                    continue
                fi
                
                local source=$(detect_source "$app_path")
                local app_info=$(get_app_info "$app_path")
                local bundle_id=$(echo "$app_info" | cut -d'|' -f1)
                local version=$(echo "$app_info" | cut -d'|' -f2)
                
                # Color code by source
                case "$source" in
                    "App Store")
                        echo -e "  ${BLUE}[MAS]${NC} $app_name (v$version)"
                        ;;
                    "Direct Download")
                        echo -e "  ${GREEN}[DL]${NC}  $app_name (v$version)"
                        ;;
                    "PKG Installer")
                        echo -e "  ${YELLOW}[PKG]${NC} $app_name (v$version)"
                        ;;
                    "System/Apple")
                        echo -e "  ${RED}[SYS]${NC} $app_name (v$version)"
                        ;;
                    *)
                        echo -e "  ${NC}[???]${NC} $app_name (v$version)"
                        ;;
                esac
            done
        fi
    done
    echo
}

# Function to generate detailed JSON report
generate_json_report() {
    local output_file="logs-backups/installed-applications-$(date +%Y%m%d_%H%M%S).json"
    
    echo -e "${BLUE}📄 Generating detailed JSON report: $output_file${NC}"
    
    {
        echo "{"
        echo '  "timestamp": "'$(date -Iseconds)'",'
        echo '  "hostname": "'$(hostname)'",'
        echo '  "applications": ['
        
        local first_app=true
        
        # Get Homebrew apps for filtering
        local brew_apps=$(get_brew_apps)
        
        # Process all applications
        find /Applications /Applications/Utilities "$HOME/Applications" -name "*.app" -maxdepth 2 -type d 2>/dev/null | sort | while read -r app_path; do
            local app_name=$(basename "$app_path")
            
            # Skip Homebrew-managed apps
            if is_brew_app "$app_name" "$brew_apps"; then
                continue
            fi
            
            local source=$(detect_source "$app_path")
            local app_info=$(get_app_info "$app_path")
            local bundle_id=$(echo "$app_info" | cut -d'|' -f1)
            local version=$(echo "$app_info" | cut -d'|' -f2)
            local install_date="unknown"
            
            # Try to get installation date
            if [[ -d "$app_path" ]]; then
                install_date=$(stat -f "%Sm" -t "%Y-%m-%d" "$app_path" 2>/dev/null || echo "unknown")
            fi
            
            # Add comma for all but first entry
            if [[ "$first_app" != true ]]; then
                echo ","
            fi
            first_app=false
            
            echo -n '    {'
            echo -n '"name": "'$app_name'", '
            echo -n '"path": "'$app_path'", '
            echo -n '"bundle_id": "'$bundle_id'", '
            echo -n '"version": "'$version'", '
            echo -n '"source": "'$source'", '
            echo -n '"install_date": "'$install_date'"'
            echo -n '}'
        done
        
        echo ""
        echo "  ]"
        echo "}"
    } > "$output_file"
    
    echo -e "${GREEN}✅ Report saved to: $output_file${NC}"
    echo
}

# Function to show Homebrew comparison
show_brew_comparison() {
    echo -e "${GREEN}🍺 Homebrew-Managed Applications (for reference):${NC}"
    get_brew_apps | while read -r app; do
        if [[ -n "$app" ]]; then
            echo "  • $app"
        fi
    done
    echo
}

# Function to show summary statistics
show_summary() {
    echo -e "${GREEN}📊 Summary:${NC}"
    
    local total_apps=$(find /Applications /Applications/Utilities "$HOME/Applications" -name "*.app" -maxdepth 2 -type d 2>/dev/null | wc -l | tr -d ' ')
    local brew_apps_count=$(get_brew_apps | wc -l | tr -d ' ')
    local mas_apps_count=$(find /Applications -path '*Contents/_MASReceipt/receipt' -maxdepth 4 2>/dev/null | wc -l | tr -d ' ')
    local standalone_count=$((total_apps - brew_apps_count))
    
    echo "  Total Applications: $total_apps"
    echo "  Homebrew Managed: $brew_apps_count"
    echo "  Mac App Store: $mas_apps_count"
    echo "  Other Standalone: $((standalone_count - mas_apps_count))"
    echo
}

# Function to list applications from JSON backup
list_from_json() {
    local json_file="$1"
    
    # If no specific file provided, find the most recent one
    if [[ -z "$json_file" ]]; then
        json_file=$(find logs-backups/ -name "installed-applications-*.json" -type f 2>/dev/null | sort | tail -1)
        
        if [[ -z "$json_file" ]]; then
            echo -e "${RED}❌ No JSON backup files found in logs-backups/${NC}"
            echo "Run the script without --jls to generate a backup first."
            exit 1
        fi
        
        echo -e "${BLUE}📄 Using most recent backup: $json_file${NC}"
    elif [[ ! -f "$json_file" ]]; then
        echo -e "${RED}❌ File not found: $json_file${NC}"
        exit 1
    fi
    
    echo -e "${GREEN}📱 Applications from backup ($(basename "$json_file")):${NC}"
    echo
    
    # Check if jq is available for better parsing
    if command -v jq >/dev/null 2>&1; then
        # Use jq for robust JSON parsing
        jq -r '.applications[] | "\(.source)|\(.name)|\(.version)|\(.install_date)"' "$json_file" 2>/dev/null | \
        sort -t'|' -k1,1 -k2,2 | while IFS='|' read -r source name version install_date; do
            case "$source" in
                "App Store")
                    echo -e "  ${BLUE}[MAS]${NC} $name (v$version) - installed: $install_date"
                    ;;
                "Direct Download")
                    echo -e "  ${GREEN}[DL]${NC}  $name (v$version) - installed: $install_date"
                    ;;
                "PKG Installer")
                    echo -e "  ${YELLOW}[PKG]${NC} $name (v$version) - installed: $install_date"
                    ;;
                "System/Apple")
                    echo -e "  ${RED}[SYS]${NC} $name (v$version) - installed: $install_date"
                    ;;
                *)
                    echo -e "  ${NC}[???]${NC} $name (v$version) - installed: $install_date"
                    ;;
            esac
        done
    else
        # Fallback parsing without jq (less robust but functional)
        echo -e "${YELLOW}⚠️  jq not found, using basic parsing${NC}"
        grep -o '"name": "[^"]*"' "$json_file" | sed 's/"name": "//;s/"//' | while read -r name; do
            echo "  • $name"
        done
    fi
    
    echo
    
    # Show summary by source
    if command -v jq >/dev/null 2>&1; then
        echo -e "${GREEN}📊 Summary by source:${NC}"
        jq -r '.applications[].source' "$json_file" 2>/dev/null | sort | uniq -c | while read -r count source; do
            case "$source" in
                "App Store")
                    echo -e "  ${BLUE}$count Mac App Store apps${NC}"
                    ;;
                "Direct Download")
                    echo -e "  ${GREEN}$count Direct Download apps${NC}"
                    ;;
                "PKG Installer")
                    echo -e "  ${YELLOW}$count PKG Installer apps${NC}"
                    ;;
                "System/Apple")
                    echo -e "  ${RED}$count System/Apple apps${NC}"
                    ;;
                *)
                    echo -e "  $count $source apps"
                    ;;
            esac
        done
        
        echo
        echo -e "${BLUE}💡 To reinstall on new machine:${NC}"
        echo -e "  • App Store apps: Search and install manually or use 'mas' CLI tool"
        echo -e "  • Direct Downloads: Visit vendor websites"
        echo -e "  • PKG Installers: Re-run installer packages"
    fi
}

# Main execution
main() {
    # Handle --jls option
    if [[ "$SHOW_JSON_LIST" == true ]]; then
        list_from_json "$JSON_FILE"
        exit 0
    fi
    
    print_header
    
    # Create logs directory if it doesn't exist
    mkdir -p logs-backups
    
    # Show different categories
    get_mas_apps
    analyze_standalone_apps
    show_brew_comparison
    show_summary
    
    # Generate JSON report
    generate_json_report
    
    echo -e "${BLUE}Legend:${NC}"
    echo -e "  ${BLUE}[MAS]${NC} - Mac App Store"
    echo -e "  ${GREEN}[DL]${NC}  - Direct Download"
    echo -e "  ${YELLOW}[PKG]${NC} - PKG Installer"
    echo -e "  ${RED}[SYS]${NC} - System/Apple"
    echo -e "  [???] - Unknown source"
}

# Run if executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi