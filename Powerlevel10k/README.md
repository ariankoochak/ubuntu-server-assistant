# Powerlevel10k Installer (Zsh + Oh My Zsh + p10k)

Install **Zsh**, **Oh My Zsh**, and **Powerlevel10k** system-wide on Ubuntu for existing and future users.
Tested on **Ubuntu 22.04 / 24.04**.

---

## Quick Start

### 1) Download the installer
```bash
curl -fsSL https://raw.githubusercontent.com/ariankoochak/ubuntu-server-assistant/main/Powerlevel10k/powerlevel10k-setup.sh -o powerlevel10k-setup.sh
```
### 2) Make it executable
```bash
chmod +x powerlevel10k-setup.sh
```
### 3) Run as root
```bash
sudo ./powerlevel10k-setup.sh
```

---

## What it does

* Installs required packages: `zsh`, `git`, `curl`, `unzip`, `build-essential`, `ca-certificates`
* Deploys **Oh My Zsh** to `/usr/share/oh-my-zsh`
* Deploys **Powerlevel10k** theme globally
* Prepares `/etc/skel/.zshrc` so new users inherit Zsh + p10k config
* Updates eligible existing users and switches their login shell to `zsh`

---

## Notes & Requirements

* Run installer **as root** (use `sudo`) because it modifies system paths and user shells.
* Shell changes take effect on next login.
* To apply immediately in the current session: `exec zsh -l`

---

## Uninstall / Revert (quick pointers)

* Switch a user back to bash:
  `sudo chsh -s /bin/bash <username>`
* Remove global Oh My Zsh and p10k under `/usr/share/oh-my-zsh` if desired
* Clean related defaults from `/etc/skel/.zshrc` if you want to stop applying it to new users

---

## Troubleshooting

* **Theme not loaded**: confirm `.zshrc` contains `ZSH_THEME="powerlevel10k/powerlevel10k"`.
* **No change in current shell**: log out/in or run `exec zsh -l`.
* **Partial installs**: re-run the script; it will skip existing parts.
