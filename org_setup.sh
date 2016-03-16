# RUN THIS ON THE WEB SERVER

mkdir -p $GBDIR/$name/bbi
mkdir -p $GBDIR/$name/html

#echo "converting fa to 2bit"
faToTwoBit $GBDIR/$name/genome.fa $GBDIR/$name/genome.2bit

#echo "getting chromosome info from 2bit"
twoBitInfo $GBDIR/$name/genome.2bit stdout | awk "{printf \"%s\t%s\t$GBDIR/$name/genome.2bit\n\", \$1,\$2}" > $GBDIR/$name/chromInfo.tab
cut -f 1,2 $GBDIR/$name/chromInfo.tab > $GBDIR/$name/genome.chrom.sizes


#echo "$(wc -l /gbdb/$name/chromInfo.tab | awk '{print $1}') scaffolds found"

#echo "adding ideogram track configuration"
echo -e "track cytoBandIdeo\nshortLabel Chromosome Band (Ideogram)\nlongLabel Ideogram for Orientation\ngroup map\nvisibility dense\ntype bed 4 +" >> $GBDIR/$name/trackDb.ra

cat $GBDIR/$name/genome.chrom.sizes | awk '{print $1"\t"0"\t"$2"\t""\t""gneg"}' | sort -k1,1 -k2,2n > cytoband.bed
