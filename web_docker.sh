docker run -v /vault:/vault -p 80:80 -it centos:7 bash # copy config or add to vault for access

#source config

web_yum.sh

web_setup.sh

web_kent.sh

web_hgconf.sh

#sql_update_path.sh

#sql_create.sh

#sql_perms.sh

ln -s $GBDIR /gbdb #only for w22 which points to files in /gbdb
