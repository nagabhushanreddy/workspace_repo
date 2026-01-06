#!/usr/bin/env bash
set -euo pipefail

# macOS SDK installer for common toolchains.
# Supports: Go, Node.js (with npm), Anaconda (conda).
# Usage:
#   ./install_sdks.sh            # install all
#   ./install_sdks.sh go node    # install selected

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
log() { printf "[sdk-install] %s\n" "$*"; }

install_brew() {
  local arch="$(uname -m)"
  local brew_prefix="/usr/local"
  if [[ "$arch" == "arm64" ]]; then
    brew_prefix="/opt/homebrew"
  fi

  log "Homebrew not found. Installing Homebrew (this may prompt for sudo and take a few minutes)..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

  local shell_profile="$HOME/.zprofile"
  if [[ -n "${ZSH_VERSION:-}" ]]; then
    shell_profile="$HOME/.zprofile"
  elif [[ -n "${BASH_VERSION:-}" ]]; then
    shell_profile="$HOME/.bash_profile"
  fi

  if [[ -x "$brew_prefix/bin/brew" ]]; then
    log "Adding brew to PATH via $shell_profile"
    {
      echo "eval \"$($brew_prefix/bin/brew shellenv)\""
    } >>"$shell_profile"
    # Apply to current shell
    eval "$($brew_prefix/bin/brew shellenv)"
  else
    log "Homebrew install completed but brew not found at expected prefix ($brew_prefix). Please check installation."
  fi
}

require_brew() {
  if ! command -v brew >/dev/null 2>&1; then
    install_brew
  fi
}

install_go() {
  if command -v go >/dev/null 2>&1; then
    log "Go already installed: $(go version)"
  else
    log "Installing Go via Homebrew..."
    brew install go
  fi
}

install_node() {
  if command -v node >/dev/null 2>&1; then
    log "Node.js already installed: $(node -v) (npm $(npm -v))"
  else
    log "Installing Node.js (includes npm) via Homebrew..."
    brew install node
  fi
}

install_anaconda() {
  if command -v conda >/dev/null 2>&1; then
    log "Anaconda/conda already installed: $(conda --version)"
  else
    log "Installing Anaconda via Homebrew cask (large download)..."
    brew install --cask anaconda
    log "Add conda to your shell:"
    log "  source /usr/local/anaconda3/bin/activate  # or /opt/anaconda3 depending on brew prefix"
  fi
}

run_installers() {
  local targets=("$@")
  if [[ ${#targets[@]} -eq 0 ]]; then
    targets=(go node anaconda)
  fi

  require_brew

  for t in "${targets[@]}"; do
    case "$t" in
      go) install_go ;;
      node|npm) install_node ;;
      anaconda|conda) install_anaconda ;;
      *)
        log "Unknown target: $t" >&2
        exit 1
        ;;
    esac
  done

  log "Done. Verify versions (if installed):"
  log "  go version || true"
  log "  node -v && npm -v || true"
  log "  conda --version || true"
}

run_installers "$@"
