#!/bin/bash

set -euxo pipefail

# bump_version.sh
# Prepare for release latest version

SELF_NAME=$(basename "$0")
CACHE_DIR='./cache'
ANYENV_DIR='./anyenv'
PKGBUILD_PATH="$ANYENV_DIR/PKGBUILD"
CACHE_PKGBUILD_PATH="$CACHE_DIR/PKGBUILD"

function DownloadLatestTarball() {
  local TARBALL_MD5

  pushd $CACHE_DIR > /dev/null
  gh release download --repo anyenv/anyenv --archive 'tar.gz'
  popd > /dev/null
}

function GetVersionTarball() {
  local TARBALL_VERSION

  # shellcheck disable=SC2016
  TARBALL_VERSION=$(basename ${CACHE_DIR}/anyenv-*.tar.gz | sed -r 's/anyenv-(.+).tar.gz/\1/')

  echo "$TARBALL_VERSION"
}

function GetMD5Tarball() {
  local TARBALL_MD5
  pushd $CACHE_DIR > /dev/null
  TARBALL_MD5=$(md5sum ./*.tar.gz | cut -b '-32') # md5sum has 32chars
  popd > /dev/null
  echo "$TARBALL_MD5"
}

function GetVersionPKGBUILD() {
  local PKGBUILD_VERSION

  # shellcheck disable=SC1090
  source "$PKGBUILD_PATH"

  # shellcheck disable=SC2154
  PKGBUILD_VERSION="$pkgver"

  echo "$PKGBUILD_VERSION"
}

function GetMD5PKGBUILD() {
  local PKGBUILD_MD5

  # shellcheck disable=SC1090
  source "$PKGBUILD_PATH"

  # shellcheck disable=SC2154
  PKGBUILD_MD5="$md5sums"

  echo "$PKGBUILD_MD5"
}

function EditPKGBUILD() {
  local NEW_VERSION NEW_VERSION_MD5
  NEW_VERSION=$1; shift
  NEW_VERSION_MD5=$1; shift

  # Overwrite version
  sed -r "s/^pkgver=.+$/pkgver=${NEW_VERSION}/" "$PKGBUILD_PATH" > "$CACHE_PKGBUILD_PATH"
  mv "$CACHE_PKGBUILD_PATH" "$PKGBUILD_PATH"

  # Overwrite MD5
  sed -r "s/^md5sums=\(.+\)$/md5sums=('${NEW_VERSION_MD5}')/" "$PKGBUILD_PATH" > "$CACHE_PKGBUILD_PATH"
  mv "$CACHE_PKGBUILD_PATH" "$PKGBUILD_PATH"
}

function CommitBumpingVersion() {
  pushd $ANYENV_DIR > /dev/null
  git add ./PKGBUILD
  git commit -m "Bump Version (v${OLD_VERSION} -> v${NEW_VERSION})"
  popd > /dev/null
}

function CleanUp() {
  rm -rf "$CACHE_DIR"
}

function main() {
  local NEW_VERSION NEW_VERSION_MD5 OLD_VERSION OLD_VERSION_MD5 PROCEED_TO_RELEASE

  # Guard
  if [[ ! -f './scripts/bump_version.sh' ]]; then
    echo "To run ${SELF_NAME}, cd anyenv-aur-maintain-toolchain root directory"
    exit 1
  fi

  # Set up
  CleanUp
  mkdir -p $CACHE_DIR

  # Download latest tarball
  echo '# Start to download anyenv latest tarball'
  DownloadLatestTarball
  NEW_VERSION=$(GetVersionTarball)
  NEW_VERSION_MD5=$(GetMD5Tarball)

  # Get old version info
  OLD_VERSION=$(GetVersionPKGBUILD)
  OLD_VERSION_MD5=$(GetMD5PKGBUILD)

  # Show version info
  echo '================'
  echo 'Release Info'
  echo "Version: '${OLD_VERSION}' -> '${NEW_VERSION}'"
  echo "MD5: '${OLD_VERSION_MD5}' -> '${NEW_VERSION_MD5}'"
  echo '================'
  echo

  if [[ "${OLD_VERSION_MD5}" == "${NEW_VERSION_MD5}" ]]; then
    echo 'No need to release. Bye'
    exit 0
  fi

  read -rp 'Proceed to bump version? (y/n)' PROCEED_TO_RELEASE
  if [[ "$PROCEED_TO_RELEASE" != 'y' ]]; then
    echo 'Aborted'
    exit 0
  fi

  # Edit PKGBUILD
  EditPKGBUILD "$NEW_VERSION" "$NEW_VERSION_MD5"
  CommitBumpingVersion "$OLD_VERSION" "$NEW_VERSION"

  # Clean Up
  CleanUp

  # shellcheck disable=SC2016
  echo 'Done! If you want to release this version, run `git push origin HEAD`'
}

main "$@"
