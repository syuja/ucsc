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

>&2 echo "downloading db sheet"

wget -qO- "https://spreadsheets.google.com/feeds/download/spreadsheets/Export?key="$DBDBID"&hl=en&exportFormat=tsv" | tr -d "\r" > $BROWSERDIR/db.tsv && echo "" >> $BROWSERDIR/db.tsv

>&2 echo "recreating assembly db"

ocols=$(head -n 1 $BROWSERDIR/db.tsv)

tail -n+2 $BROWSERDIR/db.tsv | while IFS=$'\t' read -r $ocols
do
  if [[ "$name" == "$assembly" ]]; then

    >&2 echo "  deleting assembly db"

    hgsql -e "drop database $name"

    >&2 echo "  recreating assembl db"

    hgsql -e "create database $name"

    >&2 echo "  loading chromInfo"

    hgsql $name < $SWDIR/kent/src/hg/lib/chromInfo.sql

    hgsql -e "load data local infile \"$GBDIR/$name/chromInfo.tab\" into table $name.chromInfo;"

    >&2 echo "  loading grp and gap tables"

    hgsql $name < $SWDIR/kent/src/hg/lib/grp.sql

    hgsql $name < $SWDIR/kent/src/hg/lib/gap.sql

    hgLoadSqlTab $name cytoBandIdeo $SWDIR/kent/src/hg/lib/cytoBandIdeo.sql $GBDIR/$name/cytoband.bed

    >&2 echo "  downloading track info"

    wget -qO- "https://spreadsheets.google.com/feeds/download/spreadsheets/Export?key="$gid"&hl=en&exportFormat=tsv" | tr -d "\r" > $GBDIR/$name/trackDb.tsv && echo "" >> $GBDIR/$name/trackDb.tsv

    >&2 echo "  creating track database file"

    awk -F "\t" '{if(NR==1){split($0,xx,"\t"); nf=NF} ; if(NR>1){for (i = 1; i <= nf; i++) print xx[i]" "$i; print ""  }}' $GBDIR/$name/trackDb.tsv | grep -Pv ' NA$' | grep -v 'bigDataUrl' | grep -Pv '^_' > $GBDIR/$name/trackDb.ra


    # >&2 echo "  making searches"

    # cols=$(head -n 1 $GBDIR/$name/trackDb.tsv)
    # tail -n+2 $GBDIR/$name/trackDb.tsv | while IFS=$'\t' read -r $cols
    # do
    #   if [ "$searchPriority" != "NA" ] && [ type == "bed"* ]; then
    #     echo "searchName $track"
    #     echo "searchTable $track"
    #     echo "searchType bed"
    #     echo "searchPriority $searchPriority"
    #     echo "searchMethod fuzzy"
    #     echo ""
    #   fi
    # done >> $GBDIR/$name/trackDb.ra

    >&2 echo "  making track description pages"

    ### HTML ###
    cols=$(head -n 1 $GBDIR/$name/trackDb.tsv)
    tail -n+2 $GBDIR/$name/trackDb.tsv | while IFS=$'\t' read -r $cols
    do
      if [ "$_methods" != "NA" ]; then

        echo "<h2>Credits</h2> $_credits <hr>" > $GBDIR/$name/${html}.html

        echo "<h2>Methods</h2> $_methods <hr>" >> $GBDIR/$name/${html}.html

      fi
    done

    >&2 echo "making track database"

    hgTrackDb $GBDIR/$name $name trackDb $SWDIR/kent/src/hg/lib/trackDb.sql $GBDIR/$name

    >&2 echo "making search database"

    hgFindSpec $GBDIR/$name $name hgFindSpec $SWDIR/kent/src/hg/lib/hgFindSpec.sql $GBDIR/$name

    >&2 echo "mysql perms"

    hgsql -e "GRANT SELECT on $name.* TO readonly@'%' IDENTIFIED BY 'access';"
    hgsql -e "FLUSH PRIVILEGES;"

    >&2 echo "loading track data"

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
