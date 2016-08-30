# clear from hgcentral: defaultDb, clade, genomeClade, dbDb, dbDbArch, liftOverChain, hubPublic, targetDb
# make sure host info is correct for custom tracks


# clear databases
hgsql -e "delete from hgcentral.dbDbArch"
hgsql -e "delete from hgcentral.hubPublic"
hgsql -e "delete from hgcentral.blatServers"
hgsql -e "delete from hgcentral.liftOverChain"
hgsql -e "delete from hgcentral.targetDb"

# download genome spreadsheet
curl -sL "https://spreadsheets.google.com/feeds/download/spreadsheets/Export?key="$DBDBID"&hl=en&exportFormat=tsv" | tr -d "\r" > $BROWSERDIR/db.tsv && echo "" >> $BROWSERDIR/db.tsv

# make assembly html files #######
cols=$(head -n 1 $BROWSERDIR/db.tsv)
tail -n+2 $BROWSERDIR/db.tsv | while IFS=$'\t' read -r $cols
do
  if [ "$summary" != "NA" ]; then
    echo "<br> $summary <br><hr>" > $htmlPath
  fi
  if [ "$credits" != "NA" ]; then
    echo "<h2>Credits</h2> $credits <hr>" >> $htmlPath
  fi

done

# make dbDb table
awk -F '\t' -v header=name,description,nibPath,organism,defaultPos,active,orderKey,genome,scientificName,htmlPath,hgNearOk,hgPbOk,sourceName  '
BEGIN {
  split(header,cols,",")
}
{
  if(NR==1){
    for (i=1; i<=NF; i++){cols[$i]=i}
  }
  if(NR>=1){
    print $cols["name"], $cols["description"], $cols["nibPath"], $cols["organism"], $cols["defaultPos"], $cols["active"], $cols["orderKey"], $cols["genome"], $cols["scientificName"], $cols["htmlPath"],  $cols["hgNearOk"], $cols["hgPbOk"], $cols["sourceName"]
  }
}' OFS='\t' $BROWSERDIR/db.tsv > $BROWSERDIR/dbDb.tsv

hgsql -e "delete from hgcentral.dbDb"
hgsql -e "load data local infile \"$BROWSERDIR/dbDb.tsv\" into table hgcentral.dbDb ignore 1 lines;"

# make clade table
awk -F '\t' -v clade="clade"  '
NR==1 {
  for (i=1; i<=NF; i++){
    ix[$i]=i
  }
  print "name","label","priority"}
NR>1  {
  if(!($ix[clade] in p)) {
    print $ix[clade], $ix[clade], NR; p[$ix[clade]]=$ix[clade]
  }
}' OFS='\t' $BROWSERDIR/db.tsv > $BROWSERDIR/clade.tsv

hgsql -e "delete from hgcentral.clade"
hgsql -e "load data local infile \"$BROWSERDIR/clade.tsv\" into table hgcentral.clade ignore 1 lines;"

# make genomeClade table
awk -F '\t' -v clade="clade"  -v organism="organism" '
NR==1 {
  for (i=1; i<=NF; i++){
    ix[$i]=i
  }
  print "genome","clade","priority"}
NR>1  {
  if(!($ix[organism] in p)) {
    print $ix[organism], $ix[clade], NR
    p[$ix[organism]]=$ix[organism]
  }
}' OFS='\t' $BROWSERDIR/db.tsv > $BROWSERDIR/genomeClade.tsv

hgsql -e "delete from hgcentral.genomeClade"
hgsql -e "load data local infile \"$BROWSERDIR/genomeClade.tsv\" into table hgcentral.genomeClade ignore 1 lines;"

# make defaultDb table
awk -F '\t' -v name="name"  -v organism="organism" '
NR==1 {
  for (i=1; i<=NF; i++){
    ix[$i]=i
  }
  print "genome","name"
}
NR>1  {
  if(!($ix[organism] in p)) {
    print $ix[organism], $ix[name]
    p[$ix[organism]]=$ix[organism]
  }
}' OFS='\t' $BROWSERDIR/db.tsv > $BROWSERDIR/defaultDb.tsv

hgsql -e "delete from hgcentral.defaultDb"
hgsql -e "load data local infile \"$BROWSERDIR/defaultDb.tsv\" into table hgcentral.defaultDb ignore 1 lines;"

# get header of genome list spreadsheet
cols=$(head -n 1 $BROWSERDIR/db.tsv)

# loop through genomes
tail -n+2 $BROWSERDIR/db.tsv | while IFS=$'\t' read -r $cols
do
  # if track spreadsheet defined for genome
  if [ "$gid" != "NA" ]; then

    # download track spreadsheet
    curl -sL "https://spreadsheets.google.com/feeds/download/spreadsheets/Export?key="$gid"&hl=en&exportFormat=tsv" | tr -d "\r" > $nibPath/trackDb.tsv && echo "" >> $nibPath/trackDb.tsv

    # create track database file from spreadsheet
    awk -F "\t" '{if(NR==1){split($0,xx,"\t"); nf=NF} ; if(NR>1 && $1==1){for (i = 1; i <= nf; i++) print xx[i]" "$i; print ""  }}' $nibPath/trackDb.tsv | grep -v " NA$" | grep -v "^_" > $nibPath/trackDb.ra

    # get header of track spreadsheet
    tcols=$(head -n 1 $nibPath/trackDb.tsv)

    # loop through tracks
    tail -n+2 $nibPath/trackDb.tsv | while IFS=$'\t' read -r $tcols
    do
      if [ "$bigDataUrl" != "NA" && ${_on} -eq 1 ]; then
        # assign bigData path to mysql table in genome database
        hgBbiDbLink $name $track ${nibPath}/bbi/ $bigDataUrl
      fi
    done

    # loop through beds/nonbinaries and load into database HERE
    # hgLoadBed

    # recreate trackDb table
    hgTrackDb $nibPath $name trackDb ${SWDIR}/kent/src/hg/lib/trackDb.sql $nibPath

  fi
done
