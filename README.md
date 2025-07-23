# Cosmic Up

A robust, automated starting point for a [Cosmic](https://system76.com/cosmic) based development environment.

---

## Overview

**Cosmic Up** leverages [Ansible](https://docs.ansible.com) to automate the setup of a full-featured, customizable development environment on [Cosmic](https://system76.com/cosmic).

Whether you're:

- New to configuring development environments
- Exploring automation for your setup
- Curious about using Cosmic as your daily driver
- Tired of breakages from manual tweaks

**Cosmic Up** helps you get up and running quickly, reliably, and repeatably.

![Screenshot](https://u.cubeupload.com/kevincreel31337/Screenshot2025071512.png "Screen Shot")

---

## Features

- Safe, repeatable provisioning (run `make` any time)
- Automated system upgrades before provisioning
- Easily extensible and configurable
- Automated [Fish shell](https://fishshell.com) customization with plugins, themes, and productivity tools
- Support for local LLMs ([Ollama](https://ollama.com/), [Open WebUI](https://docs.openwebui.com/))
- Pre-configured developer tools: [VSCode](https://code.visualstudio.com), [Cursor](https://cursor.com), [NeoVim](https://neovim.io), [Docker](https://www.docker.com), [Node.js](https://nodejs.org) (via [nvm](https://github.com/nvm-sh/nvm)), and more
- Dotfile bootstrapping with [yadm](https://yadm.io)

---

## ⚠️ Prerequisites & Warnings

- This project is intended for a **fresh installation** of [Cosmic](https://system76.com/cosmic)
- Tested on **Cosmic Epoch 1 (alpha 7) / Pop!_OS 24.04 LTS alpha**
- **sudo** access is required

---

## Quick Start
>
> **Tip:** Be patient! Installing/updating packages/apps takes time! (15+ minutes). Go grab a coffee. ☕

1. **Fork this repository** to your own GitHub account
2. **Create a VM** (e.g., with [VirtualBox](https://www.virtualbox.org/)) using the [Cosmic ISO](https://system76.com/cosmic).
3. **Customize**: Edit Ansible variables to suit your preferences (see below)
4. **Commit your changes**: Commit your changes and push to your fork
5. **Clone your fork** onto your fresh Cosmic install
6. **Run the full setup:**

   ```sh
   make
   ```

   This will:
   - Upgrade system packages
   - Set up Ansible in a Python virtual environment
   - Run the Ansible playbook to configure your system

7. **Reboot** if prompted (the upgrade step may require it). After rebooting, run:

   ```sh
   make
   ```

   again to complete the setup.

> **Tip:** Use `make help` to see all available commands and what they do.

### Main Makefile Targets

- `make provision` – Full setup: upgrade, ansible, playbook (recommended)
- `make upgrade` – Upgrade system packages only
- `make ansible` – Set up Ansible and dependencies only
- `make run` – Run the Ansible playbook only
- `make clean` – Clean up temporary files and Ansible artifacts
- `make clean-venv` – Remove the Ansible Python virtual environment
- `make help` – Show all available targets and descriptions

---

## Configuration

All settings are managed via Ansible variables, allowing you to fully customize your setup. The most important file is:

- [`ansible/group_vars/all.yml`](ansible/group_vars/all.yml): **Enable or disable major features and roles.**

Other key files for fine-tuning:

- **OS Settings:** [`ansible/roles/host_config/vars/main.yml`](ansible/roles/host_config/vars/main.yml)
- **Packages:** [`ansible/roles/manage_packages/vars/main.yml`](ansible/roles/manage_packages/vars/main.yml)
- **Fonts:** [`ansible/roles/nerd_fonts/vars/main.yml`](ansible/roles/nerd_fonts/vars/main.yml)
- **Dotfiles:** [`ansible/roles/yadm/vars/main.yml`](ansible/roles/yadm/vars/main.yml)

> **Tip:** At minimum, set your locale, timezone, and hostname in the [Host Config File](ansible/roles/host_config/vars/main.yml).

### Enabling/Disabling Features

You can quickly turn features on or off by editing the variables in `ansible/group_vars/all.yml`.  
Set each feature to `true` (enable) or `false` (disable):

```yaml
# ansible/group_vars/all.yml

enable_docker: true      # Install and configure Docker
enable_nerd_fonts: false # Skip Nerd Fonts installation
enable_ollama: true      # Install Ollama and Open WebUI
```

This makes your setup highly customizable—just edit `all.yml` before running `make`.

---

## Troubleshooting

If you run into issues during setup, try the following steps:

### Common Issues & Solutions

- **Install hangs or fails:**
  - Press `Ctrl+C` to terminate the process.
  - Re-run the setup with:

    ```sh
    make
    ```

  - If prompted for a reboot, reboot your system and run `make` again.

- **Ansible errors or playbook failures:**
  - Check the error message in your terminal for details.
  - Run the linter to check for common issues:

    ```sh
    ./ansible-venv/bin/ansible-lint
    ```

  - Make sure your Ansible variables are valid YAML and all required variables are set.

- **Missing dependencies or command not found:**
  - Ensure you are not running as root (do not use `sudo make`).

- **Permission errors:**
  - The scripts should be run as your normal user (not root).
  - If you see permission denied errors, check file permissions and try again.

- **Reboot required:**
  - If the upgrade step prompts for a reboot, reboot your system and then re-run `make` to continue.

## Authors

- [Kevin Creel](https://github.com/Kevincreel)

---

## License

This project is licensed under the [WTFPL](LICENSE.md).

---

## Acknowledgments

Thanks to the System76 Cosmic/Pop!_OS team, the Ansible community, package maintainers, and everyone contributing to open source! 🙏💪

Special thanks for inspiration and code snippets:

- [Jeff Geerling's mac-dev-playbook](https://github.com/geerlingguy/mac-dev-playbook)
