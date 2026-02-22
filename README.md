# Deadline 10 Docker Containers - Unofficial - Developer setup
<img src="assets/deadline_container.png">

### Not for production use - For testing purposes only - Beware of the Gremlins

<br>

## Quick Info
This repo contains all necessary files to build and run Deadline 10.4 docker containers with different services.
It builds the stack from the Linux Deadline installer and runs the services in separate containers.

> Download the Deadline 10.4 Linux installer tarball from the AWS Thinkbox website and place it in the `install/` directory as `Deadline-10.4.2.3-linux-installers.tar`. Run `make download` to verify the file is in place.

> To include your custom plugins in the repo, copy your plugins to the `deadline_custom` folder respecting the original Deadline folder structure and run `make sync` to move them into the repository custom plugins folder.

To rebuild the repo, delete files and folders in the `repository/` directory and run `make dev` again.
The installer containers will check if the files are present and rebuild if necessary on the next run.
Use `make clean` to stop containers, remove volumes and DB files.

> Please check the code if it fits your setup and change the Deadline INI files accordingly.

---

## Setup

1. Copy `.env.example` to `.env` and set `DEADLINE_VERSION` to match your installer tarball:
   ```sh
   cp .env.example .env
   ```

2. Place the Deadline installer tarball in `install/`:
   ```
   install/Deadline-10.4.2.3-linux-installers.tar
   ```

3. Start the stack:
   ```sh
   make dev
   ```

---

## Containers
- Deadline MongoDB - 1 container, port 27017, standard MongoDB setup, v5.0.1
- Deadline Repository installer - 1 container, one-shot, installs repo files then exits
- Deadline Client installer - 1 container, one-shot, installs client files then exits
- Deadline Webservice - 1 container, standard Deadline Webservice setup, port 8081
- Deadline RCS - 1 container, standard Deadline RCS setup, port 8080
- Deadline Worker - 1 container, launched from separate `docker-compose.worker.yml`, standard Deadline Worker no-gui setup

<br>

---
## How to run
Clone the repo and download the Deadline installer from the official website. Place the installer in the `install/` directory.
- Copy `.env.example` to `.env` and set `DEADLINE_VERSION` to match your installer.
- Edit `install/connection.ini` to match your MongoDB connection string.
- Edit `install/deadline.ini` to match your Deadline setup.

Run `make dev` (or `docker compose up`) in the root directory of the project.

### Notes
It can take a while to launch all containers and services, so be patient. Depending on your host RAM and CPU, it can take up to 10 minutes to install repository files and start all services.
Containers have dependencies and will start in the following order:
```
1. MongoDB
2. Repository - checks if repository is already installed, if not it installs it
3. Client - checks if client is already installed, if not it installs it
4. Webservice - waits for client files, then starts the web service
5. RCS - waits for client files, then starts the RCS service
6. Worker (separate compose file) - docker-compose.worker.yml
```

---

<br>

## Errors, issues, debugging

> Deadline Webservice container open file descriptors error - inotify error <br>

If you get an error like this then set your host ulimits to a higher value:
> Check your host machine ulimits and set them higher. Use the following snippet which was tested OK on Ubuntu systems.
Execute the following commands in the terminal of the host machine where docker compose runs:
```bash
echo fs.inotify.max_user_instances=524288 | sudo tee -a /etc/sysctl.conf && sudo sysctl -p
```

<br>

### Host networking

Add this entry to your hosts file to resolve container names locally:
```bash
127.0.0.1       d10mongodb d10client d10rcs d10repo d10webservice
```

### If you find any bugs or a better setup solution please open an issue or a pull request and we can discuss the changes and merge them.
