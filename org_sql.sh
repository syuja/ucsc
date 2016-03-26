#
# echo "finding default position"
# defchrom=$(sort -k2,2n $GBDIR/$name/chromInfo.tab | tail -n 1 | awk '{print $1}')
# defstop=$(sort -k2,2n $GBDIR/$name/chromInfo.tab | tail -n 1 | awk '{print $2}')
#$SWDIR/kent/src/utils/qa/makeCytoBandIdeo.csh $name

name="zeaMayB73_v3"
description="AGPv3"
nibPath="/gbdb/zeaMayB73_v3"
organism="Zea mays B73"
defaultPos="1:1-100000"
active="1"
orderKey="1"
genome=$organism
scientificName=$organism
htmlPath=$GBDIR/$name/html/assembly
hgNearOk=0
hgPbOk=0
sourceName="GCA_000005005.5"
gid="1EJ8DIuT_EUcOChEl6YwO20yAzJl4nPVGEP9K--idvFo"

######################################

hsql -e "drop database $name"

hgsql -e "create database $name"

hgsql $name < $SWDIR/kent/src/hg/lib/chromInfo.sql

hgsql -e "load data local infile \"$GBDIR/$name/chromInfo.tab\" into table $name.chromInfo;"

hgsql $name < $SWDIR/kent/src/hg/lib/grp.sql

hgsql $name < $SWDIR/kent/src/hg/lib/gap.sql

hgLoadSqlTab $name cytoBandIdeo $SWDIR/kent/src/hg/lib/cytoBandIdeo.sql $GBDIR/$name/cytoband.bed

wget -qO- "https://spreadsheets.google.com/feeds/download/spreadsheets/Export?key="$gid"&hl=en&exportFormat=tsv" | tr -d "\r" > $GBDIR/$name/trackDb.tsv && echo "" >> $GBDIR/$name/trackDb.tsv

awk -F "\t" '{if(NR==1){split($0,xx,"\t"); nf=NF} ; for (i = 1; i <= nf; i++) print xx[i]" "$i; print ""  }' $GBDIR/$name/trackDb.tsv | grep -Pv ' NA$' | grep -v 'bigDataUrl' | grep -Pv '^_' > $GBDIR/$name/trackDb.ra

hgTrackDb $GBDIR/$name $name trackDb $SWDIR/kent/src/hg/lib/trackDb.sql $GBDIR/$name

hgFindSpec $GBDIR/$name $name hgFindSpec $SWDIR/kent/src/hg/lib/hgFindSpec.sql $GBDIR/$name

hgsql -e "GRANT SELECT on $name.* TO readonly@'%' IDENTIFIED BY 'access';"
hgsql -e "FLUSH PRIVILEGES;"


cols=$(head -n 1 $GBDIR/$name/trackDb.tsv)

while IFS=$'\t' read -r $cols
do
  if [ "$track" != 'track' ] && [ "$bigDataUrl" != 'NA' ]; then
    if [ "$bigDataUrl" == *":"* ]; then
      hgBbiDbLink $name $track $bigDataUrl
    else
      hgBbiDbLink $name $track $GBDIR/$name/bbi/$bigDataUrl
    fi
  fi
done < $GBDIR/$name/trackDb.tsv
