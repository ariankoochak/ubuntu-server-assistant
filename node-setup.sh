#!/usr/bin/env bash
# System-wide Node.js (LTS) via NVM for all users on Ubuntu 24.x
# - Installs NVM into /usr/local/nvm (shared)
# - Installs the latest LTS Node.js and sets it as default
# - Exposes node/npm/npx/corepack at /usr/local/bin for all users (including future ones)
# Run as root: sudo bash node-setup.sh

set -euo pipefail
umask 022

if [ "${EUID:-$(id -u)}" -ne 0 ]; then
  echo "Please run this script as root (e.g., 'sudo bash ...')."
  exit 1
fi

export DEBIAN_FRONTEND=noninteractive

echo "[1/6] Installing prerequisites..."
apt update -y
apt install -y bash curl ca-certificates git

NVM_VERSION="v0.39.7"
NVM_DIR="/usr/local/nvm"
PROFILE_D="/etc/profile.d"
NVM_PROFILE="${PROFILE_D}/nvm.sh"

echo "[2/6] Installing NVM to ${NVM_DIR} (shared)..."
if [ -d "${NVM_DIR}/.git" ] || [ -f "${NVM_DIR}/nvm.sh" ]; then
  echo "  NVM already present at ${NVM_DIR}"
else
  mkdir -p "${NVM_DIR}"
  git clone https://github.com/nvm-sh/nvm.git "${NVM_DIR}"
  cd "${NVM_DIR}"
  git checkout "${NVM_VERSION}"
  cd -
fi

echo "[3/6] Creating ${NVM_PROFILE} to load NVM for all users..."
cat > "${NVM_PROFILE}" <<'EOF'
# /etc/profile.d/nvm.sh - make NVM available system-wide
export NVM_DIR="/usr/local/nvm"

# If shell has 'nounset' on, temporarily disable to avoid nvm unbound-var issues
__NVM_RESTORE_NOUNSET=0
if ( set -o | grep -q 'nounset *on' ); then
  set +u
  __NVM_RESTORE_NOUNSET=1
fi

# Load nvm and completion (if present)
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && . "$NVM_DIR/bash_completion"

# Try to activate default Node silently
if command -v nvm >/dev/null 2>&1; then
  nvm use --silent default >/dev/null 2>&1 || true
fi

# Restore nounset if it was originally on
if [ "${__NVM_RESTORE_NOUNSET}" = "1" ]; then
  set -u
fi
unset __NVM_RESTORE_NOUNSET
EOF
chmod 644 "${NVM_PROFILE}"

# Load NVM in this script's environment (with nounset disabled around nvm)
# shellcheck disable=SC1090
set +u
. "${NVM_PROFILE}"
set -u

echo "[4/6] Installing latest LTS Node.js (this may take a moment)..."
# nvm isn't nounset-safe; disable -u around nvm commands
set +u
nvm install --lts
nvm alias default 'lts/*'
nvm use --lts
NODE_VERSION="$(nvm version default)"
set -u

NODE_BIN_DIR="${NVM_DIR}/versions/node/${NODE_VERSION}/bin"

echo "[5/6] Linking Node.js tools for all users in /usr/local/bin ..."
install -d /usr/local/bin
for bin in node npm npx corepack; do
  if [ -x "${NODE_BIN_DIR}/${bin}" ]; then
    ln -sf "${NODE_BIN_DIR}/${bin}" "/usr/local/bin/${bin}"
    echo "  Linked ${bin} -> /usr/local/bin/${bin}"
  fi
done

echo "[6/6] Verifying installation..."
/usr/local/bin/node -v
/usr/local/bin/npm -v || true
/usr/local/bin/npx -v || true
/usr/local/bin/corepack -v || true

cat <<'NOTE'

Done ✅
- NVM installed at: /usr/local/nvm
- Global init script: /etc/profile.d/nvm.sh (affects all current & future users)
- Default Node.js (LTS) is active and symlinked into /usr/local/bin:
    node, npm, npx, corepack

Notes:
- This script temporarily disables 'set -u' around NVM calls to avoid the
  "PROVIDED_VERSION: unbound variable" error in nvm.
- Open a new shell (or re-login) so /etc/profile.d/nvm.sh is loaded.

Update Node globally later (example):
  sudo bash -lc 'export NVM_DIR=/usr/local/nvm; . /etc/profile.d/nvm.sh; \
    set +u; nvm install --lts; nvm alias default lts/*; \
    v=$(nvm version default); set -u; \
    for b in node npm npx corepack; do ln -sf "$NVM_DIR/versions/node/$v/bin/$b" "/usr/local/bin/$b"; done'
NOTE
