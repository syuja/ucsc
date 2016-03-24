wget -qO- "https://spreadsheets.google.com/feeds/download/spreadsheets/Export?key=1ilMW4gv8XsECFuKpSlOFWVhO_04qiogVdQHYYxQF2ZM&hl=en&exportFormat=tsv" | tr -d "\r" | awk -F '\t' -v header=name,description,nibPath,organism,defaultPos,active,orderKey,genome,scientificName,htmlPath,hgNearOk,hgPbOk,sourceName  '
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
}' OFS='\t'
