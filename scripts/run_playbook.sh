#!/usr/bin/env bash

set -euo pipefail

# Default values
ansible_venv=${ansible_venv:-"ansible-venv"}
requirements_file=${requirements_file:-"./ansible/requirements.yml"}
inventory_file=${inventory_file:-"./ansible/inventory.yml"}

# Color codes - check if colors are supported
if [[ -t 1 ]] && [[ -n "$TERM" ]]; then
    # Colors are supported
    readonly RED='\033[31m'
    readonly GREEN='\033[0;32m'
    readonly YELLOW='\033[33m'
    readonly BLUE='\033[34m'
    readonly MAGENTA='\033[35m'
    readonly CYAN='\033[36m'
    readonly BOLD='\033[1m'
    readonly RESET='\033[0m'
else
    # Colors are not supported
    readonly RED=''
    readonly GREEN=''
    readonly YELLOW=''
    readonly BLUE=''
    readonly MAGENTA=''
    readonly CYAN=''
    readonly BOLD=''
    readonly RESET=''
fi

# Get script directory
SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)
readonly SCRIPT_DIR

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

# Help function
show_help() {
    cat << EOF
Usage: $(basename "$0") [OPTIONS] [PLAYBOOK_ARGS...]

Run Ansible playbook with virtual environment activation.

OPTIONS:
    -h, --help              Show this help message
    -v, --venv PATH         Path to Ansible virtual environment (default: ansible-venv)
    -r, --requirements FILE Path to requirements file (default: ./ansible/requirements.yml)
    -i, --inventory FILE    Path to inventory file (default: ./ansible/inventory.yml)
    --dry-run               Show what would be executed without running
    --skip-deps             Skip installing dependencies

ENVIRONMENT VARIABLES:
    ANSIBLE_VENV            Path to Ansible virtual environment
    REQUIREMENTS_FILE       Path to requirements file
    INVENTORY_FILE          Path to inventory file

EXAMPLES:
    $(basename "$0") ./ansible/playbook.yml
    $(basename "$0") -v custom-venv ./ansible/playbook.yml --tags docker
    $(basename "$0") --dry-run ./ansible/playbook.yml

EOF
}

# Parse command line arguments
parse_args() {
    local dry_run=false
    local skip_deps=false
    
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                show_help
                exit 0
                ;;
            -v|--venv)
                ansible_venv="$2"
                shift 2
                ;;
            -r|--requirements)
                requirements_file="$2"
                shift 2
                ;;
            -i|--inventory)
                inventory_file="$2"
                shift 2
                ;;
            --dry-run)
                dry_run=true
                shift
                ;;
            --skip-deps)
                skip_deps=true
                shift
                ;;
            --)
                shift
                break
                ;;
            -*)
                log_error "Unknown option: $1"
                show_help
                exit 1
                ;;
            *)
                break
                ;;
        esac
    done
    
    # Store remaining arguments for ansible-playbook
    readonly PLAYBOOK_ARGS=("$@")
    readonly DRY_RUN=$dry_run
    readonly SKIP_DEPS=$skip_deps
}

# Validate prerequisites
validate_prerequisites() {
    # Check if virtual environment exists
    if [[ ! -d "$ansible_venv" ]]; then
        log_error "Ansible virtual environment not found at: $ansible_venv"
        log_info "Run './scripts/setup_ansible.sh' to create the virtual environment"
        exit 1
    fi
    
    # Check if requirements file exists
    if [[ ! -f "$requirements_file" ]]; then
        log_warning "Requirements file not found: $requirements_file"
        log_info "Skipping dependency installation"
        SKIP_DEPS=true
    fi
    
    # Check if inventory file exists
    if [[ ! -f "$inventory_file" ]]; then
        log_error "Inventory file not found: $inventory_file"
        exit 1
    fi
    
    # Check if ansible-playbook is available in venv
    if [[ ! -f "$ansible_venv/bin/ansible-playbook" ]]; then
        log_error "ansible-playbook not found in virtual environment: $ansible_venv"
        log_info "Run './scripts/setup_ansible.sh' to install Ansible"
        exit 1
    fi
}

# Install dependencies
install_dependencies() {
    if [[ "$SKIP_DEPS" == "true" ]]; then
        log_info "Skipping dependency installation (--skip-deps flag used)"
        return 0
    fi
    
    if [[ -s "$requirements_file" ]]; then
        log_info "Installing required Ansible roles and collections from: $requirements_file"
        
        # Install collections
        if grep -q "collections:" "$requirements_file"; then
            log_info "Installing Ansible collections..."
            if [[ "$DRY_RUN" == "true" ]]; then
                echo "ansible-galaxy collection install -r $requirements_file"
            else
                # Use the ansible-galaxy from the virtual environment
                "$ansible_venv/bin/ansible-galaxy" collection install -r "$requirements_file" || {
                    log_error "Failed to install Ansible collections"
                    return 1
                }
            fi
        fi
        
        # Install roles
        if grep -q "roles:" "$requirements_file"; then
            log_info "Installing Ansible roles..."
            if [[ "$DRY_RUN" == "true" ]]; then
                echo "ansible-galaxy install -r $requirements_file"
            else
                # Use the ansible-galaxy from the virtual environment
                "$ansible_venv/bin/ansible-galaxy" install -r "$requirements_file" || {
                    log_error "Failed to install Ansible roles"
                    return 1
                }
            fi
        fi
    else
        log_info "Requirements file is empty or doesn't contain dependencies"
    fi
}

# Run the playbook
run_playbook() {
    local venv_activate="$ansible_venv/bin/activate"
    
    if [[ "$DRY_RUN" == "true" ]]; then
        log_info "DRY RUN - Would execute:"
        echo "source $venv_activate"
        echo "ansible-playbook -i $inventory_file ${PLAYBOOK_ARGS[*]}"
        echo "deactivate"
        return 0
    fi
    
    log_info "Activating Ansible virtual environment: $ansible_venv"
    
    # Use a subshell to avoid affecting the parent environment
    (
        set -e
        source "$venv_activate"
        
        log_info "Running Ansible playbook with inventory: $inventory_file"
        log_info "Arguments: ${PLAYBOOK_ARGS[*]:-<none>}"
        
        ansible-playbook -i "$inventory_file" "${PLAYBOOK_ARGS[@]}" || {
            log_error "Ansible playbook execution failed"
            exit 1
        }
        
        log_info "Ansible playbook completed successfully"
    )
}

# Main execution
main() {
    log_info "Starting Ansible playbook execution"
    
    # Parse arguments
    parse_args "$@"
    
    # Validate prerequisites
    validate_prerequisites
    
    # Install dependencies
    install_dependencies
    
    # Run the playbook
    run_playbook
    
    log_info "Script completed successfully"
}

# Run main function with all arguments
main "$@"
