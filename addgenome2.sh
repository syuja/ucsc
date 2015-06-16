$db=zeaMay3
assembly="AGPv3"
name="Z. mays"
taxonomic_id="12345"
clade="grasses"


mkdir -p $GBDIR/$db/bbi
mkdir -p $GBDIR/$db/html

echo "converting fa to 2bit"
faToTwoBit $fa $GBDIR/$db/genome.2bit

echo "getting chromosome info from 2bit"
twoBitInfo $GBDIR/$db/genome.2bit stdout | awk "{printf \"%s\t%s\t$GBDIR/$db/genome.2bit\n\", \$1,\$2}" > $GBDIR/$db/chromInfo.tab
cut -f 1,2 $GBDIR/$db/chromInfo.tab > $GBDIR/$db/genome.chrom.sizes


echo "creating genome database"
$MYSQL -e "create database $db;"

echo "creating chromInfo table"
$MYSQL $db < $SWDIR/kent/src/hg/lib/chromInfo.sql

echo "finding default position"
defchrom=$(sort -k2,2n $GBDIR/$db/chromInfo.tab | tail -n 1 | awk '{print $1}')
defstop=$(sort -k2,2n $GBDIR/$db/chromInfo.tab | tail -n 1 | awk '{print $2}')

echo "inserting chromInfo data"
$MYSQL -e "load data local infile \"$GBDIR/$db/chromInfo.tab\" into table $db.chromInfo;"

echo "creating grp table"
$MYSQL $db < $SWDIR/kent/src/hg/lib/grp.sql

echo "creating dbDb entry"
$MYSQL -e "INSERT INTO hgcentral.dbDb (name, description, nibPath, organism, defaultPos, active, orderKey, genome, scientificName, htmlPath, hgNearOk, hgPbOk, sourceName, taxId) VALUES (\"$db\", \"$assembly\", \"$GBDIR/$db\", \"$name\", \""$defchrom":1-"$defstop"\", 1, 1, \"$name\", \"$name\", \"$GBDIR/$db/html/description.html\", 0, 0, \"$db\", $taxonomic_id);"

# only for pioneer genomes
echo "creating defaultDb entry"
$MYSQL -e "INSERT INTO hgcentral.defaultDb (name, genome) VALUES (\"$db\", \"$name\");"

echo "inserting clade entry"
$MYSQL -e "INSERT INTO hgcentral.clade (name, label, priority) VALUES (\"$clade\", \"$clade\", \"$taxonomic_id\");"

# only for pioneer genomes
echo "inserting genomeClade entry"
$MYSQL -e "INSERT INTO hgcentral.genomeClade (genome,clade,priority) VALUES (\"$name\",\"$clade\",\"$taxonomic_id\")"

echo "creating gap table"
$MYSQL $db < $SWDIR/kent/src/hg/lib/gap.sql

#$SWDIR/kent/src/utils/qa/makeCytoBandIdeo.csh $db

echo "adding ideogram track configuration"
echo -e "track cytoBandIdeo\nshortLabel Chromosome Band (Ideogram)\nlongLabel Ideogram for Orientation\ngroup map\nvisibility dense\ntype bed 4 +" >> $GBDIR/$db/trackDb.ra

echo "creating ideogram"
hgsql $db -e 'load data local infile "chromInfo.tab" into table chromInfo;'
hgsql -N -e 'SELECT chrom, size FROM chromInfo' $db > $db.chroms
cat $db.chroms | awk '{print $1"\t"0"\t"$2"\t""\t""gneg"}' > $db.cytoBand
bedSort $db.cytoBand $db.cytoBand
export sql=/home/dlv04c/software/kent/src/hg/lib/cytoBandIdeo.sql
hgLoadSqlTab $db cytoBandIdeo $sql $db.cytoBand

echo "loading track configuration in database"
hgTrackDb $GBDIR/$db $db trackDb $SWDIR/kent/src/hg/lib/trackDb.sql $GBDIR/$db

echo "creating hgFindSpec table"
hgFindSpec $GBDIR/$db $db hgFindSpec $SWDIR/kent/src/hg/lib/hgFindSpec.sql $GBDIR/$db

echo "setting mysql permissions"
$MYSQL -e "GRANT SELECT, INSERT, UPDATE, DELETE, CREATE, DROP, ALTER, CREATE TEMPORARY TABLES on $db.* TO browser@localhost IDENTIFIED BY 'genome';"
$MYSQL -e "GRANT SELECT, INSERT, UPDATE, DELETE, CREATE, DROP, ALTER, CREATE TEMPORARY TABLES on hgcentral.* TO browser@localhost IDENTIFIED BY 'genome';"
$MYSQL -e "GRANT FILE on *.* TO browser@localhost IDENTIFIED BY 'genome';"
$MYSQL -e "GRANT SELECT, CREATE TEMPORARY TABLES on $db.* TO readonly@localhost IDENTIFIED BY 'access';"
$MYSQL -e "GRANT SELECT on mysql.* TO browser@localhost IDENTIFIED BY 'genome';"
$MYSQL -e "FLUSH PRIVILEGES;"








