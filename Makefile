SHELL := /bin/bash
.SHELLFLAGS := -eu -o pipefail -c

# Script paths
UPGRADE_SCRIPT := ./scripts/upgrade_packages.sh
ANSIBLE_SETUP_SCRIPT := ./scripts/setup_ansible.sh
PLAYBOOK_SCRIPT := ./scripts/run_playbook.sh
PLAYBOOK_FILE := ./ansible/playbook.yml

.PHONY: provision upgrade ansible run help clean clean-venv

provision: upgrade ansible run clean ## Run full setup (upgrade, ansible, playbook)
upgrade:        ## Upgrade system packages	
	@$(UPGRADE_SCRIPT)
ansible:         ## Set up Ansible and dependencies
	@$(ANSIBLE_SETUP_SCRIPT)
run:            ## Run the Ansible playbook
	@$(PLAYBOOK_SCRIPT) $(PLAYBOOK_FILE)
help:                    ## Show this help message
	@awk 'BEGIN {FS = ":.*##"; G="\033[0;32m"; N="\033[0m"; printf "\nUsage:\n  make <target>\n\nTargets:\n"} /^[a-zA-Z0-9_-]+:.*##/ {printf "  %s%-12s%s %s\n", G, $$1, N, $$2}' Makefile
clean:                   ## Clean up temporary files and Ansible artifacts
	@echo "Cleaning up temporary files and Ansible artifacts..."
	@rm -rf /tmp/cosmic-up 2>/dev/null || true
	@rm -f *.log 2>/dev/null || true
	@rm -f ansible/*.retry 2>/dev/null || true
	@rm -f ansible/hosts.ini.tmp 2>/dev/null || true
	@rm -rf ~/.ansible 2>/dev/null || true
	@echo "Cleanup complete."	
clean-venv:                   ## Clean up virtual environment
	@echo "Cleaning up virtual environment..."
	@rm -rf ansible-venv 2>/dev/null || true
	@echo "Cleanup complete."	