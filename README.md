### Deadline 10 Docker Containers

### Description
This repo containse all necesery files to build and run 10 docker containers with different services.

### Containers
- Deadline MongDB - 1 container, port 27017, stadard MongoDB setup, v 5.0.1
- Deadline Repository installer - 1 container, standard Deadline setup, no ssl
- Deadline Client installer - 1 container, standard Deadline Client setup
- Deadline Webservice - 1 container, standard Deadline Webservice setup, port 8081
- Deadline RCS - 1 container, standard Deadline RCS setup, port 8081 - NOT IMPLEMENTED
- Deadline Asset Server - 1 container, standard Deadline Asset Server setup, port 8081 - NOT IMPLEMENTED
- Deadline Balancer - 1 container, standard Deadline Balancer setup, port 8081 - NOT IMPLEMENTED
- Deadline Pulse - 1 container, standard Deadline Pulse setup, port 8081 - NOT IMPLEMENTED
- Deadline Monitor WebUI - 1 container, standard Deadline Monitor WebUI setup, port 8081 - NOT IMPLEMENTED



### How to run
run `docker-compose up` in the root directory of the project.
