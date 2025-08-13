# Ubuntu Server Assistant — Quick Installers

Pick what you want to set up on your server and run the corresponding **3-line** quick start.
Tested on **Ubuntu 22.04 / 24.04**.

* [Powerlevel10k (Zsh + Oh My Zsh + p10k) — system-wide](#powerlevel10k-system-wide)
* [Node.js LTS via NVM — system-wide for all users (now & future)](#nodejs-lts-system-wide)

---

## Powerlevel10k (system-wide)

Installs **Zsh**, **Oh My Zsh**, and **Powerlevel10k** globally; sets p10k as the default theme for all existing and future users.

```bash
# 1) Download the installer
curl -fsSL https://raw.githubusercontent.com/ariankoochak/ubuntu-server-assistant/main/powerlevel10k-setup.sh -o powerlevel10k-setup.sh

# 2) Make it executable
chmod +x powerlevel10k-setup.sh

# 3) Run as root
sudo ./powerlevel10k-setup.sh
```

**What it does**

* Installs `zsh`, `git`, `curl` (if missing)
* Deploys **Oh My Zsh** + **Powerlevel10k** to `/usr/share`
* Updates `/etc/skel` so new users inherit Zsh + p10k
* Switches login shells of current users to `zsh` (safe defaults)

---

## Node.js LTS (system-wide)

Installs **NVM** in `/usr/local/nvm`, installs the **latest LTS Node.js**, and exposes `node`, `npm`, `npx`, `corepack` via `/usr/local/bin` for **all users**, including users created later.

```bash
# 1) Download the installer
curl -fsSL https://raw.githubusercontent.com/ariankoochak/ubuntu-server-assistant/main/node-setup.sh -o node-setup.sh

# 2) Make it executable
chmod +x node-setup.sh

# 3) Run as root
sudo ./node-setup.sh
```

**What it does**

* Installs prerequisites: `bash`, `curl`, `ca-certificates`, `git`
* Installs **NVM** to `/usr/local/nvm` (shared)
* Installs **Node.js LTS** and sets it as **default**
* Symlinks binaries to `/usr/local/bin` → available to everyone
* Loads NVM for all users via `/etc/profile.d/nvm.sh`

**Update later (example)**

```bash
# Switch global default to a new version (e.g., Node 22 or 20)
sudo bash -lc 'export NVM_DIR=/usr/local/nvm; . $NVM_DIR/nvm.sh; \
  nvm install --lts; nvm alias default lts/*; \
  v=$(nvm version default); for b in node npm npx corepack; do \
  ln -sf "$NVM_DIR/versions/node/$v/bin/$b" "/usr/local/bin/$b"; done'
```

---

## Notes & Requirements

* Run installers **as root** (use `sudo`) when they modify system paths or `/etc/*`.
* These scripts are designed to be safe on **fresh** or **existing** servers.
* After installation, **open a new shell** (or re-login) so `/etc/profile.d/*.sh` changes apply.

## Uninstall / Revert (quick pointers)

* **Powerlevel10k/Zsh**: switch a user back to bash:
  `sudo chsh -s /bin/bash <username>`
  Remove global Oh My Zsh/p10k from `/usr/share` and clean `/etc/skel` if desired.
* **Node.js via NVM**: remove `/usr/local/nvm`, delete `/etc/profile.d/nvm.sh`, and unlink symlinks in `/usr/local/bin` (`node`, `npm`, `npx`, `corepack`).

---

## Troubleshooting

* **Command not found after install**: start a new login shell or `source /etc/profile`.
* **Proxy/corporate network**: export `http_proxy`/`https_proxy` before running installers.
* **Partial installs**: re-run the script; it will skip already completed steps.

---
