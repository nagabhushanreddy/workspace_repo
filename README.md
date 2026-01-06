# Polyrepo Workspace

Workspace coordinator + independent component repos.

## Structure
```
workspace/                    # This repo (setup scripts, docs)
├── .git/                     # Workspace repo
├── install_sdks.sh          # SDK installer
├── init_polyrepo.sh         # Init git repos
├── clone_repos.sh           # Clone components
├── README.md
├── .vscode/tasks.json       # Shared tasks
│
├── frontend/                # React Native (separate repo)
│  └── .git/
│
├── services/                # Microservices (separate repos)
│  ├── authentication-api/
│  │  └── .git/
│  ├── authorization-api/
│  │  └── .git/
│  ├── entity-api/
│  │  └── .git/
│  └── reporting-api/
│     └── .git/
│
└── infra/                   # Infrastructure (separate repo)
   └── .git/
```

## Initial Setup

1. **Install SDKs**:
```bash
./install_sdks.sh
```

2. **Initialize repos** (first time):
```bash
./init_polyrepo.sh
```
Creates `.git/` in workspace, frontend, services, and infra.

3. **Add remotes and push** (after creating GitHub repos):
```bash
# Workspace repo
git remote add origin git@github.com:myorg/workspace.git
git push -u origin main

# Each service
cd services/authentication-api
git remote add origin git@github.com:myorg/authentication-api.git
git push -u origin main
# ... repeat for other services, frontend, infra
```

## Development

**Run components** (VS Code Tasks or command line):
```bash
# Frontend
cd frontend && npm install && npm run start

# Services (each in separate terminal)
cd services/authentication-api && go run main.go      # port 8001
cd services/authorization-api && go run main.go       # port 8002
cd services/entity-api && python -m venv .venv && source .venv/bin/activate && pip install -r requirements.txt && uvicorn main:app --reload --port 8003
cd services/reporting-api && python -m venv .venv && source .venv/bin/activate && pip install -r requirements.txt && uvicorn main:app --reload --port 8004
```

## Cloning into New Workspace

```bash
git clone git@github.com:myorg/workspace.git
cd workspace
./install_sdks.sh
./clone_repos.sh \
  git@github.com:myorg/authentication-api.git \
  git@github.com:myorg/authorization-api.git \
  git@github.com:myorg/entity-api.git \
  git@github.com:myorg/reporting-api.git \
  git@github.com:myorg/frontend.git \
  git@github.com:myorg/infra.git
```

## Workflow

- **Workspace commits**: scripts, config, top-level docs
- **Component commits**: work in each folder's repo independently
- **CI/CD**: each component repo has its own workflow/pipeline

Each team can work independently on their component.
