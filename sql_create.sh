mysqladmin -u $SQL_USER password $SQL_PASSWORD

$MYSQL -e "create database hgFixed"
$MYSQL -e "create database hgcentral"
$MYSQL -e "create database customTrash"
curl -o $MYSQLDATA/hgcentral.sql http://hgdownload.cse.ucsc.edu/admin/hgcentral.sql
$MYSQL hgcentral < $MYSQLDATA/hgcentral.sql

chown -R mysql:mysql $MYSQLDATA #hgcentral db in mysqldata is created by root!
chmod -R 755 $MYSQLDATA #necessary?
