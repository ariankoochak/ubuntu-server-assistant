# Node.js LTS Installer (System-wide via NVM)

Install **Node.js LTS** system-wide on Ubuntu using **NVM** in `/usr/local/nvm`, with binaries exposed in `/usr/local/bin` for all current and future users.
Tested on **Ubuntu 22.04 / 24.04**.

---

## Quick Start

### 1) Download the installer
```bash
curl -fsSL https://raw.githubusercontent.com/ariankoochak/ubuntu-server-assistant/main/Node/node-setup.sh -o node-setup.sh
```
### 2) Make it executable
```bash
chmod +x node-setup.sh
```
### 3) Run as root
```bash
sudo ./node-setup.sh
```

---

## What it does

* Installs prerequisites: `bash`, `curl`, `ca-certificates`, `git`
* Installs **NVM** to `/usr/local/nvm` (shared)
* Installs **Node.js LTS** and sets it as **default**
* Symlinks binaries to `/usr/local/bin` so they are available to everyone
* Loads NVM for all users via `/etc/profile.d/nvm.sh`

---

## Update Later (example)

```bash
sudo bash -lc 'export NVM_DIR=/usr/local/nvm; . $NVM_DIR/nvm.sh; \
  nvm install --lts; nvm alias default lts/*; \
  v=$(nvm version default); for b in node npm npx corepack; do \
  ln -sf "$NVM_DIR/versions/node/$v/bin/$b" "/usr/local/bin/$b"; done'
```

---

## Notes & Requirements

* Run installer **as root** (use `sudo`) because it modifies system paths and `/etc/*`.
* After installation, **open a new shell** (or re-login) so profile changes apply.
* Re-running the script is safe for partial installs.

---

## Uninstall / Revert (quick pointers)

* Remove `/usr/local/nvm`
* Delete `/etc/profile.d/nvm.sh`
* Unlink `/usr/local/bin/node`, `/usr/local/bin/npm`, `/usr/local/bin/npx`, `/usr/local/bin/corepack`

---

## Troubleshooting

* **Command not found after install**: open a new login shell or run `source /etc/profile`.
* **Proxy/corporate network**: export `http_proxy`/`https_proxy` before running the installer.
* **Partial installs**: re-run the script; it skips already completed steps.
