#!/usr/bin/env bash
# -----------------------------------------------------------------------------
# One-shot environment setup for chip-lab on WSL2 Ubuntu 24.04.
#
#   ./scripts/setup_wsl.sh                       # apt tools + Python venv
#   ./scripts/setup_wsl.sh --verilator-source    # also build a newer Verilator
#
# Idempotent: safe to re-run.
# -----------------------------------------------------------------------------
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
VERILATOR_TAG="v5.044"   # cocotb 2.x needs >= 5.036; Ubuntu 24.04 ships 5.020
BUILD_VERILATOR=0

for arg in "$@"; do
  case "$arg" in
    --verilator-source) BUILD_VERILATOR=1 ;;
    -h|--help) sed -n '2,10p' "$0"; exit 0 ;;
    *) echo "unknown option: $arg" >&2; exit 2 ;;
  esac
done

log() { printf '\n\033[1;34m==> %s\033[0m\n' "$*"; }

# --- 0. Sanity checks ---------------------------------------------------------
if [[ "$(pwd -P)" == /mnt/* || "$REPO_ROOT" == /mnt/* ]]; then
  echo "WARNING: the repo is on the Windows filesystem ($REPO_ROOT)."
  echo "         Builds are ~10x slower there. Move it to your Linux home: ~/chip-lab"
fi
. /etc/os-release
if [[ "${VERSION_ID:-}" != "24.04" ]]; then
  echo "WARNING: tested on Ubuntu 24.04, found ${PRETTY_NAME:-unknown}. Continuing."
fi

# --- 1. System packages -------------------------------------------------------
log "Installing system packages (sudo)"
sudo apt-get update -qq
sudo apt-get install -y -qq \
  build-essential git make python3 python3-venv python3-pip \
  iverilog verilator gtkwave yosys

# --- 2. Optional: newer Verilator from source ---------------------------------
if [[ "$BUILD_VERILATOR" == 1 ]]; then
  log "Building Verilator $VERILATOR_TAG from source (~10-20 min)"
  sudo apt-get install -y -qq autoconf flex bison help2man perl ccache \
    libfl2 libfl-dev zlib1g zlib1g-dev
  src="$HOME/.cache/verilator-src"
  rm -rf "$src"
  git clone --depth 1 --branch "$VERILATOR_TAG" https://github.com/verilator/verilator "$src"
  (cd "$src" && autoconf && ./configure --prefix=/usr/local && make -j"$(nproc)" && sudo make install)
  hash -r
fi

# --- 3. Python virtualenv -----------------------------------------------------
log "Creating Python venv at $REPO_ROOT/.venv"
python3 -m venv "$REPO_ROOT/.venv"
"$REPO_ROOT/.venv/bin/pip" install -q --upgrade pip
"$REPO_ROOT/.venv/bin/pip" install -q -r "$REPO_ROOT/requirements.txt"

# --- 4. Git defaults for this repo --------------------------------------------
if [[ -d "$REPO_ROOT/.git" ]]; then
  git -C "$REPO_ROOT" config core.autocrlf input
  git -C "$REPO_ROOT" config pull.rebase true
fi

log "Done. Next:"
echo "  cd $REPO_ROOT && make doctor && make test"
