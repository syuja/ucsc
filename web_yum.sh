#curl -o epel.rpm https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
#rpm -ivh epel.rpm
yum update -y

yum install -y \
 rsync \
 httpd \
 libimobiledevice-devel.x86_64 \
 usbmuxd-devel.x86_64 \
 libplist-devel.x86_64 \
 libpng-devel.x86_64 \
 openssl-static.x86_64 \
 mariadb-devel.x86_64 \
 tcsh \
 gcc \
 libstdc++-devel.x86_64 \
 libstdc++-static.x86_64 \
 make \
 perl




# git \ #not if precompiled in gbdb?
#libpng*x86* \
#libstdc++-* \
