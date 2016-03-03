######################
### MYSQL ############
######################

rm -f /etc/my.cnf

echo -e '[mysqld]\n'\
'datadir='$MYSQLDATA'\n'\
'socket='$MYSQLDATA'/mysql.sock\n'\
'user=mysql\n'\
'symbolic-links=0\n'\
'loose-local-infile=1\n'\
'default-storage-engine=MYISAM\n'\
'[mysqld_safe]\n'\
'log-error=/var/log/mysqld.log\n'\ #accessible by mysql?
'pid-file=/var/run/mysqld/mysqld.pid\n'\
 > /etc/my.cnf
#'[client]\n'\
#'loose-local-infile=1'


mkdir /var/run/mysqld
chown -R mysql:mysql /var/run/mysqld
chown -R mysql:mysql $MYSQLDATA

mysqld_safe --local-infile=1 &

#service mysqld restart # not on docker
mysqladmin -u $SQL_USER password $SQL_PASSWORD

$MYSQL -e "create database hgFixed"
$MYSQL -e "create database hgcentral"
$MYSQL -e "create database customTrash"
wget -O $MYSQLDATA/hgcentral.sql http://hgdownload.cse.ucsc.edu/admin/hgcentral.sql
$MYSQL hgcentral < $MYSQLDATA/hgcentral.sql

chown -R mysql:mysql $MYSQLDATA #hgcentral db in mysqldata is created by root!
chmod -R 755 $MYSQLDATA #necessary?
#service mysqld restart
