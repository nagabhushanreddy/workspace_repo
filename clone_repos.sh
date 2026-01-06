#!/usr/bin/env bash
set -euo pipefail

# Clone polyrepo components using .polyrepo.config

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
config_file="$script_dir/.polyrepo.config"
log() { printf "[clone] %s\n" "$*"; }

# Load config
if [[ ! -f "$config_file" ]]; then
  log "Error: .polyrepo.config not found"
  exit 1
fi
source "$config_file"

# Determine protocol (ssh vs https)
use_ssh=false
if [[ "${1:-}" == "--ssh" ]]; then
  use_ssh=true
  shift
fi

build_repo_url() {
  local repo_name="$1"
  if $use_ssh; then
    case "$REPO_TYPE" in
      github)
        echo "git@github.com:$(basename "$BASE_URL")/${repo_name}.git"
        ;;
      gitlab)
        echo "git@gitlab.com:$(basename "$BASE_URL")/${repo_name}.git"
        ;;
      *)
        echo "git@${BASE_URL#https://}:${repo_name}.git"
        ;;
    esac
  else
    echo "${BASE_URL}/${repo_name}.git"
  fi
}

clone_repo() {
  local repo_name="$1"
  local target_path="$2"
  
  if [[ -d "$target_path/.git" ]]; then
    log "$repo_name already exists, skipping"
    return
  fi

  local url=$(build_repo_url "$repo_name")
  log "Cloning $repo_name from $url..."
  rm -rf "$target_path"
  git clone "$url" "$target_path"
}

log "Using config from: $config_file"
log "Base URL: $BASE_URL"
log "Protocol: $(if $use_ssh; then echo "SSH"; else echo "HTTPS"; fi)"
echo ""

# Clone frontend repos
for repo in $FRONTEND_REPOS; do
  clone_repo "$repo" "$script_dir/frontend"
done

# Clone service repos
for repo in $SERVICE_REPOS; do
  clone_repo "$repo" "$script_dir/services/$repo"
done

# Clone infra repos
for repo in $INFRA_REPOS; do
  clone_repo "$repo" "$script_dir/infra"
done

log ""
log "Clone complete!"
log "Workspace ready for development."
