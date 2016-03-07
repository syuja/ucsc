wget -qO- "https://spreadsheets.google.com/feeds/download/spreadsheets/Export?key=1KzkbiLoeGl9GO-CaBRnjVQb-t4GcQqCo-Y195i5ibVI&hl=en&exportFormat=tsv" | tr -d "\r"

 wget -r -A '30.dna_sm.genome.fa.gz' ftp://ftp.ensemblgenomes.org/pub/plants/release-30/fasta/
