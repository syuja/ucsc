#!/bin/bash


E_OPTERROR=85

if [ $# -lt 2 ]    # Script invoked with no command-line args?
then
  echo "Usage: `basename $0` function genomesfile"
  exit $E_OPTERROR    # Exit and explain usage.
    # Usage: scriptname -options
    # Note: dash (-) necessary
fi

#set -e

genomesfile=$1
funct=$2
option=$3

echo "genomefile is $genomesfile"
echo "function is $funct"


cols=$(head -n 1 "$genomesfile")
i=0
while IFS=$'\t' read -r $cols

do
  echo "echoing genus_species"
  echo $genus_species
  echo "done echoing"
 i=$((i+1))

   if [[ ("$i" -ne 1) ]] ; then
	genus=$(echo "$genus_species" | awk '{print $1}' | tr '[:upper:]' '[:lower:]')
        species=$(echo "$genus_species" | awk '{print $2}' | tr '[:upper:]' '[:lower:]')
        species="${species^}"
	subspecies=$(echo "$genus_species" | awk '{print $3}' | tr '[:upper:]' '[:lower:]')
        subspecies="${subspecies^}"

	if [ "$ensembl_fasta" != "NA" ] ; then
            ver="22"
	    assembly="$ensembl_name"
            fa=$ensembl_fasta
	else
            ver="Phytozome"
	    assembly="$phytozome_assembly_name"
            fa=$phytozome_fasta
        fi
       db="${genus:0:3}""${species:0:3}""${subspecies:0:3}""$ver"
	echo $name

        if [ "$funct" = "insert" ] ; then

            echo "making genome directory"
            mkdir -p /gbdb/$name/bbi
            mkdir -p /gbdb/$name/html

            echo "converting fa to 2bit"
            faToTwoBit $fa /gbdb/$name/genome.2bit

            echo "getting chromosome info from 2bit"
            twoBitInfo /gbdb/$name/genome.2bit stdout | awk "{printf \"%s\t%s\t/gbdb/$name/genome.2bit\n\", \$1,\$2}" > /gbdb/$name/chromInfo.tab
            cut -f 1,2 /gbdb/$name/chromInfo.tab > /gbdb/$name/genome.chrom.sizes

	          echo "$(wc -l /gbdb/$name/chromInfo.tab | awk '{print $1}') scaffolds found"

            echo "creating genome database"
            $MYSQL -e "create database $name;"

            echo "creating chromInfo table"
            $MYSQL $name < /gbdb/kent/src/hg/lib/chromInfo.sql

            echo "finding default position"
            defchrom=$(sort -k2,2n /gbdb/$name/chromInfo.tab | tail -n 1 | awk '{print $1}')
            defstop=$(sort -k2,2n /gbdb/$name/chromInfo.tab | tail -n 1 | awk '{print $2}')

            echo "inserting chromInfo data"
            $MYSQL -e "load data local infile \"/gbdb/$name/chromInfo.tab\" into table $name.chromInfo;"

            echo "creating grp table"
            $MYSQL $name < /gbdb/kent/src/hg/lib/grp.sql

            echo "creating dbDb entry"
            $MYSQL -e "INSERT INTO hgcentral.dbDb (name, description, nibPath, organism, defaultPos, active, orderKey, genome, scientificName, htmlPath, hgNearOk, hgPbOk, sourceName, taxId) VALUES (\"$name\", \"$assembly\", \"/gbdb/$name\", \"$name\", \""$defchrom":1-"$defstop"\", 1, 1, \"$name\", \"$name\", \"/gbdb/$name/html/description.html\", 0, 0, \"$name\", $taxonomic_id);"

            # only for pioneer genomes
            echo "creating defaultDb entry"
            $MYSQL -e "INSERT INTO hgcentral.defaultDb (name, genome) VALUES (\"$name\", \"$name\");"

            echo "inserting clade entry"
            $MYSQL -e "INSERT INTO hgcentral.clade (name, label, priority) VALUES (\"$clade\", \"$clade\", \"$taxonomic_id\");"

            # only for pioneer genomes
            echo "inserting genomeClade entry"
            $MYSQL -e "INSERT INTO hgcentral.genomeClade (genome,clade,priority) VALUES (\"$name\",\"$clade\",\"$taxonomic_id\")"

            echo "creating gap table"
            $MYSQL $name < /gbdb/kent/src/hg/lib/gap.sql

            echo "creating ideogram"
            /gbdb/kent/src/utils/qa/makeCytoBandIdeo.csh $name

            echo "adding ideogram track configuration"
            echo -e "track cytoBandIdeo\nshortLabel Chromosome Band (Ideogram)\nlongLabel Ideogram for Orientation\ngroup map\nvisibility dense\ntype bed 4 +" >> /gbdb/$name/trackDb.ra

            echo "loading track configuration in database"
            hgTrackDb /gbdb/$name $name trackDb /gbdb/kent/src/hg/lib/trackDb.sql /gbdb/$name

            echo "creating hgFindSpec table"
            hgFindSpec /gbdb/$name $name hgFindSpec /gbdb/kent/src/hg/lib/hgFindSpec.sql /gbdb/$name

            echo "setting mysql permissions"
            $MYSQL -e "GRANT SELECT, INSERT, UPDATE, DELETE, CREATE, DROP, ALTER, CREATE TEMPORARY TABLES on $name.* TO browser@localhost IDENTIFIED BY 'genome';"
            $MYSQL -e "GRANT SELECT, INSERT, UPDATE, DELETE, CREATE, DROP, ALTER, CREATE TEMPORARY TABLES on hgcentral.* TO browser@localhost IDENTIFIED BY 'genome';"
            $MYSQL -e "GRANT FILE on *.* TO browser@localhost IDENTIFIED BY 'genome';"
            $MYSQL -e "GRANT SELECT, CREATE TEMPORARY TABLES on $name.* TO readonly@localhost IDENTIFIED BY 'access';"
            $MYSQL -e "GRANT SELECT on mysql.* TO browser@localhost IDENTIFIED BY 'genome';"
            $MYSQL -e "FLUSH PRIVILEGES;"
        fi

        if [ "$funct" = "genes"]; then
            cp $bed /gbdb/$name/
            hgLoadBed $name ensembl_genes_all $bed
            echo -e "track ensembl_genes_all\nshortLabel Ensembl Genes\\nlongLabel Ensembl Genes from plants.ensembl.org\ntype bed 12 .\ngroup genes\nvisibility pack\n\nsearchName ensembl_genes_all\nsearchTable ensembl_genes_all\nsearchType bed\nsearchPriority 10\nsearchMethod fuzzy" >> $name/trackDb.ra
            hgTrackDb /gbdb/$name $name trackDb /gbdb/kent/src/hg/lib/trackDb.sql /gbdb/$name
        fi

        if [ "$funct" = "vcf" & $vcf != "NA"]; then
            cp $vcf /gbdb/$name/
            hgBbiDbLink $name ensembl_snp /gbdb/$vcf
            echo -e "track ensembl_snp\nshortLabel SNPs (Ensembl)\\nlongLabel SNPs from plants.ensembl.org\ntype vcfTabix\ngroup varRep\nvisibility pack" >> $name/trackDb.ra
            hgTrackDb /gbdb/$name $name trackDb /gbdb/kent/src/hg/lib/trackDb.sql /gbdb/$name
        fi

        if [ "$funct" = "mask" ]; then
            RepeatMasker -species $genus -pa 25 -gff $fa
        fi


        if [ "$funct" = "masktrack" ]; then

            rclasses=($(tail -n+4 $rmout | awk '{print $11}' | sort | uniq))

            echo -e "track repeatmasker\nshortLabel RepeatMasker\nlongLabel Repeating Elements by RepeatMasker\ntype bigBed 4\ncompositeTrack on\nvisibility dense\nallButtonPair on\ndragAndDrop on\n\n" > /gbdb/$name/trackDb.tmp

            for curclass in ${rclasses[*]}
            do
                curclassname=$(echo $curclass | tr /\? _)
                bedname=/gbdb/$name/$(basename $rmout | sed -r 's/\.[[:alnum:]]+\.[[:alnum:]]+$//')_repeats_"$curclassname".bed
                bwname=/gbdb/$name/$(basename $rmout | sed -r 's/\.[[:alnum:]]+\.[[:alnum:]]+$//')_repeats_"$curclassname".bw
                echo $curclass
                echo $curclassname
                echo $bedname
                echo $bwname
                echo "awk -v curclass=$curclass '{if ($11==curclass) print $5,$6,$7,$10}' OFS='\t' $rmout > $bedname"
                awk -v curclass=$curclass '{if ($11==curclass) print $5,$6,$7,$10}' OFS='\t' $rmout > $bedname
                echo "bedToBigBed $bedname /gbdb/"$name"/genome.chrom.sizes $bwname"
                bedToBigBed $bedname /gbdb/"$name"/genome.chrom.sizes $bwname
                echo "echo -e "track repeatmasker_"$curclassname"\nshortLabel $curclass\nlongLabel $curclass elements by RepeatMasker\nparent repeatmasker\ntype bigBed 4\nvisibility dense\n\n" >> /gbdb/$name/trackDb.tmp"
                echo -e "track repeatmasker_"$curclassname"\nshortLabel $curclass\nlongLabel $curclass elements by RepeatMasker\nparent repeatmasker\ntype bigBed 4\nvisibility dense\n\n" >> /gbdb/$name/trackDb.tmp
                echo "hgBbiDbLink $name repeatmasker_"$curclassname" $bwname"
                hgBbiDbLink $name repeatmasker_"$curclassname" $bwname


            done

            cat /gbdb/$name/trackDb.tmp >> /gbdb/$name/trackDb.ra
            hgTrackDb /gbdb/$name $name trackDb /gbdb/kent/src/hg/lib/trackDb.sql /gbdb/$name
        fi
    fi

done < "$genomesfile"
