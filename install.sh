######################
### TODO #############
######################

# clear from hgcentral: defaultDb, clade, genomeClade, dbDb, dbDbArch, liftOverChain, hubPublic, targetDb





######################
### INIT #############
######################

SCRIPTDIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
echo "source $SCRIPTDIR/config" >> ~/.bashrc
source ~/.bashrc
ln -s $SCRIPTDIR/.hg.conf ~/.hg.conf
chmod 600 ~/.hg.conf
cp $SCRIPTDIR/my.cnf /etc/my.cnf


######################
### DOCKER ###########
######################
yum install -y man
iptables -F

#centos6
yum install -y  mysql mysql-server httpd git mysql-devel.x86_64

#centos7
yum install -y mariadb-server.x86_64 httpd git mariadb-devel.x86_64

yum install -y gcc libpng-devel-1.5.13-5.el7.x86_64 libstdc++-* make
#libimobiledevice-devel.x86_64 libplist-devel.x86_64 usbmuxd-devel.x86_64

######################
### DEBIAN ###########
######################

apt-get update -y
apt-get install -y wget apache2 mysql-server git libpng++-dev gcc libc++-dev libstdc++-4.9-dev make libssl-dev libmysqlclient-dev


#########################
ln -s $WEBROOT /usr/local/apache
rmdir $WEBROOT/html
ln -s $WEBROOT $WEBROOT/html
ln -s $WEBROOT $WEBROOT/htdocs
ln -s $CGI_BIN /usr/lib/cgi-bin
ln -s $CGI_BIN $WEBROOT/cgi-bin- #if $USER not defined
ln -s $CGI_BIN $WEBROOT/cgi-bin-root

rsync -avzP rsync://hgdownload.cse.ucsc.edu/cgi-bin/ $CGI_BIN
rsync -avzP rsync://hgdownload.cse.ucsc.edu/htdocs/ $WEBROOT/

rm -f $WEBROOT/trash
mkdir $WEBROOT/trash
chmod 777 $WEBROOT/trash
#chown -R www-data:www-data $WEBROOT
chown -R apache:apache $WEBROOT
chown -R 755 $WEBROOT

mkdir -p $SWDIR
#ln -s $SWDIR ~/software
mkdir -p $SWDIR/bin/$MACHTYPE
ln -s $SWDIR/bin ~/bin
git clone http://genome-source.cse.ucsc.edu/samtabix.git $SWDIR/samtabix
cd $SWDIR/samtabix
make

git clone https://github.com/ucscGenomeBrowser/kent $SWDIR/kent
cd $SWDIR/kent
git checkout -t -b beta origin/beta
git pull
sed -i 's/hgBeacon//g' $SWDIR/kent/src/hg/makefile
sed -i 's/hgMirror//g' $SWDIR/kent/src/hg/makefile #hgMirror makefile breaks cgi make - -${USER} issue
cd src
make clean
make cgi


######################
### NETWORK ##########
######################

iptables -I INPUT 1 -p tcp --dport 443 -j ACCEPT
iptables -I INPUT 1 -p tcp --dport 80 -j ACCEPT
service iptables save
service iptables restart
sed -i 's/enforcing/disabled/g' /etc/selinux/config
echo 0 > /selinux/enforce

######################
### DEPENDENCIES #####
######################

yum update -y
yum install -y wget




cd ~
curl -o epel.rpm https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
rpm -ivh epel.rpm
yum update -y




yum -y install httpd mysql mysql-server httpd git mysql-devel.x86_64 libimobiledevice-devel.x86_64 libplist-devel.x86_64 usbmuxd-devel.x86_64 gcc libpng*x86* libstdc++-* tcsh R vim nano
yum -y update

######################
### SYMLINKS #########
######################

ln -s $WEBROOT /usr/local/apache
ln -s $WEBROOT $WEBROOT/html
ln -s $WEBROOT $WEBROOT/htdocs
ln -s $CGI_BIN /usr/lib/cgi-bin
ln -s $CGI_BIN $WEBROOT/cgi-bin-$USER
ln -s $CGI_BIN $WEBROOT/cgi-bin-root

######################
### APACHE ###########
######################

sed -i 's/^DocumentRoot.*/DocumentRoot "\/var\/www\"/g' /etc/httpd/conf/httpd.conf
# activate xbithack
cat <<EOF >> /etc/httpd/conf/httpd.conf
XBitHack on
<Directory /var/www/>
Options +Includes
</Directory>
EOF
service httpd restart
# for docker, use:
/usr/sbin/apachectl



######################
### SITE #############
######################

rsync -avzP rsync://hgdownload.cse.ucsc.edu/cgi-bin/ $CGI_BIN
rsync -avzP rsync://hgdownload.cse.ucsc.edu/htdocs/ $WEBROOT/

