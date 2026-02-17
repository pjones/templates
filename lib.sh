#!/usr/bin/env bash

################################################################################
function copy_file() {
  local src=$1

  local dst
  dst="$(basename "${src//dot/}")"

  if [ -e "$dst" ]; then
    echo >&2 "ERROR: file already exists, skipping: ${dst}"
    return
  fi

  cp \
    --archive \
    --verbose \
    "$src" "$dst"
}

################################################################################
function link_file() {
  local src=$1

  local dst
  dst=$(basename "${src//dot/}")

  if [ -e "$dst" ] && [ ! -L "$dst" ]; then
    echo >&2 "ERROR: file already exists and isn't a symlink, skipping: ${dst}"
    return
  fi

  ln \
    --symbolic \
    --relative \
    --force \
    --no-dereference \
    --verbose \
    "$src" "$dst"
}

################################################################################
function create_envrc_file() {
  local top="."
  local file=".envrc"
  local env_name="default"

  if [ $# -gt 0 ]; then
    top=$1
  fi

  if [ $# -gt 1 ]; then
    env_name=$2
  fi

  if [ ! -e "$file" ]; then
    echo "$file"
    echo "use flake ${top}#${env_name}" >"$file"
  fi
}
