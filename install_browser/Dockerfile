#sets base image for subsequent instructions
FROM centos:7

MAINTAINER "Daniel Vera" vera@genomics.fsu.edu

#executes commands in a new layer and commits results
RUN yum update -y && yum install -y \  #update upgrades to latest system software
httpd \                   #apache http server
rsync \                   #fast copying tool (like scp)
tcsh \                    #? additional shell
gcc \                     #compiler
libstdc++-devel.x86_64 \  #implementation of C++ libraries
libstdc++-static.x86_64 \ #static libraries
make \                    #makefiles
perl \                    #scripting
git \                     #
libpng-devel.x86_64 \     #png library contains C functions to handle png images
mariadb-devel.x86_64 \    #header and libraries
mariadb-server.x86_64     #server and tools

#run software
CMD ["install_browser.sh"]
