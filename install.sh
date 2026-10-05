#!/usr/bin/env bash
# Installer for larp.
#
#   ./install.sh                 install to ~/.local/bin (prompts for audio file)
#   ./install.sh --prefix /usr/local
#   ./install.sh --no-deps       skip distro packages
#   ./install.sh --uninstall
#
# Also works piped: curl -fsSL https://raw.githubusercontent.com/YajatGhule/larp/main/install.sh | bash
set -euo pipefail

REPO_RAW="https://raw.githubusercontent.com/YajatGhule/larp/${LARP_REF:-main}"
PIPES_URL="https://raw.githubusercontent.com/pipeseroni/pipes.sh/v1.3.0/pipes.sh"
PIPES_SHA256="296979f1f272a531ad12ada5284027868dabe70c5be0498e2d43e0b0bf2d76a4"
HL_VER="0.2.0"
HL_URL="https://github.com/sim590/hypr-layout/releases/download/${HL_VER}/hypr-layout-${HL_VER}-x86_64-unknown-linux-gnu"
HL_SHA256="7fae5944fa4296d6abfea72a87274532c001a77cd400242d12769a1267fab03f"

PREFIX="$HOME/.local"
DEPS=1
UNINSTALL=0
while (( $# )); do
  case "$1" in
    --prefix) PREFIX="$2"; shift ;;
    --prefix=*) PREFIX="${1#*=}" ;;
    --no-deps) DEPS=0 ;;
    --uninstall) UNINSTALL=1 ;;
    -h|--help) sed -n '2,9p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
    *) echo "unknown option: $1" >&2; exit 1 ;;
  esac
  shift
done
BIN="$PREFIX/bin"
CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/larp"

info() { printf '\033[1;34m::\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33mwarning:\033[0m %s\n' "$*" >&2; }
die()  { printf '\033[1;31merror:\033[0m %s\n' "$*" >&2; exit 1; }

SUDO=""
(( EUID != 0 )) && SUDO="sudo"
# Writing into PREFIX may need root (e.g. /usr/local)
as_prefix() { if [[ -w "$PREFIX" || ( ! -e "$PREFIX" && -w "$(dirname "$PREFIX")" ) ]]; then "$@"; else $SUDO "$@"; fi; }

if (( UNINSTALL )); then
  for f in larp larp-ws; do as_prefix rm -f "$BIN/$f"; done
  info "removed larp and larp-ws from $BIN (config in $CONFIG_DIR and dependencies kept)"
  exit 0
fi

command -v curl > /dev/null || die "curl is required"

fetch_verified() { # url sha256 dest
  local tmp; tmp="$(mktemp)"
  curl -fsSL -o "$tmp" "$1"
  echo "$2  $tmp" | sha256sum -c --quiet - || { rm -f "$tmp"; die "checksum mismatch for $1"; }
  as_prefix install -Dm755 "$tmp" "$3"
  rm -f "$tmp"
}

