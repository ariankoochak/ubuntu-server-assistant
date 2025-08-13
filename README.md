# powerlevel10k-installation

This repository provides an **easy, system-wide installation** of:
- **Zsh**
- **Oh My Zsh**
- **Powerlevel10k theme**

It sets Powerlevel10k as the default shell theme **for all existing and future users** on the system.

---

## 📋 Features
- Installs required packages: `zsh`, `git`, `curl`, etc.
- Installs **Oh My Zsh** and **Powerlevel10k** in `/usr/share` (system-wide)
- Updates `/etc/skel` so new users automatically get the theme
- Changes default shell to `zsh` for all users with login shells

---

## 🚀 Quick Start

Run these commands on your server:

```bash
# 1. Download the script
curl -fsSL https://raw.githubusercontent.com/ariankoochak/powerlevel10k-installation/main/setup.sh -o setup.sh

# 2. Make it executable
chmod +x setup.sh

# 3. Run as root
sudo ./setup.sh
```