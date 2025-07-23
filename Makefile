SHELL := /bin/bash
.SHELLFLAGS := -eu -o pipefail -c

# Script paths
UPGRADE_SCRIPT := ./scripts/upgrade_packages.sh
ANSIBLE_SETUP_SCRIPT := ./scripts/setup_ansible.sh
PLAYBOOK_SCRIPT := ./scripts/run_playbook.sh
PLAYBOOK_FILE := ./ansible/playbook.yml

.PHONY: setup upgrade-packages ansible-setup playbook help clean clean-venv tags

setup: upgrade-packages ansible-setup apply-playbook clean ## Run full setup (upgrade, ansible, playbook)
upgrade-packages:        ## Upgrade system packages
	@$(UPGRADE_SCRIPT)
ansible-setup:         ## Set up Ansible and dependencies
	@$(ANSIBLE_SETUP_SCRIPT)
playbook:            ## Run the Ansible playbook (use EXTRA_ARGS to pass options, e.g. EXTRA_ARGS="--tags fish_shell")
	@$(PLAYBOOK_SCRIPT) $(PLAYBOOK_FILE) $(EXTRA_ARGS)
help:                    ## Show this help message
	@awk 'BEGIN {FS = ":.*##"; G="\033[0;32m"; N="\033[0m"; printf "\nUsage:\n  make <target> [EXTRA_ARGS=\"--tags <tag1,tag2>\"]\n\nTargets:\n"} /^[a-zA-Z0-9_-]+:.*##/ {printf "  %s%-18s%s %s\n", G, $$1, N, $$2}' Makefile
	@printf "\n"
	@printf "Examples:\n"
	@printf "  \033[0;32mmake\033[0m                                              \033[0;33m# Run full setup\033[0m\n"
	@printf "  \033[0;32mmake playbook\033[0m                                     \033[0;33m# Run all roles (no tags)\033[0m\n"
	@printf "  \033[0;32mmake playbook EXTRA_ARGS=\"--tags fish_shell\"\033[0m      \033[0;33m# Run only the fish_shell role\033[0m\n"
	@printf "  \033[0;32mmake playbook EXTRA_ARGS=\"--tags ufw,github_cli\"\033[0m  \033[0;33m# Run only ufw and github_cli roles\033[0m\n"
clean:                   ## Clean up temporary files and Ansible artifacts
	@printf "\n"
	@printf "Cleaning up temporary files and Ansible artifacts...\n"
	@rm -rf /tmp/cosmic-up 2>/dev/null || true
	@rm -f *.log 2>/dev/null || true
	@rm -f ansible/*.retry 2>/dev/null || true
	@rm -f ansible/hosts.ini.tmp 2>/dev/null || true
	@rm -rf ~/.ansible 2>/dev/null || true
	@printf "Cleanup complete.\n"
	@printf "\n"
	@printf "\033[1;33m********************************************************************************\033[0m\n"
	@printf "\033[1;33mPlease log out and log back in, or reboot, for some changes to take effect.\033[0m\n"
	@printf "\033[1;33m********************************************************************************\033[0m\n"
clean-venv:                   ## Clean up virtual environment
	@printf "Cleaning up virtual environment...\n"
	@rm -rf ansible-venv 2>/dev/null || true
	@printf "Cleanup complete.\n"
tags:        ## List all available Ansible tags in the playbook (just the tags)
	@$(PLAYBOOK_SCRIPT) $(PLAYBOOK_FILE) --list-tags | \
	grep 'TASK TAGS:' | \
	sed -E 's/.*TASK TAGS: \[(.*)\]/\1/' | \
	tr ',' '\n' | \
	sed 's/^[[:space:]]*//;s/[[:space:]]*$$//' | \
	sort -u	