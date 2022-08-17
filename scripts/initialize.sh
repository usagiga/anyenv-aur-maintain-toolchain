#!/bin/bash

set -euo pipefail

# initialize.sh
# Scaffold for anyenv AUR package maintainer
# - Install development dependencies
#   - base-devel
#   - namcap
#   - git
# - Initialize submodules
#   - anyenv on AUR
# - Initialize git hooks for anyenv

SELF_NAME=$(basename $0)

# Guard
if [[ ! -f './scripts/initialize.sh' ]]; then
  echo "To run ${SELF_NAME}, cd anyenv-aur root directory"
  exit 1
fi

# Initialize
## Install dev dependencies
echo "# Install dev dependencies..."
sudo pacman -S base-devel namcap git

## Setup submodule
echo "# Setup submodules..."
git submodule update --init --recursive

## Install git hooks
echo "# Install git hooks..."
bash ./scripts/install_hooks.sh

echo "Done!"
