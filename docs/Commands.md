# Useful Commands:
  
---

## Docker Commands:   
- `docker images`:  lists all images on local system (useful for pushing)  
- `docker run [-p, -P] <image_name[:]>`:   tells docker to run image; **pulls** image if not found locally; `-p` or `-P` map ports; `:` can tell which version if there are multiple versions(important for debugging)    
  - `docker run syuja/whalesay cowsay boo`: executes cowsay program inside the image  
  - `docker run ubuntu /bin/echo "hello world"`  
  - `docker run -t -i ubuntu /bin/bash`: `-t` gets terminal inside container, `-i` grabs [stdin] (interactive)  
  - `docker run -d ubuntu /bin/sh -c "while true; do echo hello world; sleep 1; done"`:  `-d` runs in the bg  
- `docker ps [-l-a]`: shows running process for all containers; gives container names; `-l` shows last container; `-a` stopped containers   
-  `docker logs [-f] <container_name>`: looks inside the container; `-f` causes it to behave like `tail -f`    
-  `docker stop <container_name>`: stops it and returns its name; (required before rm)    
- `docker build -t <image_name> <location_of_Dockerfile>`: -t flag indicates name of image  
- `docker push <syuja/whalesay` : need to have a names space before pushing (**syuja**/whalesay)  
- `docker pull <image[:version]`: useful for pre-loading an image  
- `docker login --username=syuja` : login before pushing  
- `docker tag <img_id> <syuja/whalesay:latest`: allows you to add namespace/tag the image before uploading  
- `docker rmi -f <imd_id>|<img_name>` : removes images from local system; (make sure no containers based on it)  
- `docker rm <container_name>`: removes containers (not images)  
- `docker port <container_name> <internal_port>`: input internal port, returns public-facing (host) corresponding port  
  - `docker port adoring_knuth 5000`: returns 32770 which is external port  
`-P`: makes ports visible outside of the container  
`-p`: allows mappings;   
  - say that I have two containers each uses port 50000; I can map to 2 different ports on host so that I can test both.  
- `docker top <container_name>`: shows process running inside the container  
- `docker inspect <container_name>`: shows JSON with configuration and status info   
- `docker search <description>`: allows you to search existing docker images;  
- `docker commit -m -a [container] [username/image_name[:ver]`: to create your own image; `-m` for message, `-a` for author, `container` and `target` are required  

#### Dockerfile:  
* **FROM**: which image my image is based on  
* **RUN**: runs commands inside the image  
* **CMD**: instructs software to run once the image is loaded  
* 

#### Docker Networks:    
Important for connecting two containers on one host or on multiple hosts.  

