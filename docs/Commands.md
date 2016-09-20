# Useful Commands:
  
---

## Docker Commands:   
- `docker images`:  lists all images on local system (useful for pushing)  
- `docker run [-p, -P] <image_name[:]>`:   tells docker to run image; **pulls** image if not found locally; `-p` or `-P` map ports; `:` can tell which version if there are multiple versions(important for debugging)    
  - `docker run syuja/whalesay cowsay boo`: runs cowsay program inside the image  
  - `docker run ubuntu /bin/echo "hello world"`  
  - `docker run -t -i ubuntu /bin/bash`: `-t` assigns tty inside container, `-i` grabs stdin (interactive)  
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
- `docker run -d -P --name <name> <image_name> [commands]`: naming serves 2 purposes: 1) easier to remember 2) other containers can refer to it.  
  - `docker run -d -P --name web training/webapp python app.py`  
Can use `inspect`, `ps`, `rm` and `stop` to see the name.  

- `docker network ls`: lists the networks for the container  
- 2 networks drivers `bridge` and `overlay`: `bridge` limited to single host with multiple containers;   
- `docker network inspect <bridge>`: can be used to find the container's IP address  
- `docker network disconnect <network> <container>`: disconnects container, can never disconnect bridge   
  - networks are a good way to isolate containers   

You can create your own networks and add containers to them:  
- `docker network create -d bridge my-bridge-network`:  `-d` tells docker to use `bridge` driver (not overlay)  
- `docker network ls`: lists networks   
- `docker network inspect my-bridge-network`:  to see the new network ==> should be empty  
**add a container to a network**:  
- `docker run -d --network=my-bridge-network --name db training/postgress`:  
  - `-d` means as run as a daemon (detached), `--network` specifies to attach it  
  - if don't specify `--network`, it will run under the default `bridge` network   
  - use `docker network inspect <network>` to find the ip addresses  
- `docker network connect <network_name> <container>`: will bring container into a network; instead of leaving it in the default `bridge` network   
  - once they are connected to the same network, they can ping each other using their container names   
- `docker exec -it db bash`: `exec` is useful when a container is running in the background; `run` will try to pull again, but `exec` brings it to the foreground   
  

#### Docker Volumes:  (single accessible storage area within a file system)  
UnionFS : file system that works by layers,  
Data Volume: specially-designed directory within 1 or more containers   
bypasses the UnionFS  

Volumes: can be shared/reused among containers  
-changes to data volume will not be included when you update an image  
-data volumes persist even if the container itself is deleted  

The data in a volume exists outside of the container.  

There are several options.   
Perhaps, the most useful may be to mount a host file as a data volume.   

    docker run --rm -it -v ~/.bash_history:/root/.bash_history[:ro] ubuntu /bin/bash
`:ro` can specify to mount read-only  
  - `docker inspect <container>`: can help locate a volume, "Source" is the host location   
  - `docker run -d -P --name web -v /webapp training/webapp python app.py`: creates a volume at `/webapp` in the container  

