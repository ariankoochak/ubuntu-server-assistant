# Ubuntu Server Assistant — Installer Catalog

This repository contains focused Ubuntu server setup installers.
Pick what you need, open its guide, and follow the **3-line quick start**.
Tested on **Ubuntu 22.04 / 24.04**.

---

## Available Installers

* **Powerlevel10k (Zsh + Oh My Zsh + p10k) — system-wide**
  Guide: [Powerlevel10k/README.md](./Powerlevel10k/README.md)

* **Node.js LTS via NVM — system-wide for all users (now & future)**
  Guide: [Node/README.md](./Node/README.md)

---

## How to use this repo

1. Open the guide for the installer you want.
2. Copy and run the 3 quick-start commands from that guide.
3. Re-login or open a new shell if the guide says so.

---

## Notes

* Run installers **as root** (`sudo`) when they change system paths or `/etc/*`.
* Scripts are designed to be safe on **fresh** or **existing** servers.
* For update/uninstall details, use the README inside each installer folder.
