# AGENTS.md — Deadline 10 Docker Containers

## Project Overview

This repo builds and runs AWS Thinkbox Deadline 10.4 as a set of Docker containers
for **development and testing only**. The stack is orchestrated via Docker Compose
and built from the official Linux Deadline installer. There is no application code
to compile — the codebase consists of shell scripts, Docker Compose files, INI
configs, and a Makefile.

**Tech stack:** Docker Compose, POSIX shell scripts, MongoDB 5.0.1, Mono runtime,
INI configuration files.

---

## Build / Run Commands

All commands run from the repository root.

| Command | Purpose |
|---|---|
| `make dev` | Create `db/` and `repository/` dirs, then `docker compose up` |
| `make down` | Stop all containers (`docker compose down`) |
| `make download` | Check that the Deadline installer tarball is present in `install/` |
| `make sync` | Copy custom plugins from `deadline_custom/` into the repository |
| `make repoclean` | Delete installed repository and client files |
| `make clean` | Stop containers, remove volumes and DB files |
| `make all` | Check installer + start all containers (sequential) |
| `make help` | Print all available Makefile targets |

### Running individual services

```sh
# Start only MongoDB and the repo installer
docker compose up d10mongodb d10repo

# Start a worker (separate compose file)
docker compose -f docker-compose.worker.yml up d10worker

# Rebuild a single service
docker compose up --build d10webservice
```

### There are no tests or linters

This project has no test suite, no CI pipeline, no linter configs, and no
formatter configs. If you add shell scripts, validate them with `shellcheck`
before committing. If you add Python or JS code, add appropriate linting.

---

## Architecture

### Container dependency chain

```
MongoDB (d10mongodb)
  └─> Repository installer (d10repo)          [one-shot, exits on completion]
        └─> Client installer (d10client)       [one-shot, exits on completion]
              ├─> Webservice (d10webservice)    [long-running, port 8081]
              │     └─> RCS (d10rcs)           [long-running, port 8080]
              └─> Worker (d10worker)           [separate compose file]
```

### Directory layout

```
deadline-container/
├── .env.example          # Template for .env (DEADLINE_VERSION)
├── install/              # Shell scripts and INI configs mounted into containers
│   ├── *.sh              # Setup and runtime scripts (POSIX sh)
│   ├── connection.ini    # MongoDB connection config
│   ├── deadline.ini      # Deadline client config
│   └── deadline-webservice.ini
├── repository/           # Mounted into containers at /deadline10/
│   └── .deadlinerepo     # Placeholder (actual files are git-ignored)
├── deadline_custom/      # User's custom Deadline plugins (synced via `make sync`)
├── assets/               # README images (PNG)
├── docker-compose.yml    # Main stack (5 services)
├── docker-compose.worker.yml  # Separate worker container
├── Makefile              # Developer commands
├── setup.host.sh         # Host prerequisite installer (apt)
└── README.md
```

### Environment variables

The Deadline version is centralized in `.env` (git-ignored). Copy `.env.example`
to `.env` and set `DEADLINE_VERSION` to match the tarball you placed in `install/`.

---

## Code Style Guidelines

### Shell Scripts (`install/*.sh`)

- **Shebang:** Always use `#!/bin/sh` (POSIX sh, not bash). Do not use bashisms.
- **Error handling:** All scripts include `set -e` at the top to fail on errors.
  Prefer explicit error checking with `if` blocks for critical operations.
- **Idempotency pattern:** Installer scripts check whether work is already done
  before acting. Follow this pattern:
  ```sh
  if [ -f /path/to/expected/file ]; then
    echo "Already installed."
    exit 0
  fi
  ```
- **Wait-loop pattern:** Long-running service scripts poll for their binary
  before starting, with a timeout:
  ```sh
  while [ ! -f "$binary" ]; do
    # check timeout, sleep, increment elapsed
  done
  exec "$binary"
  ```
- **Variables:** Use lowercase or snake_case for local variables (`installers`,
  `destination`). Always quote variables in paths: `"$var"` not `$var`.
- **Indentation:** 2 spaces. No tabs.
- **Comments:** Brief single-line comments above the relevant block. No doc
  headers or function documentation (scripts are short and linear).
- **Functions:** Not used. Scripts are short procedural sequences. Keep it that way
  unless a script exceeds ~50 lines.
- **Output:** Use `echo` for status messages. Prefix with a visual separator
  for section headers:
  ```sh
  echo "----------------------------------------------------"
  echo "Section description"
  echo "----------------------------------------------------"
  ```
- **File paths:** Use absolute paths inside containers (`/deadline10/...`,
  `/opt/setup/...`). The mount points are defined in docker-compose.yml.

### Docker Compose (`docker-compose.yml`, `docker-compose.worker.yml`)

- **Service names:** Lowercase, prefixed with `d10` (e.g., `d10mongodb`, `d10rcs`).
- **Container names:** Match service names with `d10-` prefix
  (e.g., container `d10-mongodb` for service `d10mongodb`).
- **Images:** All Deadline services use `image: mono:latest` directly (no build
  context or Dockerfile needed).
- **Health checks:** Use `curl -i http://0.0.0.0:<port> || exit 1` for HTTP
  services. Use `mongosh` ping for MongoDB.
- **Dependencies:** Use `condition: service_healthy` or
  `condition: service_completed_successfully` — never bare `depends_on`.
- **Volumes:** Bind mounts use the long-form `type: bind` syntax for clarity.
  Short-form (`'./host:/container'`) is acceptable for simple config file mounts.
- **Restart policies:** `no` for one-shot installers, `always` for long-running
  services, `on-failure` for workers.
- **Network:** All services attach to the `net` bridge network.

### Makefile

- **Target naming:** Lowercase, no hyphens or underscores (e.g., `repoclean`,
  `clean`).
- **Help comments:** Every target must have a `## Description` comment on the
  same line as the target declaration. These are parsed by `make help`.
  ```makefile
  mytarget: ## Short description of what this target does
  ```
- **Indentation:** Tabs for recipes (required by Make).

### INI Configuration Files (`install/*.ini`)

- **Format:** Standard INI with `[Section]` headers and `Key=Value` pairs.
- **No spaces** around `=` signs.
- **Boolean values:** `True` / `False` (capitalized).

---

## Known Issues and Gotchas

1. **Git-ignored runtime directories:** `repository/client*`, `repository/repository*`,
   and `db/` are generated at runtime and git-ignored. Only placeholder files
   (`.deadlinerepo`, `.deadline_custom`) are tracked.

2. **Startup time:** The full stack can take 5-10 minutes to install and stabilize
   on first run. Installer containers (`d10repo`, `d10client`) are one-shot and
   exit after completion.

3. **Installer tarball must be placed manually:** Download the Deadline Linux
   installer tarball and place it at `install/Deadline-<version>-linux-installers.tar`.
   The filename must match the `DEADLINE_VERSION` in `.env`.
