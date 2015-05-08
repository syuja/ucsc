



























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
