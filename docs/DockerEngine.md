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
Described in a **Dockerfile**.  

<p align = "center">
  ![Docker_internals](https://github.com/syuja/ucsc/blob/samir/imgs/docker_internals.png) 
  </p>
