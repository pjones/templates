#!/usr/bin/env bash

################################################################################
set -eu
set -o pipefail

################################################################################
top=$(realpath --relative-to="$(pwd)" "$(dirname "$0")")

################################################################################
function usage() {
  cat <<EOF
Usage: $(basename "$0") [options]

  -h      This message


Link development files into the OpenMS repository.

Execute this script while in the root directory of the OpenMS
repository.
EOF
}

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
  local file=".envrc"

  if [ ! -e "$file" ]; then
    echo "$file"
    echo "use flake $top" >"$file"
  fi
}

################################################################################
function main() {
  while getopts "h" o; do
    case "${o}" in
    h)
      usage
      exit
      ;;

    *)
      exit 1
      ;;
    esac
  done

  shift $((OPTIND - 1))

  create_envrc_file

  while IFS= read -r -d "" file; do
    link_file "$file"
  done < <(find "$top" -type f -name "dot.*" -print0)

  while IFS= read -r -d "" file; do
    link_file "$file"
  done < <(find "$top/../cmake" -type f -name "dot.*" -print0)
}

################################################################################
main "$@"
