wget -qO- ftp://ftp.ensemblgenomes.org/pub/current/plants/gtf/zea_mays/Zea_mays.AGPv3.31.gtf.gz | gunzip -c | gtfToGenePred /dev/stdin /dev/stdout | genePredToBed /dev/stdin /dev/stdout | sort -k1,1 -k2,2n -k3,3n > $GBDIR/$name/bbi/ensemblGenes.bed

bedToBigBed $GBDIR/$name/bbi/ensemblGenes.bed $GBDIR/$name/genome.chrom.sizes $GBDIR/$name/bbi/ensemblGenes.bb

hgLoadBed $name ensembl_genes_all $bed

echo -e "track ensembl_genes_all\nshortLabel Ensembl Genes\\nlongLabel Ensembl Genes from plants.ensembl.org\ntype bed 12 .\ngroup genes\nvisibility pack\n\nsearchName ensembl_genes_all\nsearchTable ensembl_genes_all\nsearchType bed\nsearchPriority 10\nsearchMethod fuzzy" >> $name/trackDb.ra

hgTrackDb /gbdb/$name $name trackDb /gbdb/kent/src/hg/lib/trackDb.sql /gbdb/$name