# ── Distro packages ─────────────────────────────────────────────────────────
# $SUDO is "sudo" or empty, so word splitting is intended here
# shellcheck disable=SC2206
if (( DEPS )); then
  pkgs=(kitty fastfetch cmatrix cava mpv wireplumber pulseaudio-utils fish jq wtype)
  if command -v pacman > /dev/null; then
    pkgs=(kitty fastfetch cmatrix cava mpv wireplumber libpulse fish jq wtype)
    install_cmd=($SUDO pacman -S --needed --noconfirm)
  elif command -v apt-get > /dev/null; then
    $SUDO apt-get update -qq
    install_cmd=($SUDO apt-get install -y)
  elif command -v dnf > /dev/null; then
    install_cmd=($SUDO dnf install -y)
  elif command -v zypper > /dev/null; then
    install_cmd=($SUDO zypper --non-interactive install)
  elif command -v xbps-install > /dev/null; then
    install_cmd=($SUDO xbps-install -Sy)
  else
    die "unsupported package manager; install manually: ${pkgs[*]} (or rerun with --no-deps)"
  fi

  info "installing packages: ${pkgs[*]}"
  if ! "${install_cmd[@]}" "${pkgs[@]}"; then
    # Package names differ between distros; retry one by one and report what is left
    missing=()
    for p in "${pkgs[@]}"; do "${install_cmd[@]}" "$p" > /dev/null 2>&1 || missing+=("$p"); done
    (( ${#missing[@]} )) && warn "could not install: ${missing[*]} (install them yourself)"
  fi
fi

command -v hyprctl > /dev/null || warn "Hyprland not found; larp needs a running Hyprland session"

# ── pipes.sh ────────────────────────────────────────────────────────────────
if ! command -v pipes.sh > /dev/null; then
  info "installing pipes.sh 1.3.0 to $BIN"
  fetch_verified "$PIPES_URL" "$PIPES_SHA256" "$BIN/pipes.sh"
fi

# ── hypr-layout ─────────────────────────────────────────────────────────────
if ! command -v hypr-layout > /dev/null; then
  glibc="$(ldd --version 2>/dev/null | head -n1 | grep -oE '[0-9]+\.[0-9]+$' || echo 0)"
  if [[ "$(uname -m)" == x86_64 ]] && printf '2.39\n%s\n' "$glibc" | sort -CV; then
    info "installing hypr-layout $HL_VER to $BIN"
    fetch_verified "$HL_URL" "$HL_SHA256" "$BIN/hypr-layout"
  elif command -v cargo > /dev/null; then
    info "building hypr-layout $HL_VER with cargo (prebuilt binary needs x86_64 + glibc 2.39)"
    as_prefix cargo install --locked --git https://github.com/sim590/hypr-layout --tag "$HL_VER" --root "$PREFIX"
  else
    warn "hypr-layout not installed: the prebuilt binary needs x86_64 + glibc >= 2.39."
    warn "install Rust (https://rustup.rs) and rerun, or build https://github.com/sim590/hypr-layout yourself"
  fi
fi

# ── larp itself ─────────────────────────────────────────────────────────────
# Use the files next to this script when run from a clone; download them when piped
src_dir=""
[[ -f "${BASH_SOURCE[0]:-}" ]] && src_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
for f in larp larp-ws larp-update; do
  if [[ -n "$src_dir" && -f "$src_dir/$f" ]]; then
    as_prefix install -Dm755 "$src_dir/$f" "$BIN/$f"
  else
    tmp="$(mktemp)"; curl -fsSL -o "$tmp" "$REPO_RAW/$f"
    as_prefix install -Dm755 "$tmp" "$BIN/$f"; rm -f "$tmp"
  fi
done
info "installed larp, larp-ws and larp-update to $BIN"

if [[ ! -f "$CONFIG_DIR/config" ]]; then
  mkdir -p "$CONFIG_DIR"
  if [[ -n "$src_dir" && -f "$src_dir/config.example" ]]; then
    cp "$src_dir/config.example" "$CONFIG_DIR/config"
  else
    curl -fsSL -o "$CONFIG_DIR/config" "$REPO_RAW/config.example"
  fi
  info "created $CONFIG_DIR/config"

  # Prompt for audio file path
  printf '\n\033[1;34m::\033[0m Set up audio file (optional):\n'
  read -p "  Path to audio file (or press Enter to skip): " audio_path
  if [[ -n "$audio_path" ]]; then
    # Expand ~ to home directory
    audio_path="${audio_path/#\~/$HOME}"
    if [[ -f "$audio_path" ]]; then
      sed -i "s|^AUDIO_PATH=\"\"|AUDIO_PATH=\"$audio_path\"|" "$CONFIG_DIR/config"
      info "audio file set to: $audio_path"
    else
      warn "file not found: $audio_path (you can set it later in $CONFIG_DIR/config)"
    fi
  fi
fi

case ":$PATH:" in *":$BIN:"*) ;; *) warn "$BIN is not in your PATH; add it to run 'larp'" ;; esac
info "done. run: larp"
