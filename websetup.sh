######################
### TODO #############
######################

# clear from hgcentral: defaultDb, clade, genomeClade, dbDb, dbDbArch, liftOverChain, hubPublic, targetDb
# make sure host info is correct for custom tracks

######################
### INIT ############# replace with docker mounting to a static location
######################

SCRIPTDIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
echo "source $SCRIPTDIR/config" >> ~/.bashrc
source ~/.bashrc


######################
### DOCKER CENTOS ####
######################

# EXPOSE PORT 80:80
# COPY CONFIG FILE OR SET THESE IN DOCKERFILE
# MOUNT /vault to /vault

echo -e 'db.host='${HOST}'\ndb.user='$SQL_USER'\ndb.password='$SQL_PASSWORD > $HOME/.hg.conf && chmod 600 $HOME/.hg.conf
chmod 600 ~/.hg.conf

######################### SKIP 1
ln -s $WEBROOT /usr/local/apache # not needed anymore after docRoot fixed in hg.conf?
rmdir $WEBROOT/html
ln -s $WEBROOT $WEBROOT/html
ln -s $WEBROOT $WEBROOT/htdocs
ln -s $CGI_BIN /usr/lib/cgi-bin
ln -s $CGI_BIN $WEBROOT/cgi-bin- #if $USER not defined
ln -s $CGI_BIN $WEBROOT/cgi-bin-root
################################

rsync -az rsync://hgdownload.cse.ucsc.edu/cgi-bin/ $CGI_BIN
rsync -az rsync://hgdownload.cse.ucsc.edu/htdocs/ $WEBROOT/


rm -f $WEBROOT/trash
mkdir $WEBROOT/trash
chmod 777 $WEBROOT/trash
chown -R apache:apache $WEBROOT
chown -R 755 $WEBROOT


rm -f $CGI_BIN/webBlat
cp -f $SWDIR/kent/src/webBlat/webBlat $CGI_BIN #requires compilation
rm -f $CGI_BIN/webBlat.cfg
cp -f $SWDIR/kent/src/webBlat/webBlat.cfg $CGI_BIN


### APACHE
sed -i 's/^DocumentRoot.*/DocumentRoot "\/var\/www\"/g' /etc/httpd/conf/httpd.conf
# activate xbithack
cat <<EOF >> /etc/httpd/conf/httpd.conf
XBitHack on
<Directory /var/www/>
Options +Includes
</Directory>
EOF


/usr/sbin/apachectl
#service httpd restart
