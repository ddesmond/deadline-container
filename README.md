### Deadline 10 Docker Containers
![deadline_container.png](deadline_container.png)
### Description
This repo containse all necesery files to build and run 10 docker containers with different services.

### Containers
- Deadline MongDB - 1 container, port 27017, stadard MongoDB setup, v 5.0.1
- Deadline Repository installer - 1 container, standard Deadline setup, no ssl
- Deadline Client installer - 1 container, standard Deadline Client setup
- Deadline Webservice - 1 container, standard Deadline Webservice setup, port 8082
- Deadline RCS - 1 container, standard Deadline RCS setup, port 8081 
- Deadline Asset Server - 1 container, standard Deadline Asset Server setup, port 8081 - NOT IMPLEMENTED
- Deadline Balancer - 1 container, standard Deadline Balancer setup, port 8081 - NOT IMPLEMENTED
- Deadline Pulse - 1 container, standard Deadline Pulse setup, port 8081 - NOT IMPLEMENTED
- Deadline Monitor WebUI - 1 container, standard Deadline Monitor WebUI setup, port 8081 - NOT IMPLEMENTED

### How to run
Clone the repo and download the Deadline installer from the official website. Place the installer in the install directory of the project. Edit the setup sh files to match your deadline version you are installing (TODO: add env var vor deadline versions). Then
run `docker-compose up` in the root directory of the project.
Edit the install/connetion.ini file to match your MongoDB connection string.
Edit the install/deadline.ini file to match your Deadline setup.

### Notes
It can take a while to launch all containers and services, so be patient.
Containers have dependencies, so they will be started in the following order:
```
1. MongoDB
2. Repository - checks if repository is already installed, if not it installs it
3. Client - checks if client is already installed, if not it installs it
4. Webservice - checks if webservice-client files  are already installed, if not it waits until the files are there
5. RCS - checks if RCS-client files are already installed, if not it waits until the files are there
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