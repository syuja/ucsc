#
# echo "finding default position"
# defchrom=$(sort -k2,2n $GBDIR/$name/chromInfo.tab | tail -n 1 | awk '{print $1}')
# defstop=$(sort -k2,2n $GBDIR/$name/chromInfo.tab | tail -n 1 | awk '{print $2}')
#$SWDIR/kent/src/utils/qa/makeCytoBandIdeo.csh $name


######################################


E_OPTERROR=85

if [ $# -lt 1 ]    # Script invoked with no command-line args?
then
  echo "Usage: `basename $0` assembly"
  exit $E_OPTERROR    # Exit and explain usage.
    # Usage: scriptname -options
    # Note: dash (-) necessary
fi

#set -e

assembly=$1

wget -qO- "https://spreadsheets.google.com/feeds/download/spreadsheets/Export?key="${DBDBID}"&hl=en&exportFormat=tsv" | tr -d "\r" > $BROWSERDIR/db.tsv && echo "" >> $BROWSERDIR/db.tsv


ocols=$(head -n 1 $BROWSERDIR/db.tsv)

tail -n+2 $BROWSERDIR/db.tsv | while IFS=$'\t' read -r $ocols
do
  if [[ "$name" == "$assembly" ]]; then

    hgsql -e "drop database $name"

    hgsql -e "create database $name"

    hgsql $name < $SWDIR/kent/src/hg/lib/chromInfo.sql

    hgsql -e "load data local infile \"$GBDIR/$name/chromInfo.tab\" into table $name.chromInfo;"

    hgsql $name < $SWDIR/kent/src/hg/lib/grp.sql

    hgsql $name < $SWDIR/kent/src/hg/lib/gap.sql

    hgLoadSqlTab $name cytoBandIdeo $SWDIR/kent/src/hg/lib/cytoBandIdeo.sql $GBDIR/$name/cytoband.bed

    wget -qO- "https://spreadsheets.google.com/feeds/download/spreadsheets/Export?key="$gid"&hl=en&exportFormat=tsv" | tr -d "\r" > $GBDIR/$name/trackDb.tsv && echo "" >> $GBDIR/$name/trackDb.tsv

    awk -F "\t" '{if(NR==1){split($0,xx,"\t"); nf=NF} ; for (i = 1; i <= nf; i++) print xx[i]" "$i; print ""  }' $GBDIR/$name/trackDb.tsv | grep -Pv ' NA$' | grep -v 'bigDataUrl' | grep -Pv '^_' > $GBDIR/$name/trackDb.ra

    cols=$(head -n 1 $GBDIR/$name/trackDb.tsv)

    cat $GBDIR/$name/trackDb.tsv | while IFS=$'\t' read -r $cols
    do
      if [ "$track" != 'track' ] && [ "$_searchable" -gt 0 ]; then
        echo "searchName $track"
        echo "searchTable $track"
        echo "searchType bed"
        echo "searchPriority $_searchable"
        echo "searchMethod fuzzy"
        echo ""
      fi
    done >> $GBDIR/$name/trackDb.ra

    ### HTML ###
    cols=$(head -n 1 $GBDIR/$name/trackDb.tsv)
    tail -n+2 $GBDIR/$name/trackDb.tsv | while IFS=$'\t' read -r $cols
    do
      if [ "$track" != 'track' ] && [ "$_methods" != "NA" ]; then

        echo "<h2>Credits</h2> $_credits <hr>" > $GBDIR/$name/${html}.html

        echo "<h2>Methods</h2> $_methods <hr>" >> $GBDIR/$name/${html}.html

      fi
    done


    hgTrackDb $GBDIR/$name $name trackDb $SWDIR/kent/src/hg/lib/trackDb.sql $GBDIR/$name

    hgFindSpec $GBDIR/$name $name hgFindSpec $SWDIR/kent/src/hg/lib/hgFindSpec.sql $GBDIR/$name

    hgsql -e "GRANT SELECT on $name.* TO readonly@'%' IDENTIFIED BY 'access';"
    hgsql -e "FLUSH PRIVILEGES;"


    cols=$(head -n 1 $GBDIR/$name/trackDb.tsv)

    tail -n+2 $GBDIR/$name/trackDb.tsv | while IFS=$'\t' read -r $cols
    do
      if [ "$_on" -gt 0 ]; then
        if [[ "$bigDataUrl" =~ ":" ]]; then
          hgBbiDbLink $name $track $bigDataUrl
        elif [[ "$bigDataUrl" =~ ".bed" ]]; then
          hgLoadBed $name $track $GBDIR/$name/bbi/$bigDataUrl
        else
          hgBbiDbLink $name $track $GBDIR/$name/bbi/$bigDataUrl
        fi
      fi
    done


  fi
done



#  if [ "$track" != 'track' ] && [ "$bigDataUrl" != 'NA' ]; then
#  if [ "$track" != 'track' ]; then
#  fi
