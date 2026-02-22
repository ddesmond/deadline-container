# Deadline 10 Docker Containers - Unofficial - Developer setup
<img src="assets/deadline_container.png">

### Not for production use - For testing purposes only - Beware of the Gremlins

<br>

## Quick Info
This repo contains all necessary files to build and run Deadline 10.4 docker containers.
It builds the stack from the official Linux Deadline installer and runs all services in separate containers.

> Download the Deadline 10.4 Linux installer from the AWS Thinkbox website. Extract it and place the
> `Deadline-<version>-linux-installers/` directory inside `install/`. Run `make download` to verify
> the installer is in place.

> To include your custom plugins, copy them to the `deadline_custom/` folder (respecting the original
> Deadline folder structure) and run `make sync` to move them into the repository.

To rebuild the repo, delete `repository/repository` and `client/` and run `make dev` again.
The installer container checks whether files are present and reinstalls only what is missing.
Use `make clean` to stop containers, remove all named volumes, and delete DB and client files.

---

## Requirements

- Docker Desktop with **Rosetta disabled** (use QEMU x86-64 emulation on Apple Silicon)
- `DOTNET_EnableWriteXorExecute=0` is set automatically in the compose file — required for .NET 8
  under QEMU on Apple Silicon (M-series Macs)

---

## Setup

1. Copy `.env.example` to `.env` and set `DEADLINE_VERSION`:
   ```sh
   cp .env.example .env
   # edit .env and set DEADLINE_VERSION=10.4.2.3
   ```

2. Place the extracted Deadline installer directory inside `install/`:
   ```
   install/d10instalers/Deadline-10.4.2.3-linux-installers/
   ├── DeadlineRepository-10.4.2.3-linux-x64-installer.run
   ├── DeadlineClient-10.4.2.3-linux-x64-installer.run
   └── ...
   ```

3. Create required runtime directories and start the stack:
   ```sh
   make dev
   ```

---

## Containers

| Container | Image | Type | Port |
|---|---|---|---|
| `d10-mongodb` | `mongo:5.0.1` | Long-running | 27017 |
| `d10-repo` | `ubuntu:24.04` | One-shot installer | — |
| `d10-webservice` | `ubuntu:24.04` | Long-running | 8081 |
| `d10-rcs` | `ubuntu:24.04` | Long-running | 8080 |
| `d10-worker` | `ubuntu:24.04` | On-failure restart | — |

The `d10-repo` container installs both the Deadline Repository and Client (including RCS and Webservice
binaries) then exits. The `d10-webservice` and `d10-rcs` containers poll for the installed binaries
and `deadline.ini` before starting their respective services.

---

## How to run

```sh
make dev
```

Startup order (enforced via health checks and polling):
```
1. MongoDB              — waits until healthy
2. d10-repo             — installs repo + client, then exits
3. d10-webservice       — polls for binaries + deadline.ini, then starts (port 8081)
4. d10-rcs              — waits for webservice healthy, then starts (port 8080)
5. d10-worker           — separate compose file (docker-compose.worker.yml)
```

### Notes

- First run can take **5–15 minutes** on Apple Silicon (QEMU x86-64 emulation is slow for the
  `.run` installer). Subsequent runs skip the install and start in seconds.
- `d10-rcs` is started with `docker compose up -d d10rcs` after `d10-webservice` becomes healthy,
  or will be picked up automatically on the next `docker compose up`.
- MongoDB is exposed on `localhost:27017` and uses `host.docker.internal` inside containers so
  external Deadline nodes can also connect via `localhost:27017`.

### Worker

```sh
docker compose -f docker-compose.worker.yml up d10worker
```

The worker uses `install/deadline.ini` (bind-mounted) which must have `NetworkRoot` pointing to
the repository share accessible from the worker host.

---

## Named volumes

The compose stack uses three named volumes in addition to bind mounts:

| Volume | Mount path | Purpose |
|---|---|---|
| `thinkbox` | `/var/lib/Thinkbox` | System-level Deadline config (deadline.ini) |
| `root-thinkbox` | `/root/Thinkbox` | User-level Deadline config (deadline.ini, cache) |
| _(bind)_ | `./db` → `/data/db` | MongoDB data |
| _(bind)_ | `./repository` → `/deadline10/repository` | Deadline repository files |
| _(bind)_ | `./client` → `/deadline10/client` | Installed Deadline client binaries |

Run `make clean` to remove all volumes (full reset including MongoDB data and client install).
Run `make repoclean` to remove only the repository and client bind-mount directories (keeps DB).

---

## Errors, issues, debugging

**Webservice `inotify` / open file descriptor errors**

Set higher `inotify` limits on the host:
```bash
echo fs.inotify.max_user_instances=524288 | sudo tee -a /etc/sysctl.conf && sudo sysctl -p
```

**`d10-rcs` not starting**

`d10-rcs` depends on `d10-webservice: healthy`. If `d10-webservice` wasn't healthy when compose
first ran, start RCS manually:
```sh
docker compose up -d d10rcs
```

**Checking service logs**

```sh
docker logs d10-repo        # installer output
docker logs d10-webservice  # webservice startup / connection errors
docker logs d10-rcs         # RCS startup / connection errors
```

**Full reset**

```sh
make clean   # stops containers, removes volumes and DB files
make dev     # reinstalls everything from scratch
```

---

### If you find any bugs or a better setup solution please open an issue or a pull request.
