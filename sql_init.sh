mount vault:/vault /vault
docker run -h $HOSTNAME -v /vault:/vault -p 3306:3306 -it centos:7 bash # copy config or add to vault for access
##################################################
yum update -y

yum install -y \
 mariadb-server.x86_64 \
 mariadb-devel.x86_64

 #pkill mysqld

rm -f /etc/my.cnf
ln -s $BROWSERDIR/my.cnf /etc/my.cnf
rmdir /var/lib/mysql
ln -s $MYSQLDATA /var/lib/mysql #shouldnt need this, why is is looking for socket here? look in hg.conf
mkdir /var/run/mysqld
chown mysql:mysql /var/run/mysqld
chown -R mysql:mysql $MYSQLDATA
#mysql_install_db --user=mysql
mysqld_safe --local-infile=1 &
