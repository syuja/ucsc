RepeatMasker -species $genus -pa 25 -gff $fa

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
