#!/bin/bash

outname=$(echo $1 | sed 's/gff3\.gz/bed/g')

wget -O- $1 |\ 
gunzip -c | gffread -T -o- Arabidopsis_thaliana.TAIR10.22.gff3 |\ 
sed 's/transcript://g' |\ 
sed 's/gene://g' |\ 
awk -F '\t' '{ if($2 != "."){print $0} }' OFS='\t' |\ 
gtfToGenePred stdin stdout |\ 
genePredToBed stdin stdout > $outname

