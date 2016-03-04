docker run -v /vault:/vault -p 80:80 -it centos:7 bash # copy config or add to vault for access

#source config

yuminstall.sh

websetup.sh

kentBuild.sh

hgconf.sh

sql_update_path.sh

#sql_create.sh

sql_perms.sh

ln -s $GBDIR /gbdb #only for w22 which points to files in /gbdb
