# AGENTS.md — Deadline 10 Docker Containers

## Project Overview

This repo builds and runs AWS Thinkbox Deadline 10.4 as a set of Docker containers
for **development and testing only**. The stack is orchestrated via Docker Compose
and built from the official Linux Deadline installer. There is no application code
to compile — the codebase consists of shell scripts, Docker Compose files, INI
configs, and a Makefile.

**Tech stack:** Docker Compose, POSIX shell scripts, MongoDB 5.0.1, Ubuntu 24.04
(linux/amd64 via QEMU), self-contained .NET 8 binaries (deadlinewebservice.exe,
deadlinercs.exe).

---

## Build / Run Commands

All commands run from the repository root.

| Command | Purpose |
|---|---|
| `make dev` | Create `db/`, `repository/`, `client/` dirs, then `docker compose up` |
| `make down` | Stop all containers (`docker compose down`) |
| `make download` | Check that the Deadline installer directory is present in `install/` |
| `make sync` | Copy custom plugins from `deadline_custom/` into the repository |
| `make repoclean` | Delete installed repository and client files |
| `make clean` | Stop containers, remove named volumes and DB/client files |
| `make all` | Check installer + start all containers (sequential) |
| `make help` | Print all available Makefile targets |

### Running individual services

```sh
# Start only MongoDB and the repo+client installer
docker compose up d10mongodb d10repo

# Start RCS after webservice is healthy
docker compose up -d d10rcs

# Start a worker (separate compose file)
docker compose -f docker-compose.worker.yml up d10worker
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
  └─> Installer (d10repo)            [one-shot: installs repo + client, then exits]
        ├─> Webservice (d10webservice) [long-running, port 8081]
        │     └─> RCS (d10rcs)        [long-running, port 8080]
        └─> Worker (d10worker)        [separate compose file]
```

`d10-webservice` and `d10-rcs` do **not** depend on `d10repo` via compose conditions —
they use polling loops in their run scripts to wait for binaries and `deadline.ini`.

### Directory layout

```
deadline-container/
├── .env                          # DEADLINE_VERSION (git-ignored)
├── .env.example                  # Template
├── install/                      # Shell scripts and INI configs (bind-mounted into containers)
│   ├── pre_install.sh            # apt dependencies for ubuntu:24.04
│   ├── setup_deadline.sh         # One-shot: installs repo + client, writes deadline.ini
│   ├── run_webservice.sh         # Polls for binaries + deadline.ini, then starts webservice
│   ├── run_rcsservice.sh         # Polls for binaries + deadline.ini, then starts RCS
│   ├── run_worker.sh             # Worker startup script
│   ├── download_deadline.sh      # Verifies installer presence
│   ├── connection.ini            # MongoDB connection config (Hostname=host.docker.internal)
│   ├── deadline.ini              # Worker-only client config (bind-mounted in worker compose)
│   └── d10instalers/
│       └── Deadline-<version>-linux-installers/   # git-ignored, placed manually
├── repository/                   # Bind-mounted at /deadline10/repository
│   └── settings/connection.ini   # Written by installer (git-ignored)
├── client/                       # Bind-mounted at /deadline10/client (git-ignored)
├── deadline_custom/              # User's custom Deadline plugins (synced via `make sync`)
├── assets/                       # README images (PNG)
├── db/                           # MongoDB data (git-ignored)
├── docker-compose.yml            # Main stack (4 services)
├── docker-compose.worker.yml     # Separate worker container
├── Makefile                      # Developer commands
├── setup.host.sh                 # Host prerequisite installer (apt)
└── README.md
```

### Named volumes

Two named volumes share Deadline config between the installer and service containers:

| Volume | Mount path | Contains |
|---|---|---|
| `thinkbox` | `/var/lib/Thinkbox` | System-level `deadline.ini` |
| `root-thinkbox` | `/root/Thinkbox` | User-level `deadline.ini`, runtime cache |

Both volumes are mounted on `d10repo`, `d10webservice`, and `d10rcs`. The installer
writes `deadline.ini` to both paths; the run scripts wait for
`/root/Thinkbox/Deadline10/deadline.ini` before launching the service binary.

### Environment variables

