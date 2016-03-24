
wget -qO- "https://spreadsheets.google.com/feeds/download/spreadsheets/Export?key="$DBDBID"&hl=en&exportFormat=tsv" | tr -d "\r" | awk -F '\t' -v name="name"  -v organism="organism" 'NR==1 {for (i=1; i<=NF; i++){ix[$i]=i}; print "genome","name"} ;
 NR>1  { if(!($ix[organism] in p)) {print $ix[organism], $ix[name]; p[$ix[organism]]=$ix[organism] } }' OFS='\t'
