$name=zeaMay3
assembly="AGPv3"
name="Z. mays"
taxonomic_id="12345"
clade="grasses"



echo "creating genome database"
$MYSQL -e "create database $name;"

echo "creating chromInfo table"
$MYSQL $name < $SWDIR/kent/src/hg/lib/chromInfo.sql

echo "finding default position"
defchrom=$(sort -k2,2n $GBDIR/$name/chromInfo.tab | tail -n 1 | awk '{print $1}')
defstop=$(sort -k2,2n $GBDIR/$name/chromInfo.tab | tail -n 1 | awk '{print $2}')

echo "inserting chromInfo data"
$MYSQL -e "load data local infile \"$GBDIR/$name/chromInfo.tab\" into table $name.chromInfo;"

echo "creating grp table"
$MYSQL $name < $SWDIR/kent/src/hg/lib/grp.sql

echo "creating gap table"
$MYSQL $name < $SWDIR/kent/src/hg/lib/gap.sql

# echo "creating dbDb entry"
# $MYSQL -e "INSERT INTO hgcentral.dbDb (name, description, nibPath, organism, defaultPos, active, orderKey, genome, scientificName, htmlPath, hgNearOk, hgPbOk, sourceName, taxId) VALUES (\"$name\", \"$assembly\", \"$GBDIR/$name\", \"$name\", \""$defchrom":1-"$defstop"\", 1, 1, \"$name\", \"$name\", \"$GBDIR/$name/html/description.html\", 0, 0, \"$name\", $taxonomic_id);"

# only for pioneer genomes
# echo "creating defaultDb entry"
# $MYSQL -e "INSERT INTO hgcentral.defaultDb (name, genome) VALUES (\"$name\", \"$name\");"

# echo "inserting clade entry"
# $MYSQL -e "INSERT INTO hgcentral.clade (name, label, priority) VALUES (\"$clade\", \"$clade\", \"$taxonomic_id\");"

# only for pioneer genomes
# echo "inserting genomeClade entry"
# $MYSQL -e "INSERT INTO hgcentral.genomeClade (genome,clade,priority) VALUES (\"$name\",\"$clade\",\"$taxonomic_id\")"


#$SWDIR/kent/src/utils/qa/makeCytoBandIdeo.csh $name


#echo "creating ideogram track"
hgsql $name -e "load data local infile \""$GBDIR/$name/chromInfo.tab"\" into table chromInfo;"
#hgsql -N -e 'SELECT chrom, size FROM chromInfo' $name > $GBDIR/$name/chromInfo.tab
hgLoadSqlTab $name cytoBandIdeo $SWDIR/kent/src/hg/lib/cytoBandIdeo.sql $GBDBDIR/$name/cytoband.bed

#echo "loading track configuration in database"
hgTrackDb $GBDIR/$name $name trackDb $SWDIR/kent/src/hg/lib/trackDb.sql $GBDIR/$name

#echo "creating hgFindSpec table"
hgFindSpec $GBDIR/$name $name hgFindSpec $SWDIR/kent/src/hg/lib/hgFindSpec.sql $GBDIR/$name

#echo "setting mysql permissions" # make more restrictive. see http://genomewiki.ucsc.edu/index.php/Browser_Installation
#$MYSQL -e "GRANT SELECT, INSERT, UPDATE, DELETE, CREATE, DROP, ALTER, CREATE TEMPORARY TABLES on $name.* TO browser@'%' IDENTIFIED BY 'genome';"
#$MYSQL -e "GRANT SELECT, INSERT, UPDATE, DELETE, CREATE, DROP, ALTER, CREATE TEMPORARY TABLES on hgcentral.* TO readwrite@'%' IDENTIFIED BY 'genome';"
#$MYSQL -e "GRANT FILE on *.* TO browser@'%' IDENTIFIED BY 'genome';"
#$MYSQL -e "GRANT SELECT, CREATE TEMPORARY TABLES on $name.* TO readonly@'%' IDENTIFIED BY 'access';"
$MYSQL -e "GRANT SELECT on $name.* TO readonly@'%' IDENTIFIED BY 'access';"
#$MYSQL -e "GRANT SELECT on mysql.* TO browser@'%' IDENTIFIED BY 'genome';"
$MYSQL -e "FLUSH PRIVILEGES;"
