######################
### INIT #############
######################

SCRIPTDIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
echo 'source $SCRIPTDIR/config' >> ~/.bashrc
source ~/.bashrc
ln -s $SCRIPTDIR/.hg.conf ~/.hg.conf
chmod 600 ~/.hg.conf
cp $SCRIPTDIR/my.cnf /etc/my.cnf

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

wget http://download.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm
rpm -ivh epel-release-6-8.noarch.rpm
yum update
yum upgrade
yum install hg wget mysql mysql-server httpd git mysql-devel.x86_64 libimobiledevice-devel.x86_64 libplist-devel.x86_64 usbmuxd-devel.x86_64 gcc libpng*x86* libstdc++-* tcsh R vim nano

######################
### SYMLINKS #########
######################

ln -s /var/www /usr/local/apache
ln -s /var/www /var/www/html
ln -s /var/www /var/www/htdocs
ln -s /var/www/cgi-bin /usr/lib/cgi-bin
ln -s /var/www/cgi-bin /var/www/cgi-bin-dlv04c  #addresses bug with kent src compilation

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
service httpd start

######################
### SITE #############
######################

rsync -avzP rsync://hgdownload.cse.ucsc.edu/cgi-bin/ $CGI_BIN
rsync -avzP rsync://hgdownload.cse.ucsc.edu/htdocs/ $WEBROOT/

rm /var/www/trash
mkdir /var/www/trash
chmod 777 /var/www/trash
chown -R apache:apache /var/www
chown -R 755 /var/www

######################
### SOURCE ###########
######################
mkdir -p $SWDIR
ln -s $SWDIR ~/software
mkdir -p $SWDIR/bin/$MACHTYPE
ln -s $SWDIR/bin ~/bin
git clone http://genome-source.cse.ucsc.edu/samtabix.git ~/software/samtabix
cd ~/software/samtabix
make

#git clone git://genome-source.cse.ucsc.edu/kent.git
git clone https://github.com/ucscGenomeBrowser/kent ~/software/kent
cd ~/software/kent
git checkout -t -b beta origin/beta
git pull
sed -i 's/hgBeacon//g' ~/software/kent/src/hg/makefile
cd src
make clean
make

cp ~/software/kent/src/webBlat/webBlat /var/www/cgi-bin/
cp ~/software/kent/src/webBlat/webBlat.cfg /var/www/cgi-bin/

######################
### HG.CONF ##########
######################

cp ~/software/kent/src/product/ex.hg.conf /var/www/cgi-bin/hg.conf
#HG.CONF, based on http://genomewiki.ucsc.edu/index.php/Enabling_hgLogin
sed -i 's/defaultGenome=.*/defaultGenome='"$DEFAULTGENOME"'/g' /var/www/cgi-bin/hg.conf
sed -i 's/wiki\.host=.*/wiki\.host='"$HOST"'/g' /var/www/cgi-bin/hg.conf
sed -i 's/login\.browserName=.*/login\.browserName='"$BROWSERNAME"'/g' /var/www/cgi-bin/hg.conf
sed -i 's/login\.browserAddr=.*/login\.browserAddr=http:\/\/'"$HOST"'/g' /var/www/cgi-bin/hg.conf
sed -i 's/login\.mailSignature=Greenome Browser Staff=.*/login\.mailSignature=Greenome Browser Staff/g' /var/www/cgi-bin/hg.conf
sed -i 's/login\.mailReturnAddr=.*/login\.mailReturnAddr='"$EMAILADDRESS"'/g' /var/www/cgi-bin/hg.conf

######################
### MYSQL ############
######################

cp ~/ucsc/my.cnf /etc/my.cnf
service mysqld restart
mysqladmin -u $SQL_USER password $SQL_PASSWORD
wget -O $MYSQLDATA/hgcentral.sql http://hgdownload.cse.ucsc.edu/admin/hgcentral.sql
$MYSQL -e "create database hgFixed"
$MYSQL -e "create database hgcentral"
$MYSQL hgcentral < hgcentral.sql
chmod -R 755 /var/lib/mysql/
service mysqld restart

${MYSQL} -e "GRANT SELECT, INSERT, UPDATE, DELETE, CREATE, DROP, ALTER, CREATE TEMPORARY TABLES on hgcentral.* TO browser@localhost IDENTIFIED BY 'genome';" mysql
${MYSQL} -e "GRANT SELECT, INSERT, UPDATE, DELETE, CREATE, DROP, ALTER, CREATE TEMPORARY TABLES on hgfixed.* TO browser@localhost IDENTIFIED BY 'genome';" mysql
${MYSQL} -e "GRANT FILE on *.* TO browser@localhost IDENTIFIED BY 'genome';" mysql
${MYSQL} -e "GRANT SELECT on mysql.* TO browser@localhost IDENTIFIED BY 'genome';" mysql
${MYSQL} -e "GRANT SELECT, INSERT, UPDATE, DELETE, CREATE, DROP, ALTER on hgcentral.* TO readwrite@localhost IDENTIFIED BY 'update';" mysql
${MYSQL} -e "FLUSH PRIVILEGES;"
