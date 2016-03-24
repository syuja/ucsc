
wget -qO- "https://spreadsheets.google.com/feeds/download/spreadsheets/Export?key=1ilMW4gv8XsECFuKpSlOFWVhO_04qiogVdQHYYxQF2ZM&hl=en&exportFormat=tsv" | tr -d "\r" | awk -F '\t' -v clade="clade"  -v organism="organism" 'NR==1 {for (i=1; i<=NF; i++){ix[$i]=i}; print "genome","clade","priority"} ;
 NR>1  { if(!($ix[organism] in p)) {print $ix[organism], $ix[clade], NR; p[$ix[organism]]=$ix[organism] } }' OFS='\t'
