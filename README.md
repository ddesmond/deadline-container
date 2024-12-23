# Deadline 10 Docker Containers - Unofficial - Developer setup
<img src="assets/deadline_container.png">

### Not for production use - For testing purposes only - Beware of the Gremlins

<br>

## Quick Info
This repo contains all necessary files to build and run Deadline 10 docker containers with different services.
It builds the stack from the linux Deadline installer and runs the services in separate containers.

> Download the installer either manualy or run `make downoload` in the root of the repo

Additionaly you can clone the web ui setup from https://github.com/BreakTools/deadline-web-app-frontend and https://github.com/BreakTools/deadline-web-app-backend .
To setup those, run the following commands in the root directory of the project `make webapp`

<img src="assets/webapp.png" width=75%>

The WEBUI is accesible at http://localhost:2000 or http://0.0.0.0:2000  after the stack has been launched and settled - no nginx routing is setup per defaults.

After getting the webapp - it is ready to run `make dev` and the stack will be up and running.

> To include your custom plugins in the repo, copy your plugins to the deadline_custom folder respecting the original deadline folder structure and run `make sync` and those will be moved inside the repository custom plugins folder.

To rebuild the repo, delete files and folders in the repository folder and run `make dev` again.
The installer containers will check if the files are present and rebuild if necessary on the next run.
Use `make webclean` to remove webui files including the database and docker caches ( it runs docker system prune -af)

> Please check the code if it fits your setup and change the deadline ini files accordigly.

---

## Containers
- Deadline Nginx - Traffic - 1 container, port 80, 443, standard setup, brin your own certs
- Deadline MongDB - 1 container, port 27017, standard MongoDB setup, v 5.0.1
- Deadline Repository installer - 1 container, standard Deadline setup, no ssl
- Deadline Client installer - 1 container, standard Deadline Client setup
- Deadline Webservice - 1 container, standard Deadline Webservice setup, port 8081
- Deadline RCS - 1 container, standard Deadline RCS setup, port 8080
- Deadline Asset Server - 1 container, NOT IMPLEMENTED
- Deadline Balancer - 1 container,  NOT IMPLEMENTED
- Deadline Pulse - 1 container, NOT IMPLEMENTED
- Deadline Monitor WebUI App Frontend - 1 container, standard Deadline Monitor WebUI app setup
- Deadline Monitor WebUI App Backend - 1 container, standard Deadline Monitor Backend app setup
- Deadline Worker - 1 container, launched from separate docker-compose.worker.yml file, standard Deadline Worker no gui setup

<br>

--- 
## How to run
Clone the repo and download the Deadline installer from the official website. Place the installer in the install directory of the project. 
- Edit the setup sh files to match your deadline version you are installing (TODO: add env var vor deadline versions).
- Edit the install/connetion.ini file to match your MongoDB connection string.
- Edit the install/deadline.ini file to match your Deadline setup.

Run `docker compose up` in the root directory of the project.
After containers stabilize, open Deadline Monitor and disable Webservice password in the Repository settings for the web app services to work.

You can disable parts you dont need in the docker-compose.yml file. Feel free to copy and/or edit the compose file to fit your specific needs.

### Notes
It can take a while to launch all containers and services, so be patient. Depending on your host RAM and CPU, it can take up to 10 minutes to install repository files and start all services.
Containers have dependencies, so they will be started in the following order:
```
1. MongoDB
2. Repository - checks if repository is already installed, if not it installs it
3. Client - checks if client is already installed, if not it installs it
4. Webservice - checks if webservice-client files  are already installed, if not it waits until the files are there
5. RCS - checks if RCS-client files are already installed, if not it waits until the files are there
6. Monitor WebUI App Backend and Frontend
7. Separate Deadline worker-slave container - launch from docker-compose.worker.yml
```

--- 

<br>

## Errors, issues, debugging

> Deadline Webservice container open file desriptors error - inotify error <br>

If you get an error like this then set your host ulimits to a higher value:
> Check your host machine ulimits and set them higher. Use the following snippet which was tested OK on ubuntu systems.
Execute the following commands in the terminal of the host machine where docker compose runs:
```bash
echo fs.inotify.max_user_instances=524288 | sudo tee -a /etc/sysctl.conf && sudo sysctl -p
```

<br>
<br>

### Deadline Monitor Webservice Settings

<img src="assets/webservice-settings.png" width=85%>

This is needed for the Deadline Monitor WebUI App to work.
The Deadline webservice needs no password set in the Repository settings to make connections and request work.
Point your Deadline Monitor to the installed Deadline Repository.
Add this entry to your hosts file:
```bash
127.0.0.1       d10mongodb d10client d10rcs d10repo d10webservice deadline-web-app-backend deadline-web-app-frontend
```

You can set a nginx instance to route the traffic to the Deadline Webservice and Deadline Monitor WebUI. This is not setup per defaults.

### Deadline Monitor WebUI App OpenAI APi Key
You will need to provide your own OpenAI API key to use the Deadline Monitor WebUI App. You can get one from the OpenAI website.

### If you find any bugs or a better setup solution please open an issue or a pull request and we can discus the changes and merge them.
