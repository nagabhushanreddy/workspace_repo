#!/usr/bin/env bash
set -euo pipefail

# Push workspace and all component repos to remote

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
config_file="$script_dir/.polyrepo.config"
log() { printf "[push] %s\n" "$*"; }

# Load config
if [[ ! -f "$config_file" ]]; then
  log "Error: .polyrepo.config not found"
  exit 1
fi
source "$config_file"

# Determine protocol
use_ssh=false
if [[ "${1:-}" == "--ssh" ]]; then
  use_ssh=true
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

push_repo() {
  local repo_path="$1"
  local repo_name="$2"
  
  if [[ ! -d "$repo_path/.git" ]]; then
    log "Skipping $repo_name (no .git found)"
    return
  fi

  cd "$repo_path"
  local url=$(build_repo_url "$repo_name")
  
  # Check if remote exists
  if ! git remote get-url origin >/dev/null 2>&1; then
    log "Adding remote for $repo_name: $url"
    git remote add origin "$url"
  fi
  
  log "Pushing $repo_name..."
  git branch -M main 2>/dev/null || true
  git push -u origin main
}

log "Using config from: $config_file"
log "Base URL: $BASE_URL"
log "Protocol: $(if $use_ssh; then echo "SSH"; else echo "HTTPS"; fi)"
echo ""

# Push workspace
push_repo "$script_dir" "$WORKSPACE_REPO"

# Push frontend repos
for repo in $FRONTEND_REPOS; do
  push_repo "$script_dir/frontend" "$repo"
done

# Push service repos
for repo in $SERVICE_REPOS; do
  push_repo "$script_dir/services/$repo" "$repo"
done

# Push infra repos
for repo in $INFRA_REPOS; do
  push_repo "$script_dir/infra" "$repo"
done

log ""
log "Push complete!"
log "All repos pushed to $BASE_URL"
