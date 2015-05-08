######################
### INIT #############
######################

SCRIPTDIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
echo 'source $SCRIPTDIR/config' >> ~/.bashrc
source ~/.bashrc
ln -s $SCRIPTDIR/.hg.conf ~/.hg.conf
chmod 600 ~/.hg.conf
cp my.cnf /etc/my.cnf

######################
### NETWORK ##########
######################

iptables -I INPUT 1 -p tcp --dport 443 -j ACCEPT
iptables -I INPUT 1 -p tcp --dport 80 -j ACCEPT
service iptables save
service iptables restart
sed -i 's/enforcing/disabled/g' /etc/selinux/config
echo 0 > /selinux/enforce

######################
### DEPENDENCIES #####
######################

wget http://download.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm
rpm -ivh epel-release-6-8.noarch.rpm
yum update
yum upgrade
yum install hg wget mysql mysql-server httpd git mysql-devel.x86_64 libimobiledevice-devel.x86_64 libplist-devel.x86_64 usbmuxd-devel.x86_64 gcc libpng*x86* libstdc++-* tcsh R vim nano

######################
### SYMLINKS #########
######################

ln -s /var/www /usr/local/apache
ln -s /var/www /var/www/html
ln -s /var/www /var/www/htdocs
ln -s /var/www/cgi-bin /usr/lib/cgi-bin
ln -s /var/www/cgi-bin /var/www/cgi-bin-dlv04c  #addresses bug with kent src compilation

######################
### APACHE ###########
######################

sed -i 's/^DocumentRoot.*/DocumentRoot "\/var\/www\"/g' /etc/httpd/conf/httpd.conf
# activate xbithack
cat <<EOF >> /etc/httpd/conf/httpd.conf
XBitHack on
<Directory /var/www/>
Options +Includes
</Directory>
EOF
service httpd start

######################
### SITE #############
######################

rsync -avzP rsync://hgdownload.cse.ucsc.edu/cgi-bin/ $CGI_BIN
rsync -avzP rsync://hgdownload.cse.ucsc.edu/htdocs/ $WEBROOT/

rm /var/www/trash
mkdir /var/www/trash
chmod 777 /var/www/trash
chown -R apache:apache /var/www
chown -R 755 /var/www

######################
### SOURCE ###########
######################

mkdir -p ~/bin/$MACHTYPE
mkdir -p ~/software
git clone http://genome-source.cse.ucsc.edu/samtabix.git ~/software/samtabix
cd ~/software/samtabix
make

#git clone git://genome-source.cse.ucsc.edu/kent.git
git clone https://github.com/ucscGenomeBrowser/kent ~/software/kent
cd ~/software/kent
git checkout -t -b beta origin/beta
git pull
sed -i 's/hgBeacon//g' ~/software/kent/src/hg/makefile
cd src
make clean
make

cp ~/software/kent/src/webBlat/webBlat /var/www/cgi-bin/
cp ~/software/kent/src/webBlat/webBlat.cfg /var/www/cgi-bin/

######################
### HG.CONF ##########
######################

cp ~/software/kent/src/product/ex.hg.conf /var/www/cgi-bin/hg.conf
#HG.CONF, based on http://genomewiki.ucsc.edu/index.php/Enabling_hgLogin
sed -i 's/defaultGenome=.*/defaultGenome='"$DEFAULTGENOME"'/g' /var/www/cgi-bin/hg.conf
sed -i 's/wiki\.host=.*/wiki\.host='"$HOST"'/g' /var/www/cgi-bin/hg.conf
sed -i 's/login\.browserName=.*/login\.browserName='"$BROWSERNAME"'/g' /var/www/cgi-bin/hg.conf
sed -i 's/login\.browserAddr=.*/login\.browserAddr=http:\/\/'"$HOST"'/g' /var/www/cgi-bin/hg.conf
sed -i 's/login\.mailSignature=Greenome Browser Staff=.*/login\.mailSignature=Greenome Browser Staff/g' /var/www/cgi-bin/hg.conf
sed -i 's/login\.mailReturnAddr=.*/login\.mailReturnAddr='"$EMAILADDRESS"'/g' /var/www/cgi-bin/hg.conf

######################
### MYSQL ############
######################

cp ~/ucsc/my.cnf /etc/my.cnf
service mysqld restart
mysqladmin -u $SQL_USER password $SQL_PASSWORD
wget -O $MYSQLDATA/hgcentral.sql http://hgdownload.cse.ucsc.edu/admin/hgcentral.sql
$MYSQL -e "create database hgFixed"
$MYSQL -e "create database hgcentral"
$MYSQL hgcentral < hgcentral.sql
chmod -R 755 /var/lib/mysql/
service mysqld restart

