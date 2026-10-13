#!/usr/bin/env bash
# Create a new project from templates/project.
#   scripts/new_project.sh p02_uart uart_top
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
name="${1:-}"; top="${2:-}"

if [[ -z "$name" || -z "$top" ]]; then
  echo "usage: $0 <pNN_name> <rtl_top_module>" >&2; exit 2
fi
if [[ ! "$name" =~ ^p[0-9]{2}_[a-z0-9_]+$ ]]; then
  echo "project name must look like p02_uart (pNN_lower_snake)" >&2; exit 2
fi
if [[ ! "$top" =~ ^[a-z][a-z0-9_]*$ ]]; then
  echo "top module must be lower_snake_case" >&2; exit 2
fi

dest="$REPO_ROOT/projects/$name"
[[ -e "$dest" ]] && { echo "$dest already exists" >&2; exit 1; }

cp -r "$REPO_ROOT/templates/project" "$dest"
mv "$dest/rtl/TOP.sv" "$dest/rtl/$top.sv"
mv "$dest/tb/test_TOP.py" "$dest/tb/test_$top.py"
grep -rl --null '__TOP__\|__NAME__' "$dest" | xargs -0 sed -i "s/__TOP__/$top/g; s/__NAME__/$name/g"
touch "$dest/.wip"

echo "Created projects/$name (marked .wip -- excluded from regression until you delete .wip)"
echo "Next: write the spec in projects/$name/README.md, then TESTPLAN.md, before any RTL."