The Deadline version is centralized in `.env` (git-ignored). Copy `.env.example`
to `.env` and set `DEADLINE_VERSION` to match the installer directory in `install/d10instalers/`.

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
- **Wait-loop pattern:** Long-running service scripts poll for files with a
  timeout before starting:
  ```sh
  while [ ! -f "$file" ]; do
    if [ "$elapsed" -ge "$timeout" ]; then
      echo "ERROR: timed out. Exiting."
      exit 1
    fi
    echo "Waiting for $file ... (${elapsed}s/${timeout}s)"
    sleep "$interval"
    elapsed=$((elapsed + interval))
  done
  ```
- **Variables:** Use lowercase or snake_case for local variables. Always quote
  variables in paths: `"$var"` not `$var`.
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
- **Images:** All Deadline services use `image: ubuntu:24.04` with
  `platform: linux/amd64`. Do NOT use `mono:latest` — glibc 2.28 on Buster is
  too old for the self-contained .NET 8 binaries.
- **QEMU fix:** All Deadline service containers must set
  `DOTNET_EnableWriteXorExecute: "0"` — required for .NET 8 W^X JIT under QEMU
  on Apple Silicon.
- **MongoDB hostname:** Use `host.docker.internal` (with `extra_hosts: host-gateway`)
  so MongoDB is reachable from both compose containers and external nodes via
  `localhost:27017`.
- **Health checks:** Use `bash -c 'echo > /dev/tcp/0.0.0.0/<port>'` for HTTP
  services (`curl` is not installed). Use `mongosh` ping for MongoDB.
- **Dependencies:** Use `condition: service_healthy` — never bare `depends_on`.
  `d10webservice` and `d10rcs` only depend on `d10mongodb: healthy`; they wait
  for the installer output via polling loops in their run scripts.
- **Volumes:** Bind mounts use the long-form `type: bind` syntax for clarity.
  Named volumes use `type: volume`. Short-form is acceptable for simple mounts.
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

1. **`deadline.ini` is written to two paths by the installer:**
   `/root/Thinkbox/Deadline10/deadline.ini` (user-level, read first by the binary)
   and `/var/lib/Thinkbox/Deadline10/deadline.ini` (system-level). Both paths are
   on named volumes (`root-thinkbox` and `thinkbox`) so all containers share the
   same file. If volumes are wiped independently, `setup_deadline.sh` has a fallback
   block that writes `deadline.ini` directly without re-running the full installer.

2. **`d10rcs` startup:** `d10-rcs` depends on `d10-webservice: healthy`. If compose
   was first run while webservice was unhealthy (e.g., installer still running),
   `d10-rcs` will not be started automatically. Run `docker compose up -d d10rcs`
   after webservice becomes healthy.

3. **Git-ignored runtime directories:** `repository/settings/`, `repository/repository/`,
   `client/`, and `db/` are generated at runtime and git-ignored. Only placeholder
   files (`.deadlinerepo`, `.deadline_custom`) are tracked.

4. **Startup time:** The full stack takes **5–15 minutes** on first run on Apple
   Silicon (QEMU x86-64 emulation). Subsequent runs skip the install entirely and
   start in seconds (idempotency checks all three sentinels: repo `connection.ini`,
   client `deadlinecommand.exe`, and `deadline.ini`).

5. **Installer directory must be placed manually:** Download and extract the Deadline
   Linux installer, and place the directory at
   `install/d10instalers/Deadline-<version>-linux-installers/`. The directory name
   must match `DEADLINE_VERSION` in `.env`.

6. **`deadlinewebservice.exe` and `deadlinercs.exe` are self-contained .NET 8 ELF
   binaries** — not Mono assemblies. Mono is not needed. The `mono:latest` image
   (Debian Buster, glibc 2.28) is too old; `ubuntu:24.04` (glibc 2.39) is required.

7. **QEMU W^X segfault:** Without `DOTNET_EnableWriteXorExecute=0`, the .NET 8
   runtime raises SIGSEGV under QEMU x86-64 on Apple Silicon when MongoDB becomes
   reachable. This env var disables W^X JIT memory protection to work around the
   incompatibility.

8. **Network "Resource is still in use"** on `docker compose down`: A leftover
   container attached to the `net` network prevents network removal. This is benign
   and does not affect the next `docker compose up`.
