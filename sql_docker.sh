mount -t nfs vault:/vault /vault
docker run -h $HOSTNAME -v /vault:/vault -p 3306:3306 -it centos:7 bash # copy config or add to vault for access
#source config
sql_yum.sh
sql_conf.sh
nsf_sql_perms.sh
