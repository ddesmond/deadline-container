### Deadline 10 Docker Containers - Unofficial - Not for production use - For testing purposes only / Beware of the Gremlins
![deadline_container.png](deadline_container.png)

### Description
This repo contains all necessary files to build and run Deadline 10 docker containers with different services.

### Containers
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
- Deadline Worker - 1 container, NOT IMPLEMENTED

### How to run
Clone the repo and download the Deadline installer from the official website. Place the installer in the install directory of the project. 
Edit the setup sh files to match your deadline version you are installing (TODO: add env var vor deadline versions). 

Edit the install/connetion.ini file to match your MongoDB connection string.
Edit the install/deadline.ini file to match your Deadline setup.

Then run `docker-compose up` in the root directory of the project.
After containers stabilize, open Deadline Monitor and disable Webservice password in the Repository settings for the web app services to work.

You can disable parts you dont need in the docker-compose.yml file. Feel free to copy and or edit the compose file to fit your specific needs.

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
```
Deadline Webservice container open file desriptors error - inotify error: If you get an error like this then set your host limits to a higher value:
Check your host machine ulimits and set them higher. Use the following snippet which was tested OK on ubuntu systems.
Execute the following commands in the terminal of the host machine where docker compose runs:
```bash
echo fs.inotify.max_user_instances=524288 | sudo tee -a /etc/sysctl.conf && sudo sysctl -p
```

The Deadline webservice needs no password set in the Repository settings to make connections and request work.
Point your Deadline Monitor to the installed Deadline Repository.
Add this entry to your hosts file:
```bash
127.0.0.1       d10mongodb d10client d10rcs d10repo d10webservice deadline-web-app-backend deadline-web-app-frontend
```


You can set a nginx instace to route the traffic to the Deadline Webservice and Deadline Monitor WebUI.