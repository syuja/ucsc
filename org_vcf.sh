cp $vcf /gbdb/$name/
hgBbiDbLink $name ensembl_snp /gbdb/$vcf
echo -e "track ensembl_snp\nshortLabel SNPs (Ensembl)\\nlongLabel SNPs from plants.ensembl.org\ntype vcfTabix\ngroup varRep\nvisibility pack" >> $name/trackDb.ra
hgTrackDb /gbdb/$name $name trackDb /gbdb/kent/src/hg/lib/trackDb.sql /gbdb/$name
