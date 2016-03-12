
### APACHE

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
