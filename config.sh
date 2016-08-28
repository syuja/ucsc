# PROCEDURE
# launch an admin container and run nfs_init.sh
# launch an admin container and run ugb_init.sh
# launch a  mysql container
# launch a    web container

export DBDBID="1ilMW4gv8XsECFuKpSlOFWVhO_04qiogVdQHYYxQF2ZM"


# PERSISTENT DATA LOCATIONS
export     GBDIR=/vault/gbdb       #location to store track and genome data
export     SWDIR=/vault/software   #location to store software
export BROWSERDIR=/vault/gbtest3   #location to store browser html and database

# HOST INFO
export        DOMAIN=$(dnsdomainname)
export       SQLHOST="msc4"

# BROWSER SETTINGS
export DEFAULTGENOME="Zea mays B73"
export   BROWSERNAME="The Greenome Browser"

# MISC
export    WIKIEMAIL="NOEMAIL"
export EMAILADDRESS="vera@genomics.fsu.edu"

# MYSQL ACCOUNTS
export     SQL_USER="root"
export SQL_PASSWORD="genome"

#############################################
#############################################

# usually doesn't need changing
export    MYSQLDATA=$BROWSERDIR/mysql
export      WEBROOT=$BROWSERDIR/www
export      CGI_BIN=${WEBROOT}/cgi-bin
export     MACHTYPE='x86_64'
export   MySQL_USER=${SQL_USER}
export        MYSQL="mysql -u${MySQL_USER} -p${SQL_PASSWORD}"
export      USE_SSL=1
export USE_SAMTABIX=1
export  SAMTABIXDIR="$SWDIR/samtabix/"
export HGCONF=$CGI_BIN/hg.conf


# add bins to path
export PATH=$SWDIR:$PATH
export PATH=$SWDIR/bin/x86_64:$PATH
export PATH=$SAMTABIXDIR:$PATH