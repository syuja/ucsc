#!/bin/bash


E_OPTERROR=85

if [ $# -lt 1 ]    # Script invoked with no command-line args?
then
  echo "Usage: `basename $0` function genomesfile"
  exit $E_OPTERROR    # Exit and explain usage.
    # Usage: scriptname -options
    # Note: dash (-) necessary
fi

#set -e

genomesfile=$1
#option=$3

cols=$(head -n 1 $genomesfile)
i=0



while IFS=$'\t' read -r $cols
do
  if [ "$ensemblGff" != "NA" && $name != "name" ]
  then
    echo "processing $name"
    mkdir -p ${name}/bbi

    # grab gff
    curl -s ${ensemblGff} | gunzip -c | sed 's/?/\./g' > ${name}/ensemblAnnotations.gff

    # genes
    gffread -T -o- ${name}/ensemblAnnotations.gff | sed 's/transcript://g' | sed 's/gene://g' | awk -F '\t' '{ if($2 != "."){print $0} }' OFS='\t' | gtfToGenePred stdin stdout | genePredToBed stdin stdout > ${name}/ensemblGenes.bed

    # non-simple repeats
    grep 'repeat_region' ${name}/ensemblAnnotations.gff | cut -f 1,4,5,9 | sed 's/Name=//g' | sed 's/class=//g' | sed 's/;repeat_consensus=.*//g' | grep -v 'trf;trf' | grep -v 'dust;dust' | sort -k1,1 -k2,2n -k3,3n > ${name}/ensemblRepeats.bed
    bedToBigBed ${name}/ensemblRepeats.bed ${name}/genome.chrom.sizes ${name}/bbi/ensemblRepeats.bb
    # trf
    grep 'repeat_region' ${name}/ensemblAnnotations.gff | grep 'Name=trf' | cut -f 1,4,5 | sort -k1,1 -k2,2n -k3,3n > ${name}/bbi/ensemblTrfs.bed
    bedToBigBed ${name}/ensemblRepeats.bed ${name}/genome.chrom.sizes ${name}/bbi/ensemblTrfs.bb

    # dust
    grep 'repeat_region' ${name}/ensemblAnnotations.gff | grep 'Name=dust' | cut -f 1,4,5 | sort -k1,1 -k2,2n -k3,3n > ${name}/bbi/ensemblDust.bed
    bedToBigBed ${name}/ensemblRepeats.bed ${name}/genome.chrom.sizes ${name}/bbi/ensemblDust.bb


  fi
done < "$genomesfile"
