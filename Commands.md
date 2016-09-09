# Useful Commands:
  
---

## Docker Commands:   
- `docker images`:  lists all images on local system (useful for pushing)  
- `docker run <image_name>`:   tells docker to run image; **pulls** image if not found locally    
  - `docker run syuja/whalesay cowsay boo`: executes cowsay program inside the image  
- `docker build -t <image_name> <location_of_Dockerfile>`: -t flag indicates name of image  
- `docker push <syuja/whalesay` : need to have a names space before pushing (**syuja**/whalesay)  
- `docker login --username=syuja` : login before pushing  
- `docker tag <img_id> <syuja/whalesay:latest`: allows you to add namespace/tag the image before uploading  
- `docker rmi -f <imd_id>|<img_name>` : removes images from local system   

#### Dockerfile:  
* **FROM**: which image my image is based on  
* **RUN**: runs commands inside the image  
* **CMD**: instructs software to run once the image is loaded  
