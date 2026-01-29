#!/usr/bin/env bash
set -euo pipefail

src="$1"
dst="$2"

if [ ! -d "$src" ]; then
  echo "seed-workspace: missing template dir: $src" >&2
  exit 1
fi

mkdir -p "$dst"

rsync -rlt --delete --chmod=Du=rwx,Dgo=rx,Fu=rw,Fgo=r --exclude 'BOOTSTRAP.md' "$src/" "$dst/"

if [ -f "/etc/botctl/tools.md" ]; then
  printf '\n%s\n' "$(cat /etc/botctl/tools.md)" >> "$dst/TOOLS.md"
fi
