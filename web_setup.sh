######################
### TODO #############
######################

# clear from hgcentral: defaultDb, clade, genomeClade, dbDb, dbDbArch, liftOverChain, hubPublic, targetDb
# make sure host info is correct for custom tracks

######################
### INIT ############# replace with docker mounting to a static location
######################

# SCRIPTDIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
# echo "source $SCRIPTDIR/config" >> ~/.bashrc
# source ~/.bashrc



echo -e 'db.host='${SQLHOST}'\ndb.user='$SQL_USER'\ndb.password='$SQL_PASSWORD > $HOME/.hg.conf && chmod 600 $HOME/.hg.conf
chmod 600 ~/.hg.conf

mkdir -p $WEBROOT
#ln -s $WEBROOT /usr/local/apache # not needed anymore after docRoot fixed in hg.conf?
rmdir $WEBROOT/html || :
ln -s $WEBROOT $WEBROOT/html
ln -s $WEBROOT $WEBROOT/htdocs
ln -s $CGI_BIN /usr/lib/cgi-bin
ln -s $CGI_BIN $WEBROOT/cgi-bin- #if $USER not defined
ln -s $CGI_BIN $WEBROOT/cgi-bin-root

rsync -az rsync://hgdownload.cse.ucsc.edu/cgi-bin/ $CGI_BIN
rsync -az rsync://hgdownload.cse.ucsc.edu/htdocs/ $WEBROOT/


rm -f $WEBROOT/trash
mkdir $WEBROOT/trash
chmod 777 $WEBROOT/trash
chown -R apache:apache $WEBROOT
chown -R 755 $WEBROOT




### APACHE
sed -i 's#^DocumentRoot.*#DocumentRoot "'"$WEBROOT"'"#g' /etc/httpd/conf/httpd.conf # replace path here with $WEBROOT
# activate xbithack
echo -e 'XBitHack on\n'\
'<Directory '$WEBROOT'/>\n'\
'Options +Includes\n'\
'</Directory>' >> /etc/httpd/conf/httpd.conf


/usr/sbin/apachectl
#service httpd restart
