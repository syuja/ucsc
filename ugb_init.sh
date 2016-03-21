
mkdir -p $MYSQLDATA
chown mysql:mysql $MYSQLDATA

#######################
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
#######################

chmod 755 $BROWSERDIR/my.cnf
rm -f /etc/my.cnf
ln -s $BROWSERDIR/my.cnf /etc/my.cnf

rmdir /var/lib/mysql
ln -s $MYSQLDATA /var/lib/mysql #shouldnt need this, why is is looking for socket here? look in hg.conf
mkdir /var/run/mysqld
chown mysql:mysql /var/run/mysqld
chown -R mysql:mysql $MYSQLDATA

mysql_install_db --user=mysql
mysqld_safe --local-infile=1 &

#echo -e 'db.host=localhost\ndb.user='$SQL_USER'\ndb.password='$SQL_PASSWORD > $HOME/.hg.conf && chmod 600 $HOME/.hg.conf
#chmod 600 ~/.hg.conf


mysqladmin -u $SQL_USER password $SQL_PASSWORD


$MYSQL -e "create database hgFixed"
$MYSQL -e "create database hgcentral"
$MYSQL -e "create database customTrash"
curl -o $MYSQLDATA/hgcentral.sql http://hgdownload.cse.ucsc.edu/admin/hgcentral.sql
$MYSQL hgcentral < $MYSQLDATA/hgcentral.sql # replace this with creating the databases manually or modify sql statements

chown -R mysql:mysql $MYSQLDATA #hgcentral db in mysqldata is created by root!
chmod -R 755 $MYSQLDATA #necessary?




######################
### SQL ##############
######################

# allow an admin node to do anything
${MYSQL} -e "GRANT FILE,SELECT,INSERT,UPDATE,DELETE,CREATE,DROP,ALTER,CREATE TEMPORARY TABLES on *.* TO root@'%."$DOMAIN"' IDENTIFIED BY \'"$SQL_PASSWORD"\';" mysql

# allow webserver to modify hgcentral and customTrash
${MYSQL} -e "GRANT SELECT,INSERT,UPDATE,DELETE,CREATE,DROP,ALTER on hgcentral.* TO readwrite@'%."$DOMAIN"' IDENTIFIED BY 'update';" mysql

${MYSQL} -e "GRANT SELECT,INSERT,UPDATE,DELETE,CREATE,DROP,ALTER,INDEX on customTrash.* TO readwrite@'%."$DOMAIN"' IDENTIFIED by 'update';" mysql

${MYSQL} -e "FLUSH PRIVILEGES;"

pkill mysqld

######################
### WEB ##############
######################

# clear from hgcentral: defaultDb, clade, genomeClade, dbDb, dbDbArch, liftOverChain, hubPublic, targetDb
# make sure host info is correct for custom tracks

mkdir -p $WEBROOT
ln -s $WEBROOT $WEBROOT/html
ln -s $WEBROOT $WEBROOT/htdocs
ln -s $CGI_BIN /usr/lib/cgi-bin
ln -s $CGI_BIN $WEBROOT/cgi-bin- #if $USER not defined
ln -s $CGI_BIN $WEBROOT/cgi-bin-root

rsync --delete -az rsync://hgdownload.cse.ucsc.edu/cgi-bin/ $CGI_BIN
rsync --delete -az rsync://hgdownload.cse.ucsc.edu/htdocs/ $WEBROOT/

# delete left toolbar from index
sed -i '/<TABLE WIDTH="100%" BORDER=0 CELLPADDING=0 CELLSPACING=0>/,/<\/TD><\/TR><\/TABLE>/d' $WEBROOT/index.html

rm -f $WEBROOT/trash
mkdir -p $WEBROOT/trash
chmod 777 $WEBROOT/trash
chown -R apache:apache $WEBROOT
chown -R 755 $WEBROOT

# RUN ON WEB SERVER

cd $SWDIR/kent/src
make clean
make cgi
make blatSuite

#post-build tasks
rm -f $CGI_BIN/webBlat
cp -f $SWDIR/kent/src/webBlat/webBlat $CGI_BIN
rm -f $CGI_BIN/webBlat.cfg
cp -f $SWDIR/kent/src/webBlat/webBlat.cfg $CGI_BIN

chown -R apache:apache $WEBROOT #cgis copied from source compilaton owned by root
