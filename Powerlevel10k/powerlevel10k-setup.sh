#!/bin/bash

set -euo pipefail

if [[ $EUID -ne 0 ]]; then
  echo "Please run as root (use: sudo ./powerlevel10k-setup.sh)"
  exit 1
fi

export DEBIAN_FRONTEND=noninteractive
apt-get update -y
apt-get upgrade -y
apt-get install -y git curl unzip build-essential ca-certificates zsh

if ! grep -q '^/usr/bin/zsh$' /etc/shells; then
  echo "/usr/bin/zsh" >> /etc/shells
fi

OMZ_DIR="/usr/share/oh-my-zsh"
if [[ ! -d "$OMZ_DIR" ]]; then
  git clone --depth=1 https://github.com/ohmyzsh/ohmyzsh.git "$OMZ_DIR"
fi

P10K_DIR="$OMZ_DIR/custom/themes/powerlevel10k"
if [[ ! -d "$P10K_DIR" ]]; then
  git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$P10K_DIR"
fi

SKEL_ZSHRC="/etc/skel/.zshrc"
cat > "$SKEL_ZSHRC" <<'EOF'
export ZSH=/usr/share/oh-my-zsh
ZSH_THEME="powerlevel10k/powerlevel10k"
plugins=(git)

source "$ZSH/oh-my-zsh.sh"

[[ -f ~/.p10k.zsh ]] && source ~/.p10k.zsh
EOF
chmod 0644 "$SKEL_ZSHRC"

configure_user() {
  local user="$1" home="$2" shell="$3"

  [[ -d "$home" ]] || return 0

  local zshrc="$home/.zshrc"

  if [[ ! -f "$zshrc" ]]; then
    cp -f "$SKEL_ZSHRC" "$zshrc"
  else
    if grep -q '^export ZSH=' "$zshrc"; then
      sed -i 's|^export ZSH=.*|export ZSH=/usr/share/oh-my-zsh|' "$zshrc"
    else
      printf '\nexport ZSH=/usr/share/oh-my-zsh\n' >> "$zshrc"
    fi

    if grep -q '^ZSH_THEME=' "$zshrc"; then
      sed -i 's|^ZSH_THEME=.*|ZSH_THEME="powerlevel10k/powerlevel10k"|' "$zshrc"
    else
      printf 'ZSH_THEME="powerlevel10k/powerlevel10k"\n' >> "$zshrc"
    fi

    grep -q 'oh-my-zsh.sh' "$zshrc" || printf 'source "$ZSH/oh-my-zsh.sh"\n' >> "$zshrc"
    grep -q '\.p10k\.zsh' "$zshrc" || printf '[[ -f ~/.p10k.zsh ]] && source ~/.p10k.zsh\n' >> "$zshrc"
  fi

  local ug
  ug="$(id -u "$user"):$(id -g "$user")"
  chown "$ug" "$zshrc"

  if [[ "$shell" != "/usr/bin/zsh" ]]; then
    usermod -s /usr/bin/zsh "$user" || true
  fi
}

while IFS=: read -r name _ uid gid gecos home shell; do
  if [[ "$uid" -eq 0 || "$uid" -ge 1000 ]]; then
    if [[ "$shell" != "/usr/sbin/nologin" && "$shell" != "/bin/false" ]]; then
      configure_user "$name" "$home" "$shell"
    fi
  fi
done < <(getent passwd)

echo "✅ Done. Zsh + oh-my-zsh + Powerlevel10k installed system-wide."
echo "ℹ️  Shell defaults changed to zsh; take effect at next login."
echo "➡️  Apply now in current session: run 'exec zsh -l'"
