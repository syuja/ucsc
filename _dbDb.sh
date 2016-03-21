wget -qO- "https://spreadsheets.google.com/feeds/download/spreadsheets/Export?key=1KzkbiLoeGl9GO-CaBRnjVQb-t4GcQqCo-Y195i5ibVI&hl=en&exportFormat=tsv" | tr -d "\r"

 wget -r -A '30.dna_sm.genome.fa.gz' ftp://ftp.ensemblgenomes.org/pub/plants/release-30/fasta/

wget -qO- "https://spreadsheets.google.com/feeds/download/spreadsheets/Export?key=1KzkbiLoeGl9GO-CaBRnjVQb-t4GcQqCo-Y195i5ibVI&hl=en&exportFormat=tsv" | tr -d "\r" | awk '{ if(NR==1){print $1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,"nibPath"} else{ print $1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11, "/gbdb/" $1 }}' OFS='\t'  | column -t
