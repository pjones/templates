#!/usr/bin/env bash

################################################################################
set -eu
set -o pipefail

################################################################################
top=$(realpath --relative-to="$(pwd)" "$(dirname "$0")")

################################################################################
source "$(dirname "${BASH_SOURCE[0]}")/../lib.sh"

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

  create_envrc_file "$top"

  while IFS= read -r -d "" file; do
    link_file "$file"
  done < <(find "$top" -type f -name "dot.*" -print0)

  while IFS= read -r -d "" file; do
    link_file "$file"
  done < <(find "$top/../cmake" -type f -name "dot.*" -print0)
}

################################################################################
main "$@"
