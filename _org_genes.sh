if [ "$funct" = "genes"]; then
    cp $bed /gbdb/$name/
    hgLoadBed $name ensembl_genes_all $bed
    echo -e "track ensembl_genes_all\nshortLabel Ensembl Genes\\nlongLabel Ensembl Genes from plants.ensembl.org\ntype bed 12 .\ngroup genes\nvisibility pack\n\nsearchName ensembl_genes_all\nsearchTable ensembl_genes_all\nsearchType bed\nsearchPriority 10\nsearchMethod fuzzy" >> $name/trackDb.ra
    hgTrackDb /gbdb/$name $name trackDb /gbdb/kent/src/hg/lib/trackDb.sql /gbdb/$name
fi