${MYSQL} -e "GRANT SELECT, INSERT, UPDATE, DELETE, CREATE, DROP, ALTER, CREATE TEMPORARY TABLES on hgcentral.* TO browser@localhost IDENTIFIED BY 'genome';" mysql
${MYSQL} -e "GRANT SELECT, INSERT, UPDATE, DELETE, CREATE, DROP, ALTER, CREATE TEMPORARY TABLES on hgfixed.* TO browser@localhost IDENTIFIED BY 'genome';" mysql
${MYSQL} -e "GRANT FILE on *.* TO browser@localhost IDENTIFIED BY 'genome';" mysql
${MYSQL} -e "GRANT SELECT on mysql.* TO browser@localhost IDENTIFIED BY 'genome';" mysql
${MYSQL} -e "GRANT SELECT, INSERT, UPDATE, DELETE, CREATE, DROP, ALTER on hgcentral.* TO readwrite@localhost IDENTIFIED BY 'update';" mysql
${MYSQL} -e "FLUSH PRIVILEGES;"











































INSTALL CUSTOM GENOME
cd /gbdb
mkdir b73v2
faToTwoBit b73v2.fa b73v2.2bit
twoBitInfo b73v2.2bit stdout | awk '{printf "%s\t%s\t/gbdb/b73v2/b73v2.2bit\n", $1,$2}' > chromInfo.tab



BLAT
use hgcentral;
INSERT INTO blatServers (db, host, port, isTrans, canPcr) VALUES ("b73v2", "leopold.iplantcollaborative.org",17777,0,1);
INSERT INTO blatServers (db, host, port, isTrans, canPcr) VALUES ("b73v2", "leopold.iplantcollaborative.org",17778,1,0);
exit


IDEOGRAM
# edit /gbdb/kent/src/utils/qa/makeCytoBandIdeo.csh with the following lines ##########
# set sql=/gbdb/kent/src/hg/lib/cytoBandIdeo.sql
# source /gbdb/kent/src/utils/qa/qaConfig.csh
#######################################################################################
/gbdb/kent/src/utils/qa/makeCytoBandIdeo.csh
# add to trackDb.ra ###################################################################
track cytoBandIdeo
shortLabel Chromosome Band (Ideogram)
longLabel Ideogram for Orientation
group map
visibility dense
type bed 4 +
#######################################################################################
hgTrackDb ./ b73v2 trackDb /gbdb/kent/src/hg/lib/trackDb.sql ./



# add track
cd /gbdb/b73v2/tracks/b73v2
hgBbiDbLink b73v2 testwig tracks/z4g3c12.bw
hgTrackDb ./ b73v2 trackDb /gbdb/kent/src/hg/lib/trackDb.sql ./


# delete other ‘groups’ from hgcentral.clade and delete sacCer3 db


########
#FOR EACH GENOME
########
${MYSQL}
use hgcentral;

INSERT INTO dbDb (name, description, nibPath, organism, defaultPos, active, orderKey, genome, scientificName, htmlPath, hgNearOk, hgPbOk, sourceName, taxId)
VALUES ("b73v2", "Mar 2010", "/gbdb/b73v2", "Z. mays", "chr1:10459784-10469783", 1, 1, "Z. mays", "Zea mays", "/gbdb/b73v2/html/description.html", 0, 0, "b73 Refgen_V2", 12345);

INSERT INTO defaultDb (name, genome) VALUES ("b73v2", "Z. mays");

INSERT INTO clade (name,label,priority) VALUES ("monocot","Monocot",1);

INSERT INTO genomeClade (genome,clade,priority) VALUES ("Z. mays","monocot",1)
# create grp table for genome
# from here

use b73v2;

# exit mysql

hgsql b73v2 < /gbdb/kent/src/hg/lib/grp.sql
hgsql b73v2 < /gbdb/kent/src/hg/lib/chromInfo.sql
hgsql b73v2 < /gbdb/kent/src/hg/lib/gap.sql
hgsql b73v2 -e 'load data local infile "chromInfo.tab" into table chromInfo;'







####################### BLAT BOOTUP ################################
cd /gbdb/b73v2
gfServer -tileSize=7 -canStop start leopold.iplantcollaborative.org 17777 -stepSize=5 b73v2.2bit &
gfServer -trans -canStop start leopold.iplantcollaborative.org 17778 b73v2.2bit &




make tracks searchable

hgLoadBed b73v2 hitdomain /gbdb/b73v2/bbi/hitdomain.bed
hgFindSpec . b73v2 hgFindSpec /gbdb/kent/src/hg/lib/hgFindSpec.sql .
hgTrackDb ./ b73v2 trackDb /gbdb/kent/src/hg/lib/trackDb.sql ./

scrap

# awk '{print $1,0,$2,$1,"gpos"}' OFS='\t' b73v2.chrom.sizes > cytoBand.txt #use script instead
# hgsql b73v2 < /gbdb/kent/src/hg/lib/cytoBandIdeo.sql
# hgsql b73v2 -e 'load data local infile "/gbdb/b73v2/cytoBand.txt" into table cytoBandIdeo;'

