FROM centos:7

MAINTAINER "Daniel Vera" vera@genomics.fsu.edu

RUN yum update -y && yum install -y \
httpd \
rsync \
tcsh \
gcc \
libstdc++-devel.x86_64 \
libstdc++-static.x86_64 \
make \
perl \
git \
libpng-devel.x86_64 \
mariadb-devel.x86_64 \
mariadb-server.x86_64

CMD ["install_browser.sh"]
