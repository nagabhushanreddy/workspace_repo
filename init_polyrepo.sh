#!/usr/bin/env bash
set -euo pipefail

# Initialize polyrepo structure:
# - Workspace coordinator repo (this dir)
# - Independent repos for frontend, services, infra

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
config_file="$script_dir/.polyrepo.config"
log() { printf "[polyrepo-init] %s\n" "$*"; }

# Load config
if [[ -f "$config_file" ]]; then
  source "$config_file"
else
  log "Warning: .polyrepo.config not found, using defaults"
  GIT_USER_EMAIL="dev@workspace.local"
  GIT_USER_NAME="Workspace Dev"
fi

init_workspace_repo() {
  if [[ -d "$script_dir/.git" ]]; then
    log "Workspace repo already initialized"
    return
  fi
  cd "$script_dir"
  log "Initializing workspace coordinator repo..."
  git init
  git config user.email "${GIT_USER_EMAIL}" || true
  git config user.name "${GIT_USER_NAME}" || true
  git add install_sdks.sh install_vs_code_extensions.sh README.md .gitignore .vscode/
  git add .github/copilot-instructions.md
  git commit -m "Initial workspace setup: install scripts, config, docs"
  log "Workspace repo ready: $script_dir"
}

init_component_repo() {
  local component_path="$1"
  local component_name="$(basename "$component_path")"

  if [[ -d "$component_path/.git" ]]; then
    log "$component_name already has .git, skipping"
    return
  fi

  cd "$component_path"
  log "Initializing $component_name repo..."
  git init
  git config user.email "${GIT_USER_EMAIL}" || true
  git config user.name "${GIT_USER_NAME}" || true
  git add .
  git commit -m "Initial $component_name"
  log "$component_name repo ready: $component_path"
}

# Initialize workspace
init_workspace_repo

# Initialize each service
for service_dir in "$script_dir"/services/*/; do
  [[ -d "$service_dir" ]] && init_component_repo "$service_dir"
done

# Initialize frontend
[[ -d "$script_dir/frontend" ]] && init_component_repo "$script_dir/frontend"

# Initialize infra
[[ -d "$script_dir/infra" ]] && init_component_repo "$script_dir/infra"

log "Polyrepo initialization complete!"
log "Next steps:"
log "  - Create remote repos for each component"
log "  - Add remotes: cd <component> && git remote add origin <repo-url>"
log "  - Push: git push -u origin main"
