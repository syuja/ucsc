#!/bin/bash

wget -O- ftp.ensemblgenomes.org/pub/release-22/plants/gff3/arabidopsis_thaliana/Arabidopsis_thaliana.TAIR10.22.gff3.gz | gunzip -c | gffread -T -o- Arabidopsis_thaliana.TAIR10.22.gff3 | sed 's/transcript://g' | sed 's/gene://g' | awk -F '\t' '{ if($2 != "."){print $0} }' OFS='\t' | gtfToGenePred stdin stdout | genePredToBed stdin stdout > out.bed
