<a id='top'></a>
# Overview of Docker Engine:
  
---  
Client-server with 3 major components:  
  1. Server with daemon  
  2. REST api (specifies interface)  
  3. command line interface (CLI) client
  <p align = "center">
  ![Engine_Diagram](https://github.com/syuja/ucsc/blob/samir/imgs/docker_engine.png) 
  </p>


Docker daemon creates and manages objects (images, containers, networks, and data volumes).  
Docker daemon and client communicate through the REST api.
Docker client is the primary user interface to Docker.   


## Docker Internals:  
Docker image: read-only template with instructions for creating a Docker container  
It may be based on or extend other images.  
For example, an image may be based on Ubuntu with a additional utilities installed.  

It consists of series of layers transparently overlaid.  
When you update an application, a new layer is built and it  replaces  
only the layer it updates.

An image is described in  **Dockerfile**; each instruction creates a new layer.  
`FROM` - specify base image  
`MAINTAINER` -  
`RUN` - bash commands  
`ADD` - add file or dir  
`ENV` - create environment variable  
`CMD` - process to run when launching container from this image (usually .sh script)    
  
  <p align = "center">
  ![Docker_internals](https://github.com/syuja/ucsc/blob/samir/imgs/docker_internals.png) 
</p>

Docker container: a runnable instance of a Docker image. 
Run, start, stop, move or delete.     

Each container is an **"isolated and secure application platform"**, 
but it can be given access to resources on host or other containers.   
When Docker runs an image fro ma container, it adds a read-write layer on top.  

Docker Registry: library of images.   

Docker Services:  allows a __swarm__ of Docker nodes to work together.  
Docker Service appears as a single application, even though it is several concurrent replicas.  
**Services** offer **scalability**.   


#### What happens when you run a container?  
1. Docker pulls the image. 
2. Creates new container
3. Allocates a filesystem and mounts a read-write layer  
4. Allocates a network/bridge interface (for talking to localhost)   
5. Sets up an IP address  
6. Executes process you specify (CMD /bin/bash)  
7. Captures and provide application output logs to stdin (`-i` flag)  

### Underlying Technology:  
Written in `Go` and takes advantage of features in Linux kernel.  
  1. Uses **namespace** to provide isolated workspace  
   - `pid` namespace isolate the process  
   - `net` namespace isolate network interface  
   - `ipc` namespace manage InterProcess Comm  
   ...  

  2. Control groups:  
control groups in Linux limit an application to a specific set of resources.  

  3. Union File Systems: layers and lightweight    


Container format combines namespaces, control groups and UnionFS into wrapper.  