#test db config with join
SELECT d.name,d.orderKey,g.genome,g.priority,g.clade,d.scientificName FROM dbDb d, genomeClade g WHERE d.organism = g.genome ORDER by d.orderKey;


INSERT INTO clade (name,label,priority) VALUES ("dicot","Dicot",1);


create database tair10;

INSERT INTO dbDb (name, description, nibPath, organism, defaultPos, active, orderKey, genome, scientificName, htmlPath, hgNearOk, hgPbOk, sourceName, taxId)
VALUES ("tair10", "TAIR10 (Feb 2011)", "/gbdb/tair10", "A. thaliana", "chr1:1000000-2000000", 1, 1, "A. thaliana", "Arabidopsis thaliana", "/gbdb/tair10/html/description.html", 0, 0, "TAIR10", 12346);

INSERT INTO defaultDb (name, genome) VALUES ("tair10", "A. thaliana");
INSERT INTO genomeClade (genome,clade,priority) VALUES ("A. thaliana","dicot",1)

use tair10;
CREATE TABLE grp (
     name varchar(255) not null,    # Group name.  Connects with trackDb.grp
     label varchar(255) not null,    # Label to display to user
     priority float not null,    # 0 is top
               #Indices
     PRIMARY KEY(name)
 );
INSERT grp VALUES("user", "Custom Tracks", 1);
INSERT grp VALUES("map", "Mapping and Sequencing Tracks", 2);
INSERT grp VALUES("genes", "Genes and Gene Prediction Tracks", 3);
INSERT grp VALUES("pubs", "Literature", 3.5);
INSERT grp VALUES("rna", "mRNA and EST Tracks", 4);
INSERT grp VALUES("regulation", "Expression and Regulation", 5);
INSERT grp VALUES("compGeno", "Comparative Genomics", 6);
INSERT grp VALUES("varRep", "Variation and Repeats", 7);
INSERT grp VALUES("x", "Experimental Tracks", 10);

BLAT
use hgcentral;
INSERT INTO blatServers (db, host, port, isTrans, canPcr) VALUES ("tair10", "leopold.iplantcollaborative.org",17781,0,1);
INSERT INTO blatServers (db, host, port, isTrans, canPcr) VALUES ("tair10", "leopold.iplantcollaborative.org",17782,1,0);
exit


hgsql tair10 < /gbdb/kent/src/hg/lib/chromInfo.sql
hgsql tair10 < /gbdb/kent/src/hg/lib/gap.sql
hgsql tair10 -e 'load data local infile "chromInfo.tab" into table chromInfo;'
IDEOGRAM
# edit /gbdb/kent/src/utils/qa/makeCytoBandIdeo.csh with the following lines ##########
# set sql=/gbdb/kent/src/hg/lib/cytoBandIdeo.sql
# source /gbdb/kent/src/utils/qa/qaConfig.csh
#######################################################################################
/gbdb/kent/src/utils/qa/makeCytoBandIdeo.csh
# add to trackDb.ra ###################################################################
track cytoBandIdeo
shortLabel Chromosome Band (Ideogram)
longLabel Ideogram for Orientation
group map
visibility dense
type bed 4 +
#######################################################################################
hgTrackDb ./ tair10 trackDb /gbdb/kent/src/hg/lib/trackDb.sql ./


############### MYSQL PERMISSIONS ################## modified from ex.MySQLUserPerms.sh

SQL_USER="root"
SQL_PASSWORD="genome"
MySQL_USER=${SQL_USER}
export SQL_USER MySQL_USER SQL_PASSWORD

MYSQL="mysql -u${MySQL_USER} -p${SQL_PASSWORD}"
export MYSQL
${MYSQL} -e "show tables;" mysql

#enter db list in this line
for DB in sacCer3 b73v2 hgcentral hgFixed
do
    ${MYSQL} -e "GRANT SELECT, INSERT, UPDATE, DELETE, CREATE, DROP, ALTER, CREATE TEMPORARY TABLES on ${DB}.* TO browser@localhost \
    IDENTIFIED BY 'genome';" mysql
done
${MYSQL} -e "GRANT FILE on *.* TO browser@localhost IDENTIFIED BY 'genome';" mysql

for DB in b73v2 hgFixed sacCer3
do
    ${MYSQL} -e "GRANT SELECT, CREATE TEMPORARY TABLES on \
    ${DB}.* TO readonly@localhost IDENTIFIED BY 'access';" mysql
done
for DB in mysql
do
    ${MYSQL} -e "GRANT SELECT on \
    ${DB}.* TO browser@localhost IDENTIFIED BY 'genome';" mysql
done
for DB in hgcentral
do
    ${MYSQL} -e "GRANT SELECT, INSERT, UPDATE, DELETE, CREATE, DROP, ALTER on ${DB}.* TO readwrite@localhost \
    IDENTIFIED BY 'update';" mysql
done
${MYSQL} -e "FLUSH PRIVILEGES;"
