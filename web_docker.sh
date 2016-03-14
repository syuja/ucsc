docker run -h $HOSTNAME -v /vault:/vault -p 80:80 -it centos:7 bash

#!/bin/bash
web_init.sh
web_hgconf.sh
ln -s $GBDIR /gbdb
