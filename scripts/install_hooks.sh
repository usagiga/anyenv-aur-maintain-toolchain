#!/bin/bash

set -euo pipefail

# install_hooks.sh
# Install git hooks to ./anyenv

SELF_NAME="$(basename "$0")"

# Guard
if [[ ! -f './scripts/initialize.sh' ]]; then
  echo "To run ${SELF_NAME}, cd anyenv-aur-maintain-toolchain root directory"
  exit 1
fi

if [[ ! -d './anyenv/' ]]; then
  echo "To run ${SELF_NAME}, update submodules"
  exit 1
fi

# Install
echo "# Install git hooks..."
for FILE_PATH in ./hooks/*; do
  FILE_NAME="$(basename "${FILE_PATH}")"

  echo "## Installing ${FILE_NAME}..."
  SRC_PATH="$(realpath "${FILE_PATH}")"
  DST_PATH="$(realpath "./.git/modules/anyenv/hooks")/${FILE_NAME}"
  ln -sf "${SRC_PATH}" "${DST_PATH}"
done
