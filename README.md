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

- Idempotent and repeatable provisioning
- Easily extensible for your own tools and preferences
- Automated [Fish shell](https://fishshell.com) setup with [fzf](https://github.com/junegunn/fzf), [tide prompt](https://github.com/IlanCosman/tide), [fd](https://github.com/sharkdp/fd), [autopair](https://github.com/jorgebucaran/autopair.fish), [extra themes](https://github.com/mattmc3/themepak.fish) and more!
- Editors: [VSCode](https://code.visualstudio.com), [Cursor](https://cursor.com), [NeoVim](https://neovim.io)
- Installs and configures [Docker](https://www.docker.com), [Node.js](https://nodejs.org) (via [nvm](https://github.com/nvm-sh/nvm)), and other developer tools
- Customizable package and font management
- Dotfile management with [yadm](https://yadm.io)

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
6. **Run**:

   ```sh
   make all
   ```

7. **Reboot** if prompted, then run `make all` again to complete setup

> **Tip:** Ansible is installed and run via [python venv](https://docs.python.org/3/library/venv.html)

---

## Configuration

All settings are managed via Ansible variables. Key files to review:

- **OS Settings**: [`ansible/roles/host_config/vars/main.yml`](ansible/roles/host_config/vars/main.yml)
- **Packages**: [`ansible/roles/manage_packages/vars/main.yml`](ansible/roles/manage_packages/vars/main.yml)
- **Fonts**: [`ansible/roles/nerd_fonts/vars/main.yml`](ansible/roles/nerd_fonts/vars/main.yml)
- **Dotfiles** [`ansible/roles/yadm/vars/main.yml`](ansible/roles/yadm/vars/main.yml)

> **Tip:** At minimum, set your locale, timezone, and hostname in the [Host Config File](ansible/roles/host_config/vars/main.yml).

---

## Troubleshooting

**If the install hangs/fails:**

**Ctrl+C** to terminate the process and run the install again:

   ```sh
   make all
   ```

If you've made changes that are causing errors run ansible-lint

   ```sh
   ./ansible-venv/bin/ansible-lint
   ```

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
