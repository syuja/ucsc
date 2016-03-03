curl -o epel.rpm https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
rpm -ivh epel.rpm
yum update -y

yum install -y \\
 mariadb-server.x86_64\\
 httpd \\
 git \\ #not if precompiled in gbdb?
 mariadb-devel.x86_64 \\
 gcc \\ #not if precompiled in gbdb?
 libpng-devel-1.5.13-5.el7.x86_64 \\
 libstdc++-* \\ #not if precompiled in gbdb?
 make \\ #not if precompiled in gbdb?
 wget \\
 libimobiledevice-devel.x86_64 \\
 usbmuxd-devel.x86_64 \\
 libplist-devel.x86_64 \\
 libpng*x86* \\
 tcsh \\
 libstdc++-* \\
 
