pkill mysqld

rm -f /etc/my.cnf

#

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
 > /etc/my.cnf
#'[client]\n'\
#'loose-local-infile=1'

rmdir /var/lib/mysql
ln -s $MYSQLDATA /var/lib/mysql #shouldnt need this, why is is looking for socket here? look in hg.conf

mkdir /var/run/mysqld
chown mysql:mysql /var/run/mysqld

chown -R mysql:mysql $MYSQLDATA

mysql_install_db --user=mysql
mysqld_safe --local-infile=1 &
