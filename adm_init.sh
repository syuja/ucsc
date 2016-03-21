docker run -h $HOSTNAME -v /vault:/vault -p 80:80 -it centos:7 bash
###################################################################

yum update -y

yum install -y \
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
mariadb-server.x86_64 # for mysql executable

ln -s $SWDIR/bin ~/bin
