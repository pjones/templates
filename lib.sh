#!/usr/bin/env bash

################################################################################
function link_file() {
  local src=$1

  ln \
    --symbolic \
    --relative \
    --force \
    --no-dereference \
    --verbose \
    "$src" "$(basename "${src//dot/}")"
}

################################################################################
function create_envrc_file() {
  local top=$1
  local file=".envrc"
  local env_name="default"

  if [ $# -gt 1 ]; then
    env_name=$2
  fi

  if [ ! -e "$file" ]; then
    echo "$file"
    echo "use flake ${top}#${env_name}" >"$file"
  fi
}
