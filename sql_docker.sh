mount -t nfs vault:/vault
docker run -v /vault:/vault -p 3306:3306 -it centos:7 bash # copy config or add to vault for access

#source config

sql_yum.sh

#web_setup.sh

#web_kent.sh

#web_hgconf.sh

sql_update_path.sh

#sql_create.sh

sql_perms.sh

#ln -s $GBDIR /gbdb #only for w22 which points to files in /gbdb
