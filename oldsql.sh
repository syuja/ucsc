
echo "creating genome database"
$MYSQL -e "create database $name;"

echo "creating chromInfo table"
$MYSQL $name < /gbdb/kent/src/hg/lib/chromInfo.sql

echo "finding default position"
defchrom=$(sort -k2,2n /gbdb/$name/chromInfo.tab | tail -n 1 | awk '{print $1}')
defstop=$(sort -k2,2n /gbdb/$name/chromInfo.tab | tail -n 1 | awk '{print $2}')

echo "inserting chromInfo data"
$MYSQL -e "load data local infile \"/gbdb/$name/chromInfo.tab\" into table $name.chromInfo;"

echo "creating grp table"
$MYSQL $name < /gbdb/kent/src/hg/lib/grp.sql

echo "creating dbDb entry"
$MYSQL -e "INSERT INTO hgcentral.dbDb (name, description, nibPath, organism, defaultPos, active, orderKey, genome, scientificName, htmlPath, hgNearOk, hgPbOk, sourceName, taxId) VALUES (\"$name\", \"$assembly\", \"/gbdb/$name\", \"$name\", \""$defchrom":1-"$defstop"\", 1, 1, \"$name\", \"$name\", \"/gbdb/$name/html/description.html\", 0, 0, \"$name\", $taxonomic_id);"

# only for pioneer genomes
echo "creating defaultDb entry"
$MYSQL -e "INSERT INTO hgcentral.defaultDb (name, genome) VALUES (\"$name\", \"$name\");"

echo "inserting clade entry"
$MYSQL -e "INSERT INTO hgcentral.clade (name, label, priority) VALUES (\"$clade\", \"$clade\", \"$taxonomic_id\");"

# only for pioneer genomes
echo "inserting genomeClade entry"
$MYSQL -e "INSERT INTO hgcentral.genomeClade (genome,clade,priority) VALUES (\"$name\",\"$clade\",\"$taxonomic_id\")"

echo "creating gap table"
$MYSQL $name < /gbdb/kent/src/hg/lib/gap.sql

echo "creating ideogram"
/gbdb/kent/src/utils/qa/makeCytoBandIdeo.csh $name

echo "adding ideogram track configuration"
echo -e "track cytoBandIdeo\nshortLabel Chromosome Band (Ideogram)\nlongLabel Ideogram for Orientation\ngroup map\nvisibility dense\ntype bed 4 +" >> /gbdb/$name/trackDb.ra

echo "loading track configuration in database"
hgTrackDb /gbdb/$name $name trackDb /gbdb/kent/src/hg/lib/trackDb.sql /gbdb/$name

echo "creating hgFindSpec table"
hgFindSpec /gbdb/$name $name hgFindSpec /gbdb/kent/src/hg/lib/hgFindSpec.sql /gbdb/$name

echo "setting mysql permissions"
$MYSQL -e "GRANT SELECT, INSERT, UPDATE, DELETE, CREATE, DROP, ALTER, CREATE TEMPORARY TABLES on $name.* TO browser@localhost IDENTIFIED BY 'genome';"
$MYSQL -e "GRANT SELECT, INSERT, UPDATE, DELETE, CREATE, DROP, ALTER, CREATE TEMPORARY TABLES on hgcentral.* TO browser@localhost IDENTIFIED BY 'genome';"
$MYSQL -e "GRANT FILE on *.* TO browser@localhost IDENTIFIED BY 'genome';"
$MYSQL -e "GRANT SELECT, CREATE TEMPORARY TABLES on $name.* TO readonly@localhost IDENTIFIED BY 'access';"
$MYSQL -e "GRANT SELECT on mysql.* TO browser@localhost IDENTIFIED BY 'genome';"
$MYSQL -e "FLUSH PRIVILEGES;"
