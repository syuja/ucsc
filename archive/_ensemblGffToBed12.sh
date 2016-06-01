#!/bin/bash

gffname=$(basename $1 | sed 's/gff3\.gz/gff3/g')
echo $gffname
bedname=$(basename $1 | sed 's/gff3\.gz/bed/g')
echo $bedname

wget -O- $1 | gunzip -c > $gffname
gffread -T -o- $gffname |\ 
sed 's/transcript://g' |\ 
sed 's/gene://g' |\ 
awk -F '\t' '{ if($2 != "."){print $0} }' OFS='\t' |\ 
gtfToGenePred stdin stdout |\ 
genePredToBed stdin stdout > $bedname

