#curl -o epel.rpm https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
#rpm -ivh epel.rpm
yum update -y

yum install -y \
 httpd \
 libimobiledevice-devel.x86_64 \
 usbmuxd-devel.x86_64 \
 libplist-devel.x86_64 \
 libpng-devel.x86_64 \
 openssl-static.x86_64 \
 mariadb-devel.x86_64


### APACHE
pkill httpd
rm -fr /var/www
ln -s $WEBROOT /var/www


sed -i 's#^DocumentRoot.*#DocumentRoot "/var/www"#g' /etc/httpd/conf/httpd.conf # replace path here with $WEBROOT
# activate xbithack
echo -e 'XBitHack on\n'\
'<Directory /var/www/>\n'\
'Options +Includes\n'\
'</Directory>' >> /etc/httpd/conf/httpd.conf


/usr/sbin/apachectl
#service httpd restart
