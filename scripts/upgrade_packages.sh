#!/usr/bin/env bash

set -euo pipefail

# Script configuration
readonly SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)
readonly SCRIPT_NAME=$(basename "${BASH_SOURCE[0]}")
readonly LOCK_FILE="/tmp/${SCRIPT_NAME}.lock"

# Color codes - check if colors are supported
if [[ -t 1 ]] && [[ -n "$TERM" ]]; then
    # Colors are supported
    RED='\033[31m'
    GREEN='\033[0;32m'
    YELLOW='\033[33m'
    BLUE='\033[34m'
    MAGENTA='\033[35m'
    CYAN='\033[36m'
    BOLD='\033[1m'
    RESET='\033[0m'
else
    # Colors are not supported
    RED=''
    GREEN=''
    YELLOW=''
    BLUE=''
    MAGENTA=''
    CYAN=''
    BOLD=''
    RESET=''
fi

# Timestamp function
timestamp() {
    date '+%Y-%m-%d %H:%M:%S'
}

# Log functions with timestamps
log_error() {
    echo -e "${RED}[ERROR] $(timestamp)${RESET} ${1}" >&2
}

log_info() {
    echo -e "${GREEN}[INFO] $(timestamp)${RESET} ${1}"
}

log_warning() {
    echo -e "${YELLOW}[WARN] $(timestamp)${RESET} ${1}"
}

log_debug() {
    if [[ "${DEBUG:-false}" == "true" ]]; then
        echo -e "${BLUE}[DEBUG] $(timestamp)${RESET} ${1}"
    fi
}

log_success() {
    echo -e "${GREEN}${BOLD}[SUCCESS] $(timestamp)${RESET} ${1}"
}

log_step() {
    echo -e "${CYAN}${BOLD}[STEP] $(timestamp)${RESET} ${1}"
}

# Print section header
print_header() {
    local title="$1"
    local width=${2:-60}
    local char=${3:-"="}
    
    echo
    echo -e "${BOLD}${MAGENTA}$(printf "%${width}s" | tr ' ' "$char")${RESET}"
    echo -e "${BOLD}${MAGENTA}  $title${RESET}"
    echo -e "${BOLD}${MAGENTA}$(printf "%${width}s" | tr ' ' "$char")${RESET}"
    echo
}

# Print footer
print_footer() {
    local message="$1"
    local width=${2:-60}
    local char=${3:-"="}
    
    echo
    echo -e "${BOLD}${GREEN}$(printf "%${width}s" | tr ' ' "$char")${RESET}"
    echo -e "${BOLD}${GREEN}  $message${RESET}"
    echo -e "${BOLD}${GREEN}$(printf "%${width}s" | tr ' ' "$char")${RESET}"
    echo
}

# Trap to clean up lock file on exit
cleanup() {
    if [[ -f "${LOCK_FILE}" ]]; then
        rm -f "${LOCK_FILE}"
    fi
}

trap cleanup EXIT INT TERM

# Check if script is already running
if [[ -f "${LOCK_FILE}" ]]; then
    log_error "Another instance of ${SCRIPT_NAME} is already running"
    exit 1
fi

# Create lock file
touch "${LOCK_FILE}"

# Function to check if running as root
check_root() {
    if [[ $EUID -eq 0 ]]; then
        log_error "This script should not be run as root"
        exit 1
    fi
}

# Function to check if sudo is available
check_sudo() {
    if ! command -v sudo >/dev/null 2>&1; then
        log_error "sudo is not available"
        exit 1
    fi
    
    if ! sudo -n true 2>/dev/null; then
        log_info "Sudo password will be required"
    fi
}

# Function to check if apt is available
check_apt() {
    if ! command -v apt-get >/dev/null 2>&1; then
        log_error "This script is designed for Debian/Ubuntu systems with apt"
        exit 1
    fi
}

# Function to handle user input for reboot
prompt_reboot() {
    local max_attempts=3
    local attempt=1
    
    while [[ $attempt -le $max_attempts ]]; do
        echo
        log_warning "Reboot is required to finish installing updates. Reboot now? [Y/n/q]"
        read -r -n 1 -s input
        echo
        
        case "${input,,}" in
            y|"")
                log_info "Rebooting system..."
                sudo reboot
                exit 0
                ;;
            n)
                log_warning "Please reboot manually to finish installation"
                return 1
                ;;
            q)
                log_info "Exiting without rebooting"
                return 1
                ;;
            *)
                if [[ $attempt -lt $max_attempts ]]; then
                    log_warning "Invalid input. Please enter Y, n, or q (attempt $attempt/$max_attempts)"
                    ((attempt++))
                else
                    log_error "Too many invalid attempts. Exiting."
                    return 1
                fi
                ;;
        esac
    done
}

# Function to upgrade system packages
upgrade_system_packages() {
    log_step "Starting system package upgrade"
    
    # Check prerequisites
    check_root
    check_sudo
    check_apt
    
    log_info "*** Upgrading system packages..."
    
    # Configure any pending packages
    log_debug "Configuring pending packages..."
    if ! sudo dpkg --configure -a; then
        log_error "Failed to configure pending packages"
        return 1
    fi
    
    # Update package lists
    log_debug "Updating package lists..."
    if ! sudo apt-get update -qqy; then
        log_error "Failed to update package lists"
        return 1
    fi
    
    # Perform distribution upgrade
    log_debug "Performing distribution upgrade..."
    if ! sudo apt-get dist-upgrade -y; then
        log_error "Failed to perform distribution upgrade"
        return 1
    fi
    
    # Remove unnecessary packages
    log_debug "Removing unnecessary packages..."
    if ! sudo apt autoremove -y; then
        log_warning "Failed to remove unnecessary packages (non-critical)"
    fi
    
    # Check if reboot is required
    if sudo test -f /var/run/reboot-required; then
        log_success "System packages upgraded successfully"
        prompt_reboot
    else
        log_success "System packages upgraded successfully - no reboot required"
    fi
}

# Main execution
main() {
    print_header "System Package Upgrade"
    
    if upgrade_system_packages; then
        print_footer "Package upgrade completed successfully"
        exit 0
    else
        log_error "Package upgrade failed"
        exit 1
    fi
}

# Run main function
main "$@"
