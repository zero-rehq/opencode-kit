#!/usr/bin/env bash
set -euo pipefail

oc_realpath() {
  if command -v realpath >/dev/null 2>&1; then
    realpath "$1"
    return 0
  fi
  if command -v readlink >/dev/null 2>&1; then
    readlink -f "$1" 2>/dev/null && return 0
  fi
  python3 - <<'PY' "$1"
import os, sys
print(os.path.realpath(sys.argv[1]))
PY
}

oc_paths() {
  local src script_dir kit_root workspace_root
  src="$(oc_realpath "${BASH_SOURCE[0]}")"
  script_dir="$(cd "$(dirname "$src")" && pwd)"
  kit_root="$(cd "$script_dir/.." && pwd)"
  workspace_root="$(cd "$kit_root/.." && pwd)"
  echo "$script_dir|$kit_root|$workspace_root"
}
