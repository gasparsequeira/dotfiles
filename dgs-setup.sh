#!/usr/bin/env bash
#
# pentest-setup.sh
# Installs a pentest toolset on an Arch box that ALREADY has the BlackArch
# repo strapped, plus a local, legal practice target (OWASP Juice Shop).
#
# Run it (NOT as root):
#   curl -fsSL https://raw.githubusercontent.com/gasparsequeira/dotfiles/main/pentest-setup.sh | bash
# or:
#   bash pentest-setup.sh
#
# Requires bash (uses arrays). BlackArch must be strapped first:
#   curl -O https://blackarch.org/strap.sh && sudo sh strap.sh
#
set -euo pipefail

msg()  { printf '\n\033[1;32m>>> %s\033[0m\n' "$1"; }
warn() { printf '\n\033[1;33m!!! %s\033[0m\n' "$1"; }

# --- sanity checks --------------------------------------------------------
if [ "$(id -u)" -eq 0 ]; then
  warn "Run this as your normal user, not root — it calls sudo when needed."
  exit 1
fi

if ! grep -q '^\[blackarch\]' /etc/pacman.conf; then
  warn "BlackArch repo not found in /etc/pacman.conf."
  warn "Strap it first:  curl -O https://blackarch.org/strap.sh && sudo sh strap.sh && sudo pacman -Syu"
  exit 1
fi

# --- toolset --------------------------------------------------------------
pkgs=(
  # recon / network
  nmap masscan rustscan openbsd-netcat tcpdump wireshark-qt
  # web
  sqlmap nikto gobuster ffuf whatweb wpscan burpsuite
  # passwords / wordlists
  john hashcat hydra hashid seclists
  # exploitation / wireless / enumeration
  metasploit aircrack-ng wifite reaver enum4linux smbclient impacket
  # local lab
  docker
)

msg "Updating the system..."
sudo pacman -Syu --noconfirm

msg "Installing ${#pkgs[@]} packages (tools + docker)..."
sudo pacman -S --needed --noconfirm "${pkgs[@]}"

# --- post-install setup ---------------------------------------------------
msg "Adding $USER to the 'wireshark' group (non-root packet capture)..."
sudo usermod -aG wireshark "$USER"

msg "Initialising the Metasploit database..."
sudo systemctl enable --now postgresql
sudo msfdb init || warn "msfdb init hit a snag — re-run 'sudo msfdb init' later if needed."

msg "Enabling Docker and adding $USER to the 'docker' group..."
sudo systemctl enable --now docker
sudo usermod -aG docker "$USER"

# --- legal practice target ------------------------------------------------
msg "Starting OWASP Juice Shop on http://localhost:3000 (auto-restarts on boot)..."
if sudo docker ps -a --format '{{.Names}}' | grep -qx juiceshop; then
  sudo docker start juiceshop
else
  sudo docker run -d --name juiceshop --restart unless-stopped -p 3000:3000 bkimminich/juice-shop
fi

# --- done -----------------------------------------------------------------
msg "All done."
cat <<'EOF'

  Next steps:
    1. LOG OUT and back in  (so the wireshark + docker groups apply).
    2. Open your browser at  http://localhost:3000   <- your legal target.
    3. First exploit to try — SQLi login bypass:
         email:    ' OR 1=1--
         password: anything

  Reminder: only ever attack localhost / containers you own, or a host you
  have WRITTEN authorisation to test. Everything here stays on this machine.
EOF
