#!/usr/bin/env bash

set -euo pipefail

# Default values
ansible_venv=${ansible_venv:-"ansible-venv"}
REQUIRED_PACKAGES="software-properties-common python3-venv"
PYTHON_PACKAGES="ansible ansible-lint pipx"

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

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

# Help function
show_help() {
    cat << EOF
Usage: $(basename "$0") [OPTIONS]

Setup Ansible in a Python virtual environment.

OPTIONS:
    -v, --venv PATH     Virtual environment path (default: ansible-venv)
    -h, --help          Show this help message
    -f, --force         Force recreation of virtual environment

ENVIRONMENT VARIABLES:
    ansible_venv        Virtual environment path (default: ansible-venv)

EXAMPLES:
    $(basename "$0")                    # Use default venv path
    $(basename "$0") -v my-ansible-env  # Use custom venv path
    $(basename "$0") -f                 # Force recreation
EOF
}

# Parse command line arguments
parse_args() {
    local force_recreate=false
    
    while [[ $# -gt 0 ]]; do
        case $1 in
            -v|--venv)
                ansible_venv="$2"
                shift 2
                ;;
            -f|--force)
                force_recreate=true
                shift
                ;;
            -h|--help)
                show_help
                exit 0
                ;;
            *)
                log_error "Unknown option: $1"
                show_help
                exit 1
                ;;
        esac
    done
    
    # Handle force recreation
    if [[ "$force_recreate" == "true" && -d "$ansible_venv" ]]; then
        log_warning "Force flag specified, removing existing virtual environment: $ansible_venv"
        rm -rf "$ansible_venv"
    fi
}

# Check if running as root
check_not_root() {
    if [[ $EUID -eq 0 ]]; then
        log_error "This script should not be run as root"
        exit 1
    fi
}

# Check system requirements
check_system_requirements() {
    log_info "Checking system requirements..."
    
    # Check if we're on a supported system
    if [[ ! -f /etc/debian_version ]]; then
        log_warning "This script is designed for Debian/Ubuntu systems"
        log_warning "Package installation may fail on other distributions"
    fi
    
    # Check for required commands
    local missing_commands=()
    for cmd in python3 sudo; do
        if ! command -v "$cmd" &> /dev/null; then
            missing_commands+=("$cmd")
        fi
    done
    
    if [[ ${#missing_commands[@]} -gt 0 ]]; then
        log_error "Missing required commands: ${missing_commands[*]}"
        exit 1
    fi
    
    # Check Python version
    local python_version
    python_version=$(python3 --version 2>&1 | cut -d' ' -f2 | cut -d'.' -f1,2)
    if [[ ! "$python_version" =~ ^3\.[6-9]|^3\.[1-9][0-9] ]]; then
        log_warning "Python 3.6+ is recommended. Found: $python_version"
    fi
}

# Install system packages
install_system_packages() {
    log_info "Checking for required system packages: $REQUIRED_PACKAGES"
    
    local missing_packages=()
    for pkg in $REQUIRED_PACKAGES; do
        if ! dpkg -s "$pkg" >/dev/null 2>&1; then
            missing_packages+=("$pkg")
        fi
    done
    
    if [[ ${#missing_packages[@]} -gt 0 ]]; then
        log_info "Installing missing packages: ${missing_packages[*]}"
        sudo apt-get update -qqy
        sudo apt-get install -y "${missing_packages[@]}"
        log_info "System packages installed successfully"
    else
        log_info "All required system packages are already installed"
    fi
}

# Create and setup virtual environment
setup_ansible_venv() {
    log_info "Setting up Ansible virtual environment: $ansible_venv"
    
    if [[ -s "${ansible_venv}/bin/activate" ]]; then
        log_info "Virtual environment already exists"
        return 0
    fi
    
    log_info "Creating new virtual environment"
    if ! python3 -m venv "$ansible_venv"; then
        log_error "Failed to create virtual environment"
        exit 1
    fi
    
    log_info "Activating virtual environment and installing packages"
    # shellcheck disable=SC1090
    source "${ansible_venv}/bin/activate"
    
    # Upgrade pip first
    log_info "Upgrading pip"
    python3 -m pip install --upgrade pip
    
    # Install wheel first (required for some packages)
    log_info "Installing wheel"
    python3 -m pip install wheel
    
    # Install Python packages
    log_info "Installing Python packages: $PYTHON_PACKAGES"
    if ! python3 -m pip install $PYTHON_PACKAGES; then
        log_error "Failed to install Python packages"
        exit 1
    fi
    
    # Verify installation
    log_info "Verifying Ansible installation"
    if ! ansible --version &>/dev/null; then
        log_error "Ansible installation verification failed"
        exit 1
    fi
    
    deactivate
    log_info "Virtual environment setup completed successfully"
}

# Main function
main() {
    log_info "Starting Ansible setup script"
    
    parse_args "$@"
    check_not_root
    check_system_requirements
    install_system_packages
    setup_ansible_venv
    
    log_info "Setup complete! To activate the environment, run:"
    log_info "source ${ansible_venv}/bin/activate"
}

# Run main function with all arguments
main "$@"
