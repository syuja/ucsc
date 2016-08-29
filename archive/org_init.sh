# RUN THIS ON THE WEB SERVER
wget -brA 'dna_sm.genome.fa.gz' ftp://ftp.ensemblgenomes.org/pub/plants/release-31/fasta/


name="JGIv2.0"
dname="setaria_italica"
faurl="ftp://ftp.ensemblgenomes.org/pub/release-22/plants/fasta/zea_mays/dna/Zea_mays.AGPv3.22.dna_sm.genome.fa.gz"


mkdir -p $GBDIR/$name/bbi
mkdir -p $GBDIR/$name/html

#curl -so $GBDIR/$name/genome.fa.gz $faurl
cp ftp.ensemblgenomes.org/pub/plants/release-31/fasta/$dname/dna/*dna_sm.genome.fa.gz $GBDIR/$name/genome.fa.gz

gunzip $GBDIR/$name/genome.fa.gz

faToTwoBit $GBDIR/$name/genome.fa $GBDIR/$name/genome.2bit

twoBitInfo $GBDIR/$name/genome.2bit stdout | awk "{printf \"%s\t%s\t$GBDIR/$name/genome.2bit\n\", \$1,\$2}" > $GBDIR/$name/chromInfo.tab
cut -f 1,2 $GBDIR/$name/chromInfo.tab | sort -k1,1 > $GBDIR/$name/genome.chrom.sizes


#echo "$(wc -l /gbdb/$name/chromInfo.tab | awk '{print $1}') scaffolds found"

#echo "adding ideogram track configuration"
echo -e "track cytoBandIdeo\nshortLabel Chromosome Band (Ideogram)\nlongLabel Ideogram for Orientation\ngroup map\nvisibility dense\ntype bed 4 +" >> $GBDIR/$name/trackDb.ra

cat $GBDIR/$name/genome.chrom.sizes | awk '{print $1"\t"0"\t"$2"\t""\t""gneg"}' | sort -k1,1 -k2,2n > $GBDIR/$name/cytoband.bed
