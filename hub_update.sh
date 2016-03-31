#!/bin/bash

HUBDBID="10s9OMdrj-xRVZMunPMijqBoKWc5nmePOvUhZOA-XYxI"

E_OPTERROR=85

if [ $# -lt 1 ]    # Script invoked with no command-line args?
then
  echo "Usage: `basename $0` hubName"
  exit $E_OPTERROR    # Exit and explain usage.
    # Usage: scriptname -options
    # Note: dash (-) necessary
fi

#set -e

hubname=$1

>&2 echo "downloading hub list"

curl -L "https://spreadsheets.google.com/feeds/download/spreadsheets/Export?key="$HUBDBID"&hl=en&exportFormat=tsv" | tr -d "\r" > hubDb.tsv && echo "" >> hubDb.tsv

ocols=$(head -n 1 hubDb.tsv)
tail -n+2 hubDb.tsv | while IFS=$'\t' read -r $ocols
do
  if [[ "$name" == "$hubname" ]]; then

    mkdir -p $hubname

    >&2 echo "downloading info for hub \"$hubname\""

    curl -L "https://spreadsheets.google.com/feeds/download/spreadsheets/Export?key="$hubId"&hl=en&exportFormat=tsv" | tr -d "\r" > $hubname/hub.tsv && echo "" >> $hubname/hub.tsv

    grep -Pv '^_' $hubname/hub.tsv | tr '\t' ' ' > $hubname/hub.txt

    genomesId=$(grep _genomes $hubname/hub.tsv | cut -f 2)

    curl -L "https://spreadsheets.google.com/feeds/download/spreadsheets/Export?key="$genomesId"&hl=en&exportFormat=tsv" | tr -d "\r" > $hubname/genomes.tsv && echo "" >> $hubname/genomes.tsv


    rm -f $hubname/genomes.txt

    ### HTML ###
    gcols=$(head -n 1 $hubname/genomes.tsv)
    tail -n+2 $hubname/genomes.tsv | while IFS=$'\t' read -r $gcols
    do

      echo "genome $genome" >> $hubname/genomes.txt
      echo "trackDb $genome/hubDb.txt" >> $hubname/genomes.txt

      mkdir -p $hubname/$genome/bbi

      >&2 echo "downloading track table for \"$genome\""

      curl -L "https://spreadsheets.google.com/feeds/download/spreadsheets/Export?key="$genomeId"&hl=en&exportFormat=tsv" | tr -d "\r" > $hubname/$genome/hubDb.tsv && echo "" >> $hubname/$genome/hubDb.tsv

      >&2 echo "  creating track database file"

      awk -F "\t" '{if(NR==1){split($0,xx,"\t"); nf=NF} ; if(NR>1 && $1==1){for (i = 1; i <= nf; i++) print xx[i]" "$i; print ""  }}' $hubname/$genome/hubDb.tsv | grep -Pv ' NA$' | grep -Pv '^_' > $hubname/$genome/hubDb.txt

    done # end genome loop

    >&2 echo "updating hub on server"
    >&2 echo "enter password for $userhost"


    scp -r $hubname/ ${userhost}:$(dirname $path)

  fi # end hub

done
