wget -qO- "https://spreadsheets.google.com/feeds/download/spreadsheets/Export?key=1ilMW4gv8XsECFuKpSlOFWVhO_04qiogVdQHYYxQF2ZM&hl=en&exportFormat=tsv" | tr -d "\r" | awk -F '\t' -v clade="clade"  'NR==1 {for (i=1; i<=NF; i++){ix[$i]=i}; print "name","label","priority"} ;
  NR>1  { if(!($ix[clade] in p)) {print $ix[clade], $ix[clade], NR; p[$ix[clade]]=$ix[clade] } }' OFS='\t'


#wget -qO- "https://spreadsheets.google.com/feeds/download/spreadsheets/Export?key=1ilMW4gv8XsECFuKpSlOFWVhO_04qiogVdQHYYxQF2ZM&hl=en&exportFormat=tsv" | tr -d "\r" | awk -F '\t' -v header=name,description,nibPath,organism,defaultPos,active,orderKey,genome,scientificName,htmlPath,hgNearOk,hgPbOk,sourceName  'BEGIN{split(header,cols,",") {for(i = 1; i <= length(cols); i++) { colarray[cols[i]]=i } ; NR==1 {for (i=1; i<=NF; i++){ix[$i]=i}; print "name","label","priority"} ;
#  NR>1  { if(!($ix[clade] in p)) {print $ix[clade], $ix[clade], NR; p[$ix[clade]]=$ix[clade] } }}' OFS='\t'


#wget -qO- "https://spreadsheets.google.com/feeds/download/spreadsheets/Export?key=1ilMW4gv8XsECFuKpSlOFWVhO_04qiogVdQHYYxQF2ZM&hl=en&exportFormat=tsv" | tr -d "\r" | \
#awk -F '\t' '-v c1="clade" 'NR==1 {for (i=1; i<=NF; i++){ix[$i]=i}} ; NR>1{print $ix[c1], $ix[c1]} '

# -v cols=name,description,nibPath,organism,defaultPos,active,orderKey,genome,scientificName,htmlPath,hgNearOk,hgPbOk,sourceName
