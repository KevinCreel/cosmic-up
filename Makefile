SHELL := /bin/bash
.SHELLFLAGS := -eu -o pipefail -c

# Script paths
UPGRADE_SCRIPT := ./scripts/upgrade_packages.sh
ANSIBLE_SETUP_SCRIPT := ./scripts/setup_ansible.sh
PLAYBOOK_SCRIPT := ./scripts/run_playbook.sh
PLAYBOOK_FILE := ./ansible/playbook.yml

.PHONY: all upgrade ansible run help clean

## Show this help message
help:
	@awk 'BEGIN {FS = ":.*##"; G="\033[0;32m"; N="\033[0m"; printf "\nUsage:\n  make <target>\n\nTargets:\n"} /^[a-zA-Z0-9_-]+:.*##/ {printf "  %s%-12s%s %s\n", G, $$1, N, $$2}' Makefile

## Upgrade system packages
upgrade:        ## Upgrade system packages
	@$(UPGRADE_SCRIPT)

## Set up Ansible and dependencies
ansible:        ## Set up Ansible and dependencies
	@$(ANSIBLE_SETUP_SCRIPT)

## Run the Ansible playbook
run:            ## Run the Ansible playbook
	@$(PLAYBOOK_SCRIPT) $(PLAYBOOK_FILE)

## Run upgrade, ansible, and playbook (default)
all: upgrade ansible run    ## Run upgrade, ansible, and playbook (default)

## Clean up (placeholder)
clean:          ## Clean up (placeholder)
	@echo "Nothing to clean."