rm $WEBROOT/trash
mkdir$WEBROOT/trash
chmod 777$WEBROOT/trash
chown -R apache:apache $WEBROOT
chown -R 755 $WEBROOT

######################
### SOURCE ###########
######################

mkdir -p $SWDIR
ln -s $SWDIR ~/software
mkdir -p $SWDIR/bin/$MACHTYPE
ln -s $SWDIR/bin ~/bin
git clone http://genome-source.cse.ucsc.edu/samtabix.git $SWDIR/samtabix
cd $SWDIR/samtabix
make

#git clone git://genome-source.cse.ucsc.edu/kent.git
git clone https://github.com/ucscGenomeBrowser/kent $SWDIR/kent
cd $SWDIR/kent
git checkout -t -b beta origin/beta
git pull
sed -i 's/hgBeacon//g' $SWDIR/kent/src/hg/makefile
cd src
make clean
make

rm -f $CGI_BIN/webBlat
cp -f $SWDIR/kent/src/webBlat/webBlat $CGI_BIN
rm -f $CGI_BIN/webBlat.cfg
cp -f $SWDIR/kent/src/webBlat/webBlat.cfg $CGI_BIN

######################
### HG.CONF ##########
######################

cp $SWDIR/kent/src/product/ex.hg.conf $CGI_BIN/hg.conf
sed -i 's/defaultGenome=.*/defaultGenome='"$DEFAULTGENOME"'/g' $CGI_BIN/hg.conf
sed -i 's/wiki\.host=.*/wiki\.host='"$HOST"'/g' $CGI_BIN/hg.conf
sed -i 's/login\.browserName=.*/login\.browserName='"$BROWSERNAME"'/g' $CGI_BIN/hg.conf
sed -i 's/login\.browserAddr=.*/login\.browserAddr=http:\/\/'"$HOST"'/g' $CGI_BIN/hg.conf
sed -i 's/login\.mailSignature=Greenome Browser Staff=.*/login\.mailSignature=Greenome Browser Staff/g' $CGI_BIN/hg.conf
sed -i 's/login\.mailReturnAddr=.*/login\.mailReturnAddr='"$EMAILADDRESS"'/g' $CGI_BIN/hg.conf
sed -i 's/custromTracks\.host=.*/custromTracks\.host=localhost/g' $CGI_BIN/hg.conf
sed -i 's/customTracks\.host=.*/customTracks\.host=localhost/g' $CGI_BIN/hg.conf
sed -i 's/customTracks\.user=.*/customTracks\.user=readwrite/g' $CGI_BIN/hg.conf
sed -i 's/customTracks\.password=.*/customTracks\.password=update/g' $CGI_BIN/hg.conf
sed -i 's#customTracks\.tmpdir=.*#customTracks\.tmpdir='$WEBROOT/trash/ct'#g' $CGI_BIN/hg.conf

# PUT IN INFO FOR USER AND PASS HERE FOR CUSTOMTRACKS

######################
### MYSQL ############
######################

rm -f /etc/my.cnf
cp $SCRIPTDIR/my.cnf /etc/my.cnf
service mysqld restart # not on docker
mysqladmin -u $SQL_USER password $SQL_PASSWORD
wget -O $MYSQLDATA/hgcentral.sql http://hgdownload.cse.ucsc.edu/admin/hgcentral.sql
$MYSQL -e "create database hgFixed"
$MYSQL -e "create database hgcentral"
$MYSQL -e "create database customTrash"
$MYSQL hgcentral < $MYSQLDATA/hgcentral.sql
chmod -R 755 $MYSQLDATA
service mysqld restart

${MYSQL} -e "GRANT SELECT, INSERT, UPDATE, DELETE, CREATE, DROP, ALTER, CREATE TEMPORARY TABLES on hgcentral.* TO browser@localhost IDENTIFIED BY 'genome';" mysql
${MYSQL} -e "GRANT SELECT, INSERT, UPDATE, DELETE, CREATE, DROP, ALTER, CREATE TEMPORARY TABLES on hgfixed.* TO browser@localhost IDENTIFIED BY 'genome';" mysql
${MYSQL} -e "GRANT FILE on *.* TO browser@localhost IDENTIFIED BY 'genome';" mysql
${MYSQL} -e "GRANT SELECT on mysql.* TO browser@localhost IDENTIFIED BY 'genome';" mysql
${MYSQL} -e "GRANT SELECT, INSERT, UPDATE, DELETE, CREATE, DROP, ALTER on hgcentral.* TO readwrite@localhost IDENTIFIED BY 'update';" mysql
${MYSQL} -e "FLUSH PRIVILEGES;"
${MYSQL} -e "GRANT SELECT,INSERT,UPDATE,DELETE,CREATE,DROP,ALTER,INDEX on customTrash.* TO readwrite@localhost IDENTIFIED by 'update';" mysql
