mount vault:/vault /vault
docker run -h $HOSTNAME -v /vault:/vault -p 80:80 -it centos:7 bash
################################################################################

yum update -y

yum install -y \
 httpd \
 libimobiledevice-devel.x86_64 \
 usbmuxd-devel.x86_64 \
 libplist-devel.x86_64 \
 libpng-devel.x86_64 \
 openssl-static.x86_64 \
 mariadb-devel.x86_64 \
 ghostscript \
 mariadb-server.x86_64 # for mysql executable

pkill httpd
rm -fr /var/www
mkdir -p $WEBROOT
ln -s $WEBROOT /var/www

sed -i 's#^DocumentRoot.*#DocumentRoot "/var/www"#g' /etc/httpd/conf/httpd.conf # replace path here with $WEBROOT
# activate xbithack
echo -e 'XBitHack on\n'\
'<Directory /var/www/>\n'\
'Options +Includes\n'\
'</Directory>' >> /etc/httpd/conf/httpd.conf

ln -s $GBDIR /gbdb || :

/usr/sbin/apachectl

################################################################################
######### HG.CONF ##########
################################################################################


echo -e 'db.host='${SQLHOST}'\ndb.user='$SQL_USER'\ndb.password='$SQL_PASSWORD > $HOME/.hg.conf && chmod 600 $HOME/.hg.conf
chmod 600 ~/.hg.conf

rm -f $HGCONF && cp -f $SWDIR/kent/src/product/ex.hg.conf $HGCONF
sed -i 's/defaultGenome=.*/defaultGenome='"$DEFAULTGENOME"'/g' $HGCONF
sed -i 's/wiki\.host=.*/wiki\.host=HTTPHOST/g' $HGCONF
sed -i 's/central\.domain=.*/central\.domain=HTTPHOST/g' $HGCONF
sed -i 's/central\.host=.*/central\.host='"$SQLHOST"'/g' $HGCONF
sed -i 's/db\.host=.*/db\.host='"$SQLHOST"'/g' $HGCONF
sed -i 's/login\.browserName=.*/login\.browserName='"$BROWSERNAME"'/g' $HGCONF
sed -i 's/login\.browserAddr=.*/login\.browserAddr=http:\/\/'"$HOST"'/g' $HGCONF
sed -i 's/login\.mailSignature=Greenome Browser Staff=.*/login\.mailSignature=Greenome Browser Staff/g' $HGCONF
sed -i 's/login\.mailReturnAddr=.*/login\.mailReturnAddr='"$WIKIEMAIL"'/g' $HGCONF
sed -i 's/custromTracks\.host=.*/custromTracks\.host=localhost/g' $HGCONF
sed -i 's/customTracks\.host=.*/customTracks\.host='"$SQLHOST"'/g' $HGCONF
sed -i 's/customTracks\.user=.*/customTracks\.user=readwrite/g' $HGCONF
sed -i 's/customTracks\.password=.*/customTracks\.password=update/g' $HGCONF
sed -i 's#customTracks\.tmpdir=.*#customTracks\.tmpdir='$WEBROOT/trash/ct'#g' $HGCONF
sed -i 's#browser.documentRoot=.*#browser.documentRoot='$WEBROOT'#g' $HGCONF
