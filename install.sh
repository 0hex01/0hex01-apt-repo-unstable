#!/bin/bash
# 0hex01 unstable apt repo - one-line setup
#   curl -fsSL https://0hex01.github.io/0hex01-apt-repo-unstable/install.sh | sudo bash
set -euo pipefail

[ "$(id -u)" -eq 0 ] || { echo "run as root: curl ... | sudo bash" >&2; exit 1; }

BASE="https://0hex01.github.io/0hex01-apt-repo-unstable"
LIST="/etc/apt/sources.list.d/0hex01-unstable.list"

rm -f /usr/share/keyrings/0hex01.gpg

echo "deb [arch=amd64 trusted=yes] $BASE unstable main" > "$LIST"

apt update
echo "0hex01 unstable repo added - try: apt search 0hex01"
