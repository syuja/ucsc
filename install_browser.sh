yum update -y && yum install -y \
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
mariadb-server.x86_64

# create .hg.conf
echo -e 'db.host='${SQLHOST}'\ndb.user='$SQL_USER'\ndb.password='$SQL_PASSWORD > $HOME/.hg.conf && chmod 600 $HOME/.hg.conf

# create mysql config file
rm -f $BROWSERDIR/my.cnf
echo -e '[mysqld]\n'\
'datadir                ='$MYSQLDATA'\n'\
'user                   =mysql\n'\
'symbolic-links         =1\n'\
'loose-local-infile     =1\n'\
'default-storage-engine =MYISAM\n'\
'[mysqld_safe]\n'\
'log-error              =/var/log/mysqld.log\n'\
'pid-file               =/var/run/mysqld/mysqld.pid\n'\
'socket                 =/var/lib/mysql/mysql.sock\n'\
 > $BROWSERDIR/my.cnf
chmod 755 $BROWSERDIR/my.cnf
rm -f /etc/my.cnf
ln -s $BROWSERDIR/my.cnf /etc/my.cnf

# define mysql socketfile 
mkdir -p $MYSQLDATA
rmdir /var/lib/mysql
ln -s $MYSQLDATA /var/lib/mysql #shouldnt need this, why is is looking for socket here? look in hg.conf
mkdir /var/run/mysqld
chown mysql:mysql /var/run/mysqld
chown -R mysql:mysql $MYSQLDATA

# setup mysql database and root account
mysql_install_db --user=mysql
mysqld_safe --local-infile=1 &
mysqladmin -u $SQL_USER password $SQL_PASSWORD

# setup minimum browser tables
$MYSQL -e "create database hgFixed"
$MYSQL -e "create database hgcentral"
$MYSQL -e "create database customTrash"
curl -so $MYSQLDATA/hgcentral.sql http://hgdownload.cse.ucsc.edu/admin/hgcentral.sql
$MYSQL hgcentral < $MYSQLDATA/hgcentral.sql # replace this with creating the databases manually or modify sql statements
chown -R mysql:mysql $MYSQLDATA #hgcentral db in mysqldata is created by root!
#chmod -R 755 $MYSQLDATA #necessary?

# allow root to do anything from anywhere
${MYSQL} -e "GRANT ALL PRIVILEGES on *.* TO root@'%' IDENTIFIED BY '"$SQL_PASSWORD"' WITH GRANT OPTION;" mysql
${MYSQL} -e "GRANT SELECT on hgFixed.* TO readonly@'%' IDENTIFIED BY 'access';" mysql
${MYSQL} -e "GRANT SELECT on hgFixed.* TO readonly@'localhost' IDENTIFIED BY 'access';" mysql
# allow webserver to modify hgcentral and customTrash
${MYSQL} -e "GRANT SELECT,INSERT,UPDATE,DELETE,CREATE,DROP,ALTER on hgcentral.* TO readwrite@'%."$DOMAIN"' IDENTIFIED BY 'update';" mysql
${MYSQL} -e "GRANT SELECT,INSERT,UPDATE,DELETE,CREATE,DROP,ALTER on hgcentral.* TO readwrite@'localhost' IDENTIFIED BY 'update';" mysql
${MYSQL} -e "GRANT SELECT,INSERT,UPDATE,DELETE,CREATE,DROP,ALTER,INDEX on customTrash.* TO readwrite@'%."$DOMAIN"' IDENTIFIED by 'update';" mysql
${MYSQL} -e "GRANT SELECT,INSERT,UPDATE,DELETE,CREATE,DROP,ALTER,INDEX on customTrash.* TO readwrite@'localhost' IDENTIFIED by 'update';" mysql
${MYSQL} -e "FLUSH PRIVILEGES;"

# download latest browser site from UCSC
mkdir -p $CGI_BIN
rsync -az rsync://hgdownload.cse.ucsc.edu/cgi-bin/ $CGI_BIN
rsync -az rsync://hgdownload.cse.ucsc.edu/htdocs/ $WEBROOT/

# make symlinks to address bugs in file references
ln -s $WEBROOT $WEBROOT/html
ln -s $WEBROOT $WEBROOT/htdocs
ln -s $CGI_BIN /usr/lib/cgi-bin
ln -s $CGI_BIN $WEBROOT/cgi-bin- #if $USER not defined
ln -s $CGI_BIN $WEBROOT/cgi-bin-root

# fix permissions for website data
rm -fr $WEBROOT/trash
mkdir -p $WEBROOT/trash
chmod 777 $WEBROOT/trash
chown -R apache:apache $WEBROOT
chown -R 755 $WEBROOT

# compile browser from source
cd $SWDIR/kent/src
make clean
make all

# copy webBlat to cgi-bin
rm -f $CGI_BIN/webBlat
cp -f $SWDIR/kent/src/webBlat/webBlat $CGI_BIN
rm -f $CGI_BIN/webBlat.cfg
cp -f $SWDIR/kent/src/webBlat/webBlat.cfg $CGI_BIN
