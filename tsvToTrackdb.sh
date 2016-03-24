

wget -qO- "https://spreadsheets.google.com/feeds/download/spreadsheets/Export?key=1EJ8DIuT_EUcOChEl6YwO20yAzJl4nPVGEP9K--idvFo&hl=en&exportFormat=tsv" | tr -d "\r" | awk -F "\t" '{if(NR==1){split($0,xx,"\t"); nf=NF} ; for (i = 1; i <= nf; i++) print xx[i]" "$i; print ""  }' | grep -Pv ' NA$'